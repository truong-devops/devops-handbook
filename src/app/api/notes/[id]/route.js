import { query } from '@/lib/db';

const allowedDanger = new Set(['safe', 'caution', 'destructive']);
const allowedDifficulty = new Set(['beginner', 'intermediate']);

function validId(id) {
  return /^\d+$/.test(id);
}

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

export async function GET(_request, { params }) {
  const { id } = await params;
  if (!validId(id)) return Response.json({ error: 'Invalid id.' }, { status: 400 });
  const result = await query('SELECT * FROM notes WHERE id = $1', [id]);
  if (!result.rows[0]) return Response.json({ error: 'Not found.' }, { status: 404 });
  return Response.json(result.rows[0]);
}

export async function PUT(request, { params }) {
  const { id } = await params;
  if (!validId(id)) return Response.json({ error: 'Invalid id.' }, { status: 400 });

  const payload = normalize(await request.json());
  if (!payload.title || !payload.content) {
    return Response.json({ error: 'Tiêu đề và nội dung là bắt buộc.' }, { status: 400 });
  }

  const result = await query(`
    UPDATE notes
    SET title=$1, summary=$2, category=$3, difficulty=$4, danger_level=$5,
        tags=$6, content=$7, last_tested_at=$8, updated_at=NOW()
    WHERE id=$9
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
    id,
  ]);

  if (!result.rows[0]) return Response.json({ error: 'Not found.' }, { status: 404 });
  return Response.json({ id: result.rows[0].id });
}

export async function DELETE(_request, { params }) {
  const { id } = await params;
  if (!validId(id)) return Response.json({ error: 'Invalid id.' }, { status: 400 });
  const result = await query('DELETE FROM notes WHERE id = $1 RETURNING id', [id]);
  if (!result.rows[0]) return Response.json({ error: 'Not found.' }, { status: 404 });
  return Response.json({ ok: true });
}
