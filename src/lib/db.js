import pg from 'pg';

const { Pool } = pg;

const globalForPg = globalThis;

export const pool = globalForPg.__devopsHandbookPool ?? new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
  idleTimeoutMillis: 30000,
});

if (process.env.NODE_ENV !== 'production') {
  globalForPg.__devopsHandbookPool = pool;
}

export async function query(text, params = []) {
  return pool.query(text, params);
}
