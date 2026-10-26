'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';

export default function DeleteButton({ id }) {
  const router = useRouter();
  const [busy, setBusy] = useState(false);

  async function remove() {
    if (!window.confirm('Xóa ghi chú này? Thao tác này không thể hoàn tác.')) return;
    setBusy(true);
    const response = await fetch(`/api/notes/${id}`, { method: 'DELETE' });
    if (!response.ok) {
      alert('Xóa thất bại. Kiểm tra log app.');
      setBusy(false);
      return;
    }
    router.push('/');
    router.refresh();
  }

  return <button type="button" className="button danger" onClick={remove} disabled={busy}>{busy ? 'Đang xóa...' : 'Xóa'}</button>;
}
