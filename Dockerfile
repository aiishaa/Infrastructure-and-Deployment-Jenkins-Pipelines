FROM node:carbon
WORKDIR /app
COPY . ./nodeapp
RUN npm install
EXPOSE 3000
CMD [ "node", "nodeapp/app.js" ]
