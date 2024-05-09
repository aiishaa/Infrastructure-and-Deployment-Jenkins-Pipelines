const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 3000;

const connection = mysql.createConnection({
  host: process.env.RDS_HOSTNAME,
  user: process.env.RDS_USERNAME,
  password: process.env.RDS_PASSWORD,
  port: process.env.RDS_PORT
});

connection.connect((err) => {
  if (err) {
    console.error('Database connection failed: ' + err.stack);
    return;
  }
  console.log('Connected to database.');
});

app.get("/db", (req, res) => {
  // Handle requests here without attempting to connect to the database
  res.send("db connection successful");
});

const redis = require('redis');
const client = redis.createClient({
    host: process.env.REDIS_HOSTNAME,
    port: process.env.REDIS_PORT,
});

client.on('error', err => {
    console.log('Error ' + err);
});

app.get('/redis', (req, res) => {

  client.set('foo','bar', (error, rep)=> {                
    if(error){     
console.log(error);
      res.send("redis connection failed");                             
      return;                
  }                 
  if(rep){                          //JSON objects need to be parsed after reading from redis, since it is stringified before being stored into cache                      
 console.log(rep);
  res.send("redis is successfuly connected");                 
 }}) 
  })
  
  app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
  })
