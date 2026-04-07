# ----------------------------
# 1. BASE
# ----------------------------
FROM node:20-bullseye-slim AS base
LABEL \
    org.opencontainers.image.title="api_cloudnative"\
    org.opencontainers.image.source="https://github.com/jules-jean-louis1/devops-foundations/" \
    org.opencontainers.image.licences="MIT"
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/app
RUN chown node:node /usr/src/app

# ----------------------------
# 2. DEVELOPMENT
# ----------------------------
FROM base AS development
LABEL \
    org.opencontainers.image.version="1.0" \
    org.opencontainers.image.ref.name="dev"
ENV NODE_ENV=development
USER node
COPY --chown=node:node package*.json ./
RUN npm ci
COPY --chown=node:node . .
EXPOSE 3002
CMD ["dumb-init", "npm", "run", "dev"]

# ----------------------------
# 3. BUILD
# ----------------------------
FROM development AS build
RUN npm run build
RUN npm prune --production

# ----------------------------
# 4. PRODUCTION
# ----------------------------
FROM node:20-alpine AS production
LABEL \
    org.opencontainers.image.version="1.0" \
    org.opencontainers.image.ref.name="prod"
ENV NODE_ENV=production
RUN apk add --no-cache dumb-init

WORKDIR /usr/src/app
USER node

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist
COPY --chown=node:node --from=build /usr/src/app/package.json ./

EXPOSE 3002
CMD ["dumb-init", "node", "dist/main.js"]
