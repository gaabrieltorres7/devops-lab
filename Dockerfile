FROM node:20.17.0-alpine3.20 AS builder
WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npx prisma generate
RUN npm run build
RUN npm ci --omit=dev && npm cache clean --force
RUN npx prisma generate

FROM node:20.17.0-alpine3.20
WORKDIR /usr/src/app
COPY --from=builder --chown=node:node /usr/src/app/node_modules ./node_modules
COPY --from=builder --chown=node:node /usr/src/app/package.json ./package.json
COPY --from=builder --chown=node:node /usr/src/app/dist ./dist
COPY --from=builder --chown=node:node /usr/src/app/prisma ./prisma
USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]