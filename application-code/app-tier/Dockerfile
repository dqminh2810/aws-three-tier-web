FROM node:16-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install && npm install pm2 -g
COPY . .
EXPOSE 4000
CMD [ "pm2-runtime", "index.js" ]