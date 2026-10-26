'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import Sidebar from './Sidebar';
import CategoryGuide from './CategoryGuide';
import { getCategory } from '@/lib/categories';

const dangerLabels = {
  safe: 'SAFE',
  caution: 'CAUTION',
  destructive: 'DESTRUCTIVE',
};

export default function Dashboard() {
  const [notes, setNotes] = useState([]);
  const [query, setQuery] = useState('');
  const [debouncedQuery, setDebouncedQuery] = useState('');
  const [category, setCategory] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedQuery(query), 250);
    return () => clearTimeout(timer);
  }, [query]);

  useEffect(() => {
    const controller = new AbortController();
    const params = new URLSearchParams();
    if (debouncedQuery) params.set('q', debouncedQuery);
    if (category) params.set('category', category);

    setLoading(true);
    fetch(`/api/notes?${params.toString()}`, { signal: controller.signal })
      .then((response) => response.json())
      .then((data) => setNotes(data.notes ?? []))
      .catch((error) => {
        if (error.name !== 'AbortError') console.error(error);
      })
      .finally(() => setLoading(false));

    return () => controller.abort();
  }, [debouncedQuery, category]);

  const heading = useMemo(() => {
    if (!category) return 'Tất cả ghi chú';
    return getCategory(category).label;
  }, [category]);

  return (
    <div className="app-shell">
      <Sidebar activeCategory={category} onCategoryChange={setCategory} />

      <main className="main-content">
        <header className="topbar">
          <div>
            <p className="eyebrow">SỔ TAY DEVOPS CÁ NHÂN</p>
            <h1>{heading}</h1>
          </div>
          <Link className="button primary" href="/new">+ Ghi chú mới</Link>
        </header>

        <section className="hero-card">
          <div>
            <h2>Hôm nay bạn muốn kiểm tra lệnh gì?</h2>
            <p>Search theo task, command, tag hoặc lỗi bạn từng gặp.</p>
          </div>
          <input
            className="search-input"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Ví dụ: nginx -t, disk full, kubectl logs..."
            aria-label="Tìm ghi chú"
          />
        </section>

        {category && <CategoryGuide category={category} />}

        <div className="section-header">
          <div>
            <h2>{loading ? 'Đang tải...' : `${notes.length} ghi chú`}</h2>
            <p>Mở một bài để xem quy trình, command và phần verify.</p>
          </div>
        </div>

        {!loading && notes.length === 0 ? (
          <div className="empty-state">
            <h3>Chưa tìm thấy ghi chú</h3>
            <p>Thử từ khóa khác hoặc tạo note mới cho task này.</p>
          </div>
        ) : (
          <div className="note-grid">
            {notes.map((note) => {
              const itemCategory = getCategory(note.category);
              return (
                <Link href={`/notes/${note.id}`} className="note-card" key={note.id}>
                  <div className="note-card-top">
                    <span className="category-pill">{itemCategory.icon} {itemCategory.label}</span>
                    <span className={`danger-pill ${note.danger_level}`}>{dangerLabels[note.danger_level]}</span>
                  </div>
                  <h3>{note.title}</h3>
                  <p>{note.summary || 'Chưa có mô tả ngắn.'}</p>
                  <div className="tag-row">
                    {(note.tags ?? []).slice(0, 4).map((tag) => <span key={tag}>#{tag}</span>)}
                  </div>
                  <div className="note-meta">
                    <span>{note.difficulty === 'beginner' ? '🌱 Beginner' : '🧩 Intermediate'}</span>
                    <span>Updated {new Date(note.updated_at).toLocaleDateString('vi-VN')}</span>
                  </div>
                </Link>
              );
            })}
          </div>
        )}
      </main>
    </div>
  );
}
