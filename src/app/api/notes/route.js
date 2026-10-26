import { query } from '@/lib/db';

export const dynamic = 'force-dynamic';

const allowedDanger = new Set(['safe', 'caution', 'destructive']);
const allowedDifficulty = new Set(['beginner', 'intermediate']);

function normalize(body) {
  return {
    title: String(body.title ?? '').trim(),
    summary: String(body.summary ?? '').trim(),
    category: String(body.category ?? 'linux').trim(),
    difficulty: allowedDifficulty.has(body.difficulty) ? body.difficulty : 'beginner',
    danger_level: allowedDanger.has(body.danger_level) ? body.danger_level : 'safe',
    tags: Array.isArray(body.tags) ? body.tags.map((tag) => String(tag).trim()).filter(Boolean).slice(0, 20) : [],
    content: String(body.content ?? '').trim(),
    last_tested_at: body.last_tested_at || null,
  };
}

export async function GET(request) {
  const { searchParams } = new URL(request.url);
  const q = (searchParams.get('q') ?? '').trim();
  const category = (searchParams.get('category') ?? '').trim();

  const values = [];
  const conditions = [];

  if (category) {
    values.push(category);
    conditions.push(`category = $${values.length}`);
  }

  if (q) {
    values.push(`%${q}%`);
    const idx = values.length;
    conditions.push(`(
      title ILIKE $${idx}
      OR summary ILIKE $${idx}
      OR content ILIKE $${idx}
      OR array_to_string(tags, ' ') ILIKE $${idx}
    )`);
  }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const result = await query(`
    SELECT id, title, summary, category, difficulty, danger_level, tags, last_tested_at, created_at, updated_at
    FROM notes
    ${where}
    ORDER BY updated_at DESC
    LIMIT 200
  `, values);

  return Response.json({ notes: result.rows });
}

export async function POST(request) {
  try {
    const payload = normalize(await request.json());
    if (!payload.title || !payload.content) {
      return Response.json({ error: 'Tiêu đề và nội dung là bắt buộc.' }, { status: 400 });
    }

    const result = await query(`
      INSERT INTO notes (title, summary, category, difficulty, danger_level, tags, content, last_tested_at)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
      RETURNING id
    `, [
      payload.title,
      payload.summary,
      payload.category,
      payload.difficulty,
      payload.danger_level,
      payload.tags,
      payload.content,
      payload.last_tested_at,
    ]);

    return Response.json({ id: result.rows[0].id }, { status: 201 });
  } catch (error) {
    console.error(error);
    return Response.json({ error: 'Database error.' }, { status: 500 });
  }
}
