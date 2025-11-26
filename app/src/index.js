require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || '1.0.0';
const ENVIRONMENT = process.env.NODE_ENV || 'development';

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('combined'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: ENVIRONMENT,
    version: VERSION,
    uptime: process.uptime()
  });
});

// Version endpoint
app.get('/version', (req, res) => {
  res.json({
    version: VERSION,
    environment: ENVIRONMENT,
    nodeVersion: process.version
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'DevOps & IaC Demo Application',
    version: VERSION,
    environment: ENVIRONMENT,
    endpoints: {
      health: '/health',
      version: '/version',
      api: '/api'
    }
  });
});

// Sample API endpoint
app.get('/api', (req, res) => {
  res.json({
    message: 'API is working',
    timestamp: new Date().toISOString()
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
    environment: ENVIRONMENT
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path
  });
});

// Start server
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📊 Environment: ${ENVIRONMENT}`);
    console.log(`📦 Version: ${VERSION}`);
    console.log(`🏥 Health check: http://localhost:${PORT}/health`);
  });
}

module.exports = app;
