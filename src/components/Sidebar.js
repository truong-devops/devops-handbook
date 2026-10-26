'use client';

import Link from 'next/link';
import { categories } from '@/lib/categories';
import ThemeToggle from './ThemeToggle';

export default function Sidebar({ activeCategory, onCategoryChange }) {
  return (
    <aside className="sidebar">
      <Link href="/" className="brand">
        <span className="brand-mark">&gt;_</span>
        <span>
          <strong>DevOps Handbook</strong>
          <small>Learn · Runbook · Commands</small>
        </span>
      </Link>

      <nav className="nav-list" aria-label="Danh mục">
        <button
          type="button"
          className={`nav-item ${activeCategory === '' ? 'active' : ''}`}
          onClick={() => onCategoryChange('')}
        >
          <span>📚</span> Tất cả ghi chú
        </button>
        {categories.map((category) => (
          <button
            type="button"
            key={category.key}
            className={`nav-item ${activeCategory === category.key ? 'active' : ''}`}
            onClick={() => onCategoryChange(category.key)}
          >
            <span>{category.icon}</span> {category.label}
          </button>
        ))}
      </nav>

      <div className="sidebar-bottom">
        <div className="theme-box">
          <strong>Giao diện</strong>
          <ThemeToggle />
        </div>
        <div className="sidebar-tip">
          <strong>Quy tắc của sổ tay</strong>
          <p>Mỗi task nên có: mục đích → lệnh → verify → rollback → lỗi thường gặp.</p>
        </div>
      </div>
    </aside>
  );
}
