import Fastify from "fastify";
import postgres from "@fastify/postgres";
import redis from "@fastify/redis";
import nodemailer from "nodemailer";
import cors from "@fastify/cors";

const fastify = Fastify({
  logger: true,
});

fastify.register(postgres, {
  connectionString: process.env.DATABASE_URL,
});

fastify.register(redis, {
  url: process.env.REDIS_URL || "redis://redis:6379",
});

fastify.register(cors, {
  origin: "https://app.localhost",
  methods: ["GET", "POST", "PUT", "DELETE"],
  credentials: true,
});

fastify.addHook("onReady", async () => {
  const init = await fastify.redis.get("visits");

  if (init === null) {
    await fastify.redis.set("visits", 0);
  }
});

const transporter = nodemailer.createTransport({
  host: process.env.MAIL_HOST || "mailhog",
  port: parseInt(process.env.PORT_SMTP || "1025", 10),
  secure: false,
  auth: process.env.MAIL_USER
    ? {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS,
      }
    : undefined,
});

// Declare a route
fastify.get("/", function (request, reply) {
  reply.send({ hello: "world" });
});

//healthcheck
fastify.get("/health", function (request: any, reply: any) {
  const healthcheck = {
    uptime: process.uptime(),
    message: "OK",
    timestamp: Date.now(),
  };
  try {
    reply.send(healthcheck);
  } catch (e: any) {
    healthcheck.message = e;
    reply.status(503).send();
  }
});

//Test DB - Connection status
fastify.get("/db", function (request: any, reply: any) {
  fastify.pg.query(
    `SELECT NOW() as current_time, version() as postgres_version`,
    function onResult(err: any, result: any) {
      if (err) {
        reply.status(503).send({
          status: "disconnected",
          error: err.message,
          timestamp: new Date(),
        });
      } else {
        reply.send({
          status: "connected",
          data: result.rows[0],
          timestamp: new Date(),
        });
      }
    },
  );
});

//Test Redis - PING
fastify.get("/cache", async function (request: any, reply: any) {
  try {
    const pong = await fastify.redis.ping();
    reply.send({
      status: "connected",
      message: pong,
      timestamp: new Date(),
    });
  } catch (err: any) {
    reply.status(503).send({
      status: "disconnected",
      error: err.message,
      timestamp: new Date(),
    });
  }
});

fastify.get("/cache/visits", async function (request: any, reply: any) {
  try {
    const visits = await fastify.redis.get("visits");
    const updateVistis = parseInt(visits!) + 1;
    await fastify.redis.set("visits", updateVistis);
    reply.status(200).send({
      visits: updateVistis,
    });
  } catch (e) {
    reply.status(500).send({
      error: e,
    });
  }
});

//Contact form endpoint
fastify.post<{ Body: any }>(
  "/contact",
  async function (request: any, reply: any) {
    try {
      const { email, name, content } = request.body;

      if (!email || !name || !content) {
        return reply.status(400).send({
          status: "error",
          message: "Missing required fields: name, email, message",
        });
      }

      const mailOptions = {
        from: email || process.env.MAIL_FROM || "noreply@cloudnative.dev",
        to: process.env.MAIL_TO || "contact@cloudnative.dev",
        subject: `Nouveau message de contact de ${name}`,
        text: content,
        html: `
        <h2>Nouveau message de contact</h2>
        <p><strong>Nom:</strong> ${name}</p>
        <p><strong>Email:</strong> ${email}</p>
        <p><strong>Message:</strong></p>
        <p>${content.replace(/\n/g, "<br>")}</p>
      `,
      };

      // Email send
      const info = await transporter.sendMail(mailOptions);
      console.log("Email sent:", info.response);

      await fastify.pg.query(
        `INSERT INTO contact (sender, recipient, subject, content, created_at) VALUES ($1, $2, $3, $4, NOW())`,
        [
          email,
          "contact@cloudnative.dev",
          `Nouveau message de contact de ${name}`,
          content,
        ],
      );

      return reply.status(200).send({
        status: "success",
        message: "Message sent and saved successfully",
        messageId: info.messageId,
      });
    } catch (error: any) {
      console.error("Error:", error);
      return reply.status(500).send({
        status: "error",
        message: "An error occurred",
        error: error.message,
      });
    }
  },
);

// Run the server!
fastify.listen({ port: 3000, host: "0.0.0.0" }, function (err, address) {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
  console.log(`Serveur prêt sur : ${address}`);
});
