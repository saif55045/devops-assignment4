const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// ─── Middleware ─────────────────────────────
app.use(cors());
app.use(helmet());
app.use(express.json());
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined'));
}

// ─── In-memory data store ──────────────────
let items = [
  { id: 1, name: 'Item One', status: 'active' },
  { id: 2, name: 'Item Two', status: 'active' },
  { id: 3, name: 'Item Three', status: 'inactive' }
];
let nextId = 4;

// ─── Helper Functions ──────────────────────
function findItemById(id) {
  return items.find(item => item.id === parseInt(id));
}

function validateItemInput(body) {
  const errors = [];
  if (!body.name || typeof body.name !== 'string' || body.name.trim().length === 0) {
    errors.push('name is required and must be a non-empty string');
  }
  if (body.status && !['active', 'inactive'].includes(body.status)) {
    errors.push('status must be either "active" or "inactive"');
  }
  return errors;
}

function formatUptime(seconds) {
  const hrs = Math.floor(seconds / 3600);
  const mins = Math.floor((seconds % 3600) / 60);
  const secs = Math.floor(seconds % 60);
  return `${hrs}h ${mins}m ${secs}s`;
}

// ─── Routes ────────────────────────────────

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: formatUptime(process.uptime()),
    hostname: os.hostname(),
    version: process.env.APP_VERSION || '1.0.0'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    message: 'DevOps Sample API',
    version: '1.0.0',
    endpoints: ['/health', '/api/items']
  });
});

// GET all items
app.get('/api/items', (req, res) => {
  const { status } = req.query;
  let result = items;
  if (status) {
    result = items.filter(item => item.status === status);
  }
  res.status(200).json({ count: result.length, items: result });
});

// GET single item by ID
app.get('/api/items/:id', (req, res) => {
  const item = findItemById(req.params.id);
  if (!item) {
    return res.status(404).json({ error: 'Item not found' });
  }
  res.status(200).json(item);
});

// POST create new item
app.post('/api/items', (req, res) => {
  const errors = validateItemInput(req.body);
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }
  const newItem = {
    id: nextId++,
    name: req.body.name.trim(),
    status: req.body.status || 'active'
  };
  items.push(newItem);
  res.status(201).json(newItem);
});

// PUT update item
app.put('/api/items/:id', (req, res) => {
  const item = findItemById(req.params.id);
  if (!item) {
    return res.status(404).json({ error: 'Item not found' });
  }
  const errors = validateItemInput(req.body);
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }
  item.name = req.body.name.trim();
  item.status = req.body.status || item.status;
  res.status(200).json(item);
});

// DELETE item
app.delete('/api/items/:id', (req, res) => {
  const index = items.findIndex(item => item.id === parseInt(req.params.id));
  if (index === -1) {
    return res.status(404).json({ error: 'Item not found' });
  }
  const deleted = items.splice(index, 1)[0];
  res.status(200).json({ message: 'Item deleted', item: deleted });
});

// ─── 404 Handler ───────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// ─── Error Handler ─────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err.message);
  res.status(500).json({ error: 'Internal server error' });
});

// ─── Start Server ──────────────────────────
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = { app, findItemById, validateItemInput, formatUptime };
