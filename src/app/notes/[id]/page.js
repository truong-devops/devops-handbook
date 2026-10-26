import { notFound } from 'next/navigation';
import Link from 'next/link';
import { query } from '@/lib/db';
import { getCategory } from '@/lib/categories';
import MarkdownRenderer from '@/components/MarkdownRenderer';
import DeleteButton from '@/components/DeleteButton';
import ThemeToggle from '@/components/ThemeToggle';

export const dynamic = 'force-dynamic';

export default async function NotePage({ params }) {
  const { id } = await params;
  if (!/^\d+$/.test(id)) notFound();

  const result = await query('SELECT * FROM notes WHERE id = $1', [id]);
  const note = result.rows[0];
  if (!note) notFound();

  const category = getCategory(note.category);

  return (
    <main className="document-page">
      <div className="document-toolbar">
        <Link href="/" className="button">← Dashboard</Link>
        <div className="toolbar-actions">
          <div className="document-theme"><ThemeToggle /></div>
          <Link href={`/edit/${note.id}`} className="button">Sửa</Link>
          <DeleteButton id={note.id} />
        </div>
      </div>

      <div className="note-heading">
        <div className="note-card-top">
          <span className="category-pill">{category.icon} {category.label}</span>
          <span className={`danger-pill ${note.danger_level}`}>{note.danger_level.toUpperCase()}</span>
        </div>
        <h1>{note.title}</h1>
        <p className="lead">{note.summary}</p>
        <div className="tag-row large">
          {(note.tags ?? []).map((tag) => <span key={tag}>#{tag}</span>)}
        </div>
        <div className="note-meta detail">
          <span>{note.difficulty === 'beginner' ? '🌱 Beginner' : '🧩 Intermediate'}</span>
          <span>Updated {new Date(note.updated_at).toLocaleString('vi-VN')}</span>
          {note.last_tested_at && <span>✅ Tested {new Date(note.last_tested_at).toLocaleDateString('vi-VN')}</span>}
        </div>
      </div>

      <MarkdownRenderer content={note.content} />
    </main>
  );
}
