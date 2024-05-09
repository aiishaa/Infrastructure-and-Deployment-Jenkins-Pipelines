FROM node:12
WORKDIR /app
COPY . .
WORKDIR nodeapp
RUN npm install
EXPOSE 3000
CMD [ "node", "app.js" ]
