FROM node:14-alpine
WORKDIR /usr/src/app
COPY package*.json ./it
RUN npm ci --production
COPY . .
EXPOSE 8080
CMD [ "node", "index.js" ]