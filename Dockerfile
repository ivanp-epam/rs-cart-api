# build essential node_modules
FROM node:lts-alpine AS production-modules
WORKDIR /app
COPY ./package*.json ./
RUN npm install --only=production && npm prune --production

# make build
FROM node:lts-alpine AS build
WORKDIR /app
# Copy package*.json files, install dependencies
COPY ./package*.json ./
COPY . .
# build application
RUN npm install && npm run build

# Release with Alpine
FROM node:lts-alpine AS release
WORKDIR /app
# Install app and dependencies
COPY --from=build /app/package.json ./
COPY --from=build /app/dist ./dist
COPY --from=production-modules /app/node_modules ./node_modules
USER node
EXPOSE 4000
ENTRYPOINT ["node", "dist/main.js"]