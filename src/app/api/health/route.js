import { query } from '@/lib/db';

export async function GET() {
  try {
    await query('SELECT 1');
    return Response.json({ status: 'ok', database: 'ok' });
  } catch (error) {
    console.error(error);
    return Response.json({ status: 'error', database: 'down' }, { status: 503 });
  }
}
