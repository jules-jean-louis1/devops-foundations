// ESM
import Fastify from "fastify";

const fastify = Fastify({
  logger: true,
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

//Test DB
fastify.get("/db", function (request: any, reply: any) {});

fastify.get("/cache", function (request: any, reply: any) {});

fastify.get("/contact", function (request: any, reply: any) {});

// Run the server!
fastify.listen({ port: 3000 }, function (err, address) {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
  // Server is now listening on ${address}
});
