import './globals.css';

export const metadata = {
  title: 'DevOps Handbook',
  description: 'Sổ tay lệnh và runbook DevOps cá nhân',
};

const themeScript = `
(function () {
  try {
    var saved = localStorage.getItem('devops-handbook-theme') || 'system';
    document.documentElement.dataset.theme = saved;
  } catch (_) {}
})();`;

export default function RootLayout({ children }) {
  return (
    <html lang="vi" data-theme="system" suppressHydrationWarning>
      <head><script dangerouslySetInnerHTML={{ __html: themeScript }} /></head>
      <body>{children}</body>
    </html>
  );
}
