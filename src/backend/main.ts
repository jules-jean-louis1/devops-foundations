// ESM
import Fastify from "fastify";
import postgres from "@fastify/postgres";
import redis from "@fastify/redis";
import nodemailer from "nodemailer";

const fastify = Fastify({
  logger: true,
});

fastify.register(postgres, {
  connectionString: process.env.DATABASE_URL,
});

fastify.register(redis, {
  url: process.env.REDIS_URL || "redis://redis:6379",
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

//Contact form endpoint
fastify.post<{ Body: any }>(
  "/contact",
  async function (request: any, reply: any) {
    try {
      const { name, email, message, recipient_email } = request.body;

      if (!name || !email || !message) {
        return reply.status(400).send({
          status: "error",
          message: "Missing required fields: name, email, message",
        });
      }

      const mailOptions = {
        from: process.env.MAIL_FROM || "noreply@cloudnative.dev",
        to: recipient_email || process.env.MAIL_TO || "contact@cloudnative.dev",
        replyTo: email,
        subject: `Nouveau message de contact de ${name}`,
        text: message,
        html: `
        <h2>Nouveau message de contact</h2>
        <p><strong>Nom:</strong> ${name}</p>
        <p><strong>Email:</strong> ${email}</p>
        <p><strong>Message:</strong></p>
        <p>${message.replace(/\n/g, "<br>")}</p>
      `,
      };

      try {
        const info = await transporter.sendMail(mailOptions);
        console.log("Email sent:", info.response);
        reply.status(200).send({
          status: "success",
          message: "Email sent successfully",
          messageId: info.messageId,
        });
      } catch (error: any) {
        console.error("Email error:", error);
        reply.status(500).send({
          status: "error",
          message: "Failed to send email",
          error: error.message,
        });
      }
    } catch (err: any) {
      reply.status(500).send({
        status: "error",
        message: "Server error",
        error: err.message,
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
