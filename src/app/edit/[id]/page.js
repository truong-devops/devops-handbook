import { notFound } from 'next/navigation';
import Link from 'next/link';
import { query } from '@/lib/db';
import NoteForm from '@/components/NoteForm';
import ThemeToggle from '@/components/ThemeToggle';

export const dynamic = 'force-dynamic';

export default async function EditNotePage({ params }) {
  const { id } = await params;
  if (!/^\d+$/.test(id)) notFound();
  const result = await query('SELECT * FROM notes WHERE id = $1', [id]);
  const note = result.rows[0];
  if (!note) notFound();

  return (
    <main className="document-page narrow">
      <div className="document-toolbar">
        <Link href={`/notes/${note.id}`} className="button">← Quay lại</Link>
        <div className="document-theme"><ThemeToggle /></div>
      </div>
      <p className="eyebrow">EDIT RUNBOOK</p>
      <h1>Sửa ghi chú</h1>
      <NoteForm note={note} />
    </main>
  );
}
