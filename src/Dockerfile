FROM node:12

WORKDIR /opt/app

COPY * ./

RUN npm test && npm install

ENTRYPOINT npm start