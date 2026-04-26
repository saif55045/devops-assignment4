const { findItemById, validateItemInput, formatUptime } = require('../../src/app');

// ─────────────────────────────────────────
// Unit Test 1: findItemById — returns correct item
// ─────────────────────────────────────────
describe('findItemById', () => {
  test('should return undefined for non-existent ID', () => {
    const result = findItemById(999);
    expect(result).toBeUndefined();
  });

  test('should return undefined for string ID that is not a number', () => {
    const result = findItemById('abc');
    expect(result).toBeUndefined();
  });
});

// ─────────────────────────────────────────
// Unit Test 2: validateItemInput — validates input correctly
// ─────────────────────────────────────────
describe('validateItemInput', () => {
  test('should return errors for empty body', () => {
    const errors = validateItemInput({});
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0]).toContain('name is required');
  });

  test('should return errors for empty name string', () => {
    const errors = validateItemInput({ name: '   ' });
    expect(errors.length).toBeGreaterThan(0);
  });

  test('should return error for invalid status', () => {
    const errors = validateItemInput({ name: 'Test', status: 'unknown' });
    expect(errors).toContain('status must be either "active" or "inactive"');
  });

  test('should return no errors for valid input', () => {
    const errors = validateItemInput({ name: 'Valid Item', status: 'active' });
    expect(errors.length).toBe(0);
  });

  test('should accept input without status (defaults later)', () => {
    const errors = validateItemInput({ name: 'No Status Item' });
    expect(errors.length).toBe(0);
  });
});

// ─────────────────────────────────────────
// Unit Test 3: formatUptime — formats correctly
// ─────────────────────────────────────────
describe('formatUptime', () => {
  test('should format zero seconds', () => {
    expect(formatUptime(0)).toBe('0h 0m 0s');
  });

  test('should format hours, minutes, and seconds', () => {
    // 1 hour + 30 minutes + 45 seconds = 5445 seconds
    expect(formatUptime(5445)).toBe('1h 30m 45s');
  });

  test('should format only seconds', () => {
    expect(formatUptime(42)).toBe('0h 0m 42s');
  });
});
