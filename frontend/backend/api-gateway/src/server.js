const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const { createProxyMiddleware } = require('http-proxy-middleware');

dotenv.config();

const app = express();
const port = process.env.PORT || 8080;

app.use(cors());
app.use(morgan('dev'));

app.get('/', (_req, res) => {
  res.json({
    name: 'ChefInPocket API Gateway',
    status: 'ok',
    services: [
      '/api/auth',
      '/api/recipes',
      '/api/pantry',
      '/api/community',
      '/api/assistant'
    ]
  });
});

app.get('/health', (_req, res) => {
  res.json({ service: 'api-gateway', status: 'healthy' });
});

const buildProxy = (target) =>
  createProxyMiddleware({
    target,
    changeOrigin: true,
    logLevel: 'warn'
  });

app.use('/api/auth', buildProxy(process.env.AUTH_SERVICE_URL || 'http://localhost:5001'));
app.use('/api/recipes', buildProxy(process.env.RECIPE_SERVICE_URL || 'http://localhost:5002'));
app.use('/api/pantry', buildProxy(process.env.PANTRY_SERVICE_URL || 'http://localhost:5003'));
app.use('/api/community', buildProxy(process.env.COMMUNITY_SERVICE_URL || 'http://localhost:5004'));
app.use('/api/assistant', buildProxy(process.env.ASSISTANT_SERVICE_URL || 'http://localhost:5005'));

app.listen(port, () => {
  console.log(`API Gateway is running on port ${port}`);
});
