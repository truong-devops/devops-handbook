export const categoryGuides = {
  task: {
    title: 'Task: ghi lại việc đã làm để lần sau có thể tự làm lại',
    description: 'Mỗi task nên đi theo một flow cố định: yêu cầu → hiện trạng → backup → thực hiện → verify → rollback → lỗi gặp phải → bài học.',
    illustration: '/illustrations/task-runbook.svg',
    steps: ['Yêu cầu', 'Hiện trạng', 'Backup', 'Thực hiện', 'Verify', 'Rollback', 'Troubleshooting', 'Bài học'],
  },
  linux: {
    title: 'Linux từ nền tảng đến vận hành server',
    description: 'Nên học theo thứ tự: filesystem → quyền → process → systemd/log → CPU/RAM/disk → network → SSH → automation.',
    illustration: '/illustrations/linux-filesystem.svg',
    steps: ['Filesystem & file', 'Permission', 'Process', 'systemd & logs', 'CPU / RAM / Disk', 'Network', 'SSH / rsync', 'Cron & troubleshooting'],
  },
  kubernetes: {
    title: 'Kubernetes: đọc cluster trước, thay đổi sau',
    description: 'Bắt đầu bằng get/describe/logs, sau đó mới học rollout, networking, storage và thao tác node/control-plane.',
    illustration: '/illustrations/kubernetes-ha.svg',
    steps: ['Cluster & node', 'Pod', 'Deployment', 'Service / Ingress', 'Config', 'Storage', 'Troubleshooting', 'MicroK8s HA'],
  },
  docker: {
    title: 'Docker: image → container → network → volume',
    description: 'Hiểu vòng đời container trước khi học cleanup, Compose và troubleshooting.',
    illustration: '/illustrations/docker-flow.svg',
    steps: ['Image', 'Container', 'Logs / exec', 'Volume', 'Network', 'Compose', 'Resource', 'Cleanup an toàn'],
  },
  'gitlab-ci': {
    title: 'GitLab CI/CD: pipeline dễ đọc, runner dễ kiểm tra',
    description: 'Học job/stage/rules/tags/artifacts trước, rồi mới đi sâu vào deploy và reusable pipeline.',
    illustration: '/illustrations/cicd-flow.svg',
    steps: ['Pipeline', 'Stage / Job', 'Rules', 'Runner / Tags', 'Artifacts', 'Variables', 'Deploy', 'Debug pipeline'],
  },
  nginx: {
    title: 'Nginx: request đi vào đâu và được xử lý thế nào',
    description: 'Luôn đọc server block, test cấu hình rồi mới reload.',
    illustration: '/illustrations/nginx-flow.svg',
    steps: ['Config tree', 'server_name', 'location', 'Reverse proxy', 'Static files', 'TLS', 'Logs', 'Troubleshooting'],
  },
  monitoring: {
    title: 'Monitoring: từ metric đến nguyên nhân',
    description: 'Đừng chỉ nhìn dashboard đỏ; học cách đi từ symptom → metric → log → service.',
    illustration: '/illustrations/monitoring-flow.svg',
    steps: ['CPU/RAM/Disk', 'Service health', 'Metrics', 'Prometheus', 'Grafana', 'Logs', 'Alert', 'Incident check'],
  },
  database: {
    title: 'Database: connection → health → quyền → query → backup',
    description: 'Mỗi loại DB đều có connection string, lệnh connect, user/role, connection, size, query và backup/restore cơ bản.',
    illustration: '/illustrations/database-flow.svg',
    steps: ['Connection string', 'Connect', 'User / Role', 'Database / Schema', 'Connection', 'Size', 'Query', 'Backup / Restore'],
  },
  network: {
    title: 'Networking: OSI/TCP-IP → IP → route → DNS → port → TLS → HTTP',
    description: 'Khi web không vào được, kiểm tra theo từng tầng thay vì đoán. OSI/TCP-IP là mental model để khoanh vùng lỗi.',
    illustration: '/illustrations/osi-model.svg',
    steps: ['OSI / TCP-IP', 'Interface / MAC', 'IP / Subnet', 'Route', 'TCP / UDP / Port', 'DNS', 'TLS', 'HTTP'],
  },
  security: {
    title: 'Security cơ bản cho người vận hành',
    description: 'Quyền tối thiểu, SSH key, firewall và không để secret trong source/note.',
    illustration: '/illustrations/security-flow.svg',
    steps: ['Permission', 'SSH key', 'sudo', 'Firewall', 'TLS', 'Secret', 'Audit', 'Patch'],
  },
  backup: {
    title: 'Backup chỉ có giá trị khi restore được',
    description: 'Luôn ghi nguồn, đích, retention, checksum và quy trình restore/verify.',
    illustration: '/illustrations/backup-flow.svg',
    steps: ['Scope', 'Archive', 'Copy', 'Checksum', 'Retention', 'Database dump', 'Restore', 'Verify'],
  },
  troubleshooting: {
    title: 'Troubleshooting theo tầng',
    description: 'Bắt đầu từ symptom, thu thập bằng chứng, thu hẹp phạm vi rồi mới thay đổi hệ thống.',
    illustration: '/illustrations/troubleshooting-flow.svg',
    steps: ['Symptom', 'Recent change', 'Resource', 'Network', 'Service', 'Logs', 'Dependency', 'Verify fix'],
  },
};
