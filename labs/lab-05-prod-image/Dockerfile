# Lab 05 — multi-stage production image. See README.md.
#
# TODO — build stage:
#   FROM node:22.13-bookworm-slim AS build
#   WORKDIR /app
#   COPY package*.json ./
#   RUN npm ci
#   COPY . .
#   RUN npm run build
#
# TODO — runtime stage:
#   FROM node:22.13-bookworm-slim AS runtime
#   WORKDIR /app
#   ENV NODE_ENV=production
#   COPY package*.json ./
#   RUN npm ci --omit=dev
#   COPY --from=build /app/dist ./dist
#   USER node
#   HEALTHCHECK ...
#   CMD ["node", "dist/server.js"]
#
# Bake NO secrets via ENV/ARG.
