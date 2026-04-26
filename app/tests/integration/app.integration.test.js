const request = require('supertest');
const { app } = require('../../src/app');

// ─────────────────────────────────────────
// Integration Test 1: Health endpoint
// ─────────────────────────────────────────
describe('GET /health', () => {
  test('should return 200 with health status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('healthy');
    expect(res.body).toHaveProperty('timestamp');
    expect(res.body).toHaveProperty('uptime');
    expect(res.body).toHaveProperty('hostname');
  });
});

// ─────────────────────────────────────────
// Integration Test 2: Root endpoint
// ─────────────────────────────────────────
describe('GET /', () => {
  test('should return 200 with API info', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe('DevOps Sample API');
    expect(res.body.endpoints).toContain('/health');
  });
});

// ─────────────────────────────────────────
// Integration Test 3: CRUD operations on /api/items
// ─────────────────────────────────────────
describe('Items API', () => {
  test('GET /api/items should return list of items', async () => {
    const res = await request(app).get('/api/items');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('count');
    expect(res.body).toHaveProperty('items');
    expect(Array.isArray(res.body.items)).toBe(true);
  });

  test('GET /api/items?status=active should filter items', async () => {
    const res = await request(app).get('/api/items?status=active');
    expect(res.statusCode).toBe(200);
    res.body.items.forEach(item => {
      expect(item.status).toBe('active');
    });
  });

  test('POST /api/items should create a new item', async () => {
    const res = await request(app)
      .post('/api/items')
      .send({ name: 'Integration Test Item', status: 'active' });
    expect(res.statusCode).toBe(201);
    expect(res.body.name).toBe('Integration Test Item');
    expect(res.body).toHaveProperty('id');
  });

  test('POST /api/items should reject invalid input', async () => {
    const res = await request(app)
      .post('/api/items')
      .send({ name: '', status: 'bad' });
    expect(res.statusCode).toBe(400);
    expect(res.body).toHaveProperty('errors');
  });

  test('GET /api/items/:id should return 404 for non-existent item', async () => {
    const res = await request(app).get('/api/items/99999');
    expect(res.statusCode).toBe(404);
  });

  test('PUT /api/items/:id should update an existing item', async () => {
    const res = await request(app)
      .put('/api/items/1')
      .send({ name: 'Updated Item', status: 'inactive' });
    expect(res.statusCode).toBe(200);
    expect(res.body.name).toBe('Updated Item');
    expect(res.body.status).toBe('inactive');
  });

  test('DELETE /api/items/:id should delete an item', async () => {
    // First create an item to delete
    const createRes = await request(app)
      .post('/api/items')
      .send({ name: 'To Delete', status: 'active' });
    const deleteRes = await request(app).delete(`/api/items/${createRes.body.id}`);
    expect(deleteRes.statusCode).toBe(200);
    expect(deleteRes.body.message).toBe('Item deleted');
  });

  test('GET unknown route should return 404', async () => {
    const res = await request(app).get('/unknown/route');
    expect(res.statusCode).toBe(404);
  });
});
