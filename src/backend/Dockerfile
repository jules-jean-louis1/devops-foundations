# ----------------------------
# 1. BASE :
# ----------------------------
FROM node:20-bullseye-slim AS base
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/app
RUN chown node:node /usr/src/app

# ----------------------------
# 2. DEVELOPMENT :
# ----------------------------
FROM base AS development
ENV NODE_ENV development
USER node
COPY --chown=node:node package*.json ./
RUN npm install
COPY --chown=node:node . .
EXPOSE 3000
CMD ["dumb-init", "npm", "run", "dev"]

# ----------------------------
# 3. BUILD :
# ----------------------------
FROM development AS build
RUN npm run build
RUN npm prune --production

# ----------------------------
# 4. PRODUCTION
# ----------------------------
FROM node:20-bullseye-slim AS production
ENV NODE_ENV production
RUN apt-get update && apt-get install -y --no-install-recommends dumb-init && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
USER node

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist
COPY --chown=node:node --from=build /usr/src/app/package.json ./

EXPOSE 3000
# On lance directement le JS compilé, c'est beaucoup plus rapide
CMD ["dumb-init", "node", "dist/main.js"]
