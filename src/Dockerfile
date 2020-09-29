FROM node:12 AS builder
COPY * ./
RUN npm test

FROM node:12
WORKDIR /opt/app
COPY --from=builder /index.js /package.json ./
ENTRYPOINT npm start
