'use client';

import { useEffect, useState } from 'react';

const options = [
  { key: 'light', label: 'Sáng', icon: '☀️' },
  { key: 'dark', label: 'Tối', icon: '🌙' },
  { key: 'system', label: 'Máy', icon: '💻' },
];

export default function ThemeToggle() {
  const [theme, setTheme] = useState('system');

  useEffect(() => {
    const saved = localStorage.getItem('devops-handbook-theme') || 'system';
    setTheme(saved);
    document.documentElement.dataset.theme = saved;
  }, []);

  function changeTheme(nextTheme) {
    setTheme(nextTheme);
    localStorage.setItem('devops-handbook-theme', nextTheme);
    document.documentElement.dataset.theme = nextTheme;
  }

  return (
    <div className="theme-control" aria-label="Chọn giao diện sáng tối">
      {options.map((option) => (
        <button
          type="button"
          key={option.key}
          className={theme === option.key ? 'active' : ''}
          onClick={() => changeTheme(option.key)}
          title={`Giao diện ${option.label.toLowerCase()}`}
        >
          <span>{option.icon}</span>
          <small>{option.label}</small>
        </button>
      ))}
    </div>
  );
}
