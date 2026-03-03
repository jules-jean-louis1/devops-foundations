FROM node:22-bullseye-slim AS base
LABEL \
    org.opencontainers.image.title="frontend_cloudnative"\
    org.opencontainers.image.source="https://github.com/jules-jean-louis1/devops-foundations/src/frontend/" \
    org.opencontainers.image.licences="MIT"
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/app
RUN chown node:node /usr/src/app

FROM base AS development
LABEL \
    org.opencontainers.image.version="1.0" \
    org.opencontainers.image.ref.name="dev"
ENV NODE_ENV=development
USER node
COPY --chown=node:node package*.json ./
RUN npm install
COPY --chown=node:node . .
RUN npx svelte-kit sync
EXPOSE 3001
CMD [ "dumb-init", "npm", "run", "dev" ]

FROM development AS build
RUN npm run build
RUN npm prune --production

FROM node:22-alpine AS production
LABEL \
    org.opencontainers.image.version="1.0" \
    org.opencontainers.image.ref.name="prod"
ENV NODE_ENV=production
RUN apk add --no-cache dumb-init

WORKDIR /usr/src/app
USER node

COPY --chown=node:node --from=build /usr/src/app/.svelte-kit/output/server ./server
COPY --chown=node:node --from=build /usr/src/app/.svelte-kit/output/client ./client
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/package.json ./


EXPOSE 3001
CMD ["dumb-init", "node", "./server/index.js"]
