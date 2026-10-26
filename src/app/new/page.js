import Link from 'next/link';
import NoteForm from '@/components/NoteForm';
import ThemeToggle from '@/components/ThemeToggle';

export default function NewNotePage() {
  return (
    <main className="document-page narrow">
      <div className="document-toolbar">
        <Link href="/" className="button">← Dashboard</Link>
        <div className="document-theme"><ThemeToggle /></div>
      </div>
      <p className="eyebrow">NEW RUNBOOK</p>
      <h1>Ghi lại task vừa làm</h1>
      <p className="lead">Viết để 3 tháng sau chính bạn vẫn hiểu: làm gì, tại sao, verify ra sao và rollback thế nào.</p>
      <NoteForm />
    </main>
  );
}
