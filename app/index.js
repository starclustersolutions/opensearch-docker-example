// Simple Express app that generates various log types
const express = require('express');
const app = express();
const port = 3000;

// Middleware to log all requests
app.use((req, res, next) => {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    level: 'info',
    method: req.method,
    path: req.path,
    ip: req.ip,
    userAgent: req.get('user-agent')
  }));
  next();
});

app.get('/', (req, res) => {
  res.json({ message: 'Hello World!' });
});

app.get('/error', (req, res) => {
  console.error(JSON.stringify({
    timestamp: new Date().toISOString(),
    level: 'error',
    message: 'This is a simulated error',
    errorCode: 'ERR_SIMULATED'
  }));
  res.status(500).json({ error: 'Simulated error' });
});

app.get('/warn', (req, res) => {
  console.warn(JSON.stringify({
    timestamp: new Date().toISOString(),
    level: 'warn',
    message: 'This is a warning message',
    context: 'performance degradation detected'
  }));
  res.json({ warning: 'Check logs' });
});

// Generate periodic logs
setInterval(() => {
  const logTypes = ['info', 'debug', 'warn'];
  const randomType = logTypes[Math.floor(Math.random() * logTypes.length)];
  
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    level: randomType,
    message: `Periodic log message - ${randomType}`,
    metric: Math.random() * 100,
    service: 'example-app'
  }));
}, 5000);

app.listen(port, () => {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    level: 'info',
    message: `Example app listening on port ${port}`,
    service: 'example-app'
  }));
});