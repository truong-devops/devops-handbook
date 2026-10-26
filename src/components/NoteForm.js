'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { categories } from '@/lib/categories';

const starterTemplate = `## 🎯 Mục đích
Mô tả ngắn ghi chú này dùng để làm gì.

## 📋 Trước khi làm
- Kiểm tra môi trường
- Backup nếu thao tác có rủi ro

## 1. Kiểm tra hiện trạng

\`\`\`bash
# command kiểm tra
\`\`\`

## 2. Thực hiện

\`\`\`bash
# command thực hiện
\`\`\`

## ✅ Verify

\`\`\`bash
# command xác nhận kết quả
\`\`\`

## ↩️ Rollback
Ghi rõ cách quay lại trạng thái cũ.

## 🐛 Troubleshooting
- Lỗi thường gặp
- Log cần xem

## 🧠 Mình học được gì?
Giải thích lại bằng lời của mình để lần sau nhớ lâu hơn.
`;

const taskTemplate = `## 🎫 Thông tin Task

**Ticket:**  
**Ngày thực hiện:**  
**Environment:** DEV / QA / UAT / PROD  
**Server / Cluster:**  
**Người yêu cầu:**  

---

## 🎯 Mục tiêu

Task này cần làm gì?

---

## 🔎 Hiện trạng trước khi làm

Kiểm tra hệ thống trước khi thay đổi.

\`\`\`bash
# command kiểm tra
\`\`\`

**Kết quả:**

---

## 💾 Backup / Snapshot

Có cần backup không? Nếu không cần, ghi rõ lý do.

\`\`\`bash
# command backup nếu có
\`\`\`

---

## 🛠️ Các bước thực hiện

### Bước 1

Mô tả việc cần làm.

\`\`\`bash
# command
\`\`\`

### Bước 2

\`\`\`bash
# command
\`\`\`

---

## ✅ Verify

Kiểm tra sau khi thực hiện.

\`\`\`bash
# command verify
\`\`\`

**Expected result:**

---

## ↩️ Rollback

Nếu có vấn đề thì quay lại như thế nào?

\`\`\`bash
# rollback command
\`\`\`

---

## 🐛 Lỗi gặp phải

### Lỗi

\`\`\`text
error message
\`\`\`

### Nguyên nhân

...

### Cách xử lý

...

---

## 📌 Kết quả Task

- [ ] Task hoàn thành
- [ ] Service hoạt động bình thường
- [ ] Đã verify
- [ ] Không có alert bất thường

---

## 🧠 Mình học được gì?

Giải thích lại bằng lời của mình.

## 🔐 Lưu ý

Không lưu password, token, private key hoặc secret thật vào note.
`;

export default function NoteForm({ note }) {
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({
    title: note?.title ?? '',
    summary: note?.summary ?? '',
    category: note?.category ?? 'task',
    difficulty: note?.difficulty ?? 'beginner',
    danger_level: note?.danger_level ?? 'safe',
    tags: note?.tags?.join(', ') ?? '',
    last_tested_at: note?.last_tested_at ? String(note.last_tested_at).slice(0, 10) : '',
    content: note?.content ?? taskTemplate,
  });

  function update(field, value) {
    setForm((current) => ({ ...current, [field]: value }));
  }

  function changeCategory(value) {
    setForm((current) => {
      let content = current.content;

      if (!note) {
        if (value === 'task' && current.content === starterTemplate) {
          content = taskTemplate;
        }

        if (value !== 'task' && current.content === taskTemplate) {
          content = starterTemplate;
        }
      }

      return {
        ...current,
        category: value,
        content,
      };
    });
  }

  async function submit(event) {
    event.preventDefault();
    setBusy(true);
    setError('');

    const payload = {
      ...form,
      tags: form.tags
        .split(',')
        .map((tag) => tag.trim().replace(/^#/, ''))
        .filter(Boolean),
    };

    const response = await fetch(note ? `/api/notes/${note.id}` : '/api/notes', {
      method: note ? 'PUT' : 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    const data = await response.json();

    if (!response.ok) {
      setError(data.error ?? 'Không thể lưu ghi chú.');
      setBusy(false);
      return;
    }

    router.push(`/notes/${data.id}`);
    router.refresh();
  }

  return (
    <form className="note-form" onSubmit={submit}>
      <div className="form-grid two">
        <label>
          <span>Tiêu đề *</span>
          <input
            required
            value={form.title}
            onChange={(e) => update('title', e.target.value)}
            placeholder="Ví dụ: Remove node khỏi MicroK8s cluster"
          />
        </label>

        <label>
          <span>Category *</span>
          <select value={form.category} onChange={(e) => changeCategory(e.target.value)}>
            {categories.map((item) => (
              <option value={item.key} key={item.key}>
                {item.icon} {item.label}
              </option>
            ))}
          </select>
        </label>
      </div>

      <label>
        <span>Mô tả ngắn</span>
        <input
          value={form.summary}
          onChange={(e) => update('summary', e.target.value)}
          placeholder="Một câu để sau này search là nhớ bài này dùng làm gì"
        />
      </label>

      <div className="form-grid three">
        <label>
          <span>Độ khó</span>
          <select value={form.difficulty} onChange={(e) => update('difficulty', e.target.value)}>
            <option value="beginner">🌱 Beginner</option>
            <option value="intermediate">🧩 Intermediate</option>
          </select>
        </label>

        <label>
          <span>Mức rủi ro command</span>
          <select value={form.danger_level} onChange={(e) => update('danger_level', e.target.value)}>
            <option value="safe">SAFE</option>
            <option value="caution">CAUTION</option>
            <option value="destructive">DESTRUCTIVE</option>
          </select>
        </label>

        <label>
          <span>Test gần nhất</span>
          <input
            type="date"
            value={form.last_tested_at}
            onChange={(e) => update('last_tested_at', e.target.value)}
          />
        </label>
      </div>

      <label>
        <span>Tags (cách nhau bằng dấu phẩy)</span>
        <input
          value={form.tags}
          onChange={(e) => update('tags', e.target.value)}
          placeholder="microk8s, node, cluster, remove"
        />
      </label>

      <label>
        <span>Nội dung Markdown</span>
        <textarea
          className="editor"
          value={form.content}
          onChange={(e) => update('content', e.target.value)}
          spellCheck="false"
        />
      </label>

      {error && <div className="form-error">{error}</div>}

      <div className="form-actions">
        <button type="button" className="button" onClick={() => router.back()}>
          Hủy
        </button>
        <button type="submit" className="button primary" disabled={busy}>
          {busy ? 'Đang lưu...' : 'Lưu ghi chú'}
        </button>
      </div>
    </form>
  );
}
