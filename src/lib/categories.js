export const categories = [
  { key: 'task', label: 'Task', icon: '📋' },
  { key: 'linux', label: 'Linux', icon: '🐧' },
  { key: 'kubernetes', label: 'Kubernetes', icon: '☸️' },
  { key: 'docker', label: 'Docker', icon: '🐳' },
  { key: 'gitlab-ci', label: 'GitLab CI/CD', icon: '🚀' },
  { key: 'nginx', label: 'Nginx', icon: '🌐' },
  { key: 'monitoring', label: 'Monitoring', icon: '📊' },
  { key: 'database', label: 'Database', icon: '🗄️' },
  { key: 'network', label: 'Networking', icon: '🌍' },
  { key: 'security', label: 'Security', icon: '🔐' },
  { key: 'backup', label: 'Backup & Restore', icon: '💾' },
  { key: 'troubleshooting', label: 'Troubleshooting', icon: '🛠️' }
];

export function getCategory(key) {
  return categories.find((item) => item.key === key) ?? { key, label: key, icon: '📄' };
}
