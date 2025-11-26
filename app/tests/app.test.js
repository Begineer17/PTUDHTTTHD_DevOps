const request = require('supertest');
const app = require('../src/index');

describe('Application Tests', () => {
  describe('GET /health', () => {
    it('should return healthy status', async () => {
      const res = await request(app).get('/health');
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('status', 'healthy');
      expect(res.body).toHaveProperty('timestamp');
      expect(res.body).toHaveProperty('environment');
      expect(res.body).toHaveProperty('version');
    });
  });

  describe('GET /version', () => {
    it('should return version information', async () => {
      const res = await request(app).get('/version');
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('version');
      expect(res.body).toHaveProperty('environment');
      expect(res.body).toHaveProperty('nodeVersion');
    });
  });

  describe('GET /', () => {
    it('should return welcome message', async () => {
      const res = await request(app).get('/');
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('message');
      expect(res.body).toHaveProperty('endpoints');
    });
  });

  describe('GET /api', () => {
    it('should return API response', async () => {
      const res = await request(app).get('/api');
      
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('message', 'API is working');
      expect(res.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /nonexistent', () => {
    it('should return 404 for unknown routes', async () => {
      const res = await request(app).get('/nonexistent');
      
      expect(res.status).toBe(404);
      expect(res.body).toHaveProperty('error', 'Not Found');
    });
  });
});
