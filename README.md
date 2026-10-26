# DevOps Handbook

Sổ tay DevOps cá nhân để vừa học command cơ bản, vừa lưu lại runbook của những task đã làm.

## Có gì trong bản này?

- 59 bài/runbook built-in.
- Danh mục **Task** nằm đầu sidebar, có template riêng để ghi ticket, hiện trạng, backup, command, verify, rollback và bài học.
- **Linux** được làm kỹ: filesystem tree, file, permission, user/group, process, systemd, logs, disk/inode, CPU/RAM/OOM, network, port, SSH/rsync, grep/find/awk/sed, APT và cron.
- **Kubernetes** có kubectl cơ bản, pod troubleshooting, rollout/rollback, service/ingress, config/secret, storage, node maintenance và runbook **MicroK8s 3 control-plane: add/remove/join node an toàn**.
- **Database** có PostgreSQL, MySQL/MariaDB, MongoDB, Redis; mỗi phần có connection string, command connect, user/role, connection/process, size/query và backup/restore cơ bản.
- **Networking** có OSI/TCP-IP, IP, route, DNS, TCP/UDP, port, TLS, HTTP và troubleshooting flow.
- Docker, GitLab CI/CD, Nginx, Monitoring, Security, Backup và Troubleshooting.
- Search theo title, summary, command, content và tag.
- Markdown + nút Copy command.
- Badge SAFE / CAUTION / DESTRUCTIVE.
- Theme **Sáng / Tối / Theo máy**.
- Learning map + SVG minh họa cho từng lĩnh vực.
- CRUD ghi chú cá nhân.
- PostgreSQL + Docker Compose.
- Migration idempotent: rebuild source không cần xóa database volume.

## Stack

- Next.js App Router
- React
- PostgreSQL 17
- Docker Compose
- Markdown
- Cloudflare Tunnel ở phía trước nếu bạn muốn publish ra domain

Không có backend riêng. API nằm ngay trong Next.js để source dễ đọc khi đang học.

---

## 1. Chạy lần đầu

```bash
unzip devops-handbook-clean.zip
cd devops-handbook-clean
cp .env.example .env
nano .env
```

Ví dụ `.env`:

```env
POSTGRES_DB=devops_handbook
POSTGRES_USER=devops
POSTGRES_PASSWORD=CHANGE_ME_TO_A_STRONG_PASSWORD
DATABASE_URL=postgresql://devops:CHANGE_ME_TO_A_STRONG_PASSWORD@db:5432/devops_handbook
```

Sau đó:

```bash
docker compose up -d --build
```

Kiểm tra:

```bash
docker compose ps -a
docker compose logs --tail=100 migrate
docker compose logs --tail=100 app
curl http://127.0.0.1:3000/api/health
```

Expected:

```json
{"status":"ok","database":"ok"}
```

Service `migrate` chạy xong rồi ở trạng thái `Exited (0)` là bình thường.

---

## 2. Update source mà giữ note cũ

Chép source mới đè lên source cũ nhưng giữ `.env`, sau đó:

```bash
docker compose up -d --build
```

Migration sẽ chạy:

```text
scripts/init.sql
        ↓
scripts/extend.sql
```

Các bài built-in dùng `seed_key` nên được insert/update an toàn. Note cá nhân do bạn tạo không có `seed_key`, vì vậy không bị overwrite.

**Không chạy:**

```bash
docker compose down -v
```

nếu bạn muốn giữ PostgreSQL volume và ghi chú cũ.

### Nếu thật sự muốn reset sạch database

Chỉ dùng khi bạn chắc chắn không cần dữ liệu cũ:

```bash
docker compose down -v
docker compose up -d --build
```

---

## 3. Cloudflare Tunnel

### Trường hợp cloudflared đang chạy trực tiếp trên server

Published Application:

```text
Hostname: handbook.example.com
Service:  http://localhost:3000
```

Compose bind app vào:

```text
127.0.0.1:3000
```

nên port 3000 không tự mở public ra Internet.

### Trường hợp muốn chạy cloudflared bằng Docker

Điền thêm trong `.env`:

```env
CLOUDFLARE_TUNNEL_TOKEN=xxxxxxxx
```

Chạy:

```bash
docker compose -f docker-compose.yml -f docker-compose.tunnel.yml up -d --build
```

Trong Cloudflare Tunnel, service nội bộ là:

```text
http://app:3000
```

---

## 4. Lệnh vận hành project

```bash
# status
docker compose ps -a

# app log
docker compose logs -f --tail=200 app

# database log
docker compose logs -f --tail=200 db

# migration log
docker compose logs --tail=200 migrate

# restart app
docker compose restart app

# rebuild
docker compose up -d --build

# stop nhưng giữ data
docker compose down
```

---

## 5. Backup database của Handbook

Load biến môi trường:

```bash
set -a
. ./.env
set +a
```

Backup:

```bash
mkdir -p backups

docker compose exec -T db pg_dump \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  > "backups/devops-handbook-$(date +%F-%H%M).sql"
```

Verify:

```bash
ls -lh backups/
```

---

## 6. Cấu trúc source

```text
.
├── Dockerfile
├── docker-compose.yml
├── docker-compose.tunnel.yml
├── .env.example
├── public/
│   └── illustrations/
│       ├── task-runbook.svg
│       ├── linux-filesystem.svg
│       ├── kubernetes-ha.svg
│       ├── osi-model.svg
│       └── ...
├── scripts/
│   ├── init.sql
│   └── extend.sql
└── src/
    ├── app/
    │   ├── api/
    │   │   ├── health/
    │   │   └── notes/
    │   ├── notes/[id]/
    │   ├── edit/[id]/
    │   ├── new/
    │   └── globals.css
    ├── components/
    │   ├── CategoryGuide.js
    │   ├── Dashboard.js
    │   ├── MarkdownRenderer.js
    │   ├── NoteForm.js
    │   ├── Sidebar.js
    │   └── ThemeToggle.js
    └── lib/
        ├── categories.js
        ├── category-guides.js
        └── db.js
```

### Khi muốn mở rộng sau này

```text
Thêm category       → src/lib/categories.js
Learning map        → src/lib/category-guides.js
Form/template Task  → src/components/NoteForm.js
Kiến thức built-in  → scripts/extend.sql
Sơ đồ               → public/illustrations/
UI/theme             → src/app/globals.css
```

---

## 7. Cách dùng category Task

Khi bấm `+ Ghi chú mới`, form mặc định là **Task**.

Template sẽ nhắc bạn ghi theo flow:

```text
Ticket / Environment
        ↓
Mục tiêu
        ↓
Hiện trạng
        ↓
Backup
        ↓
Các bước thực hiện
        ↓
Verify
        ↓
Rollback
        ↓
Lỗi gặp phải
        ↓
Bài học
```

Ví dụ title:

```text
Task: Setup GitLab Runner office
Task: Remove node03 khỏi MicroK8s cluster
Task: Upgrade PHP trên oracle03
Task: Chuyển traffic FPT sang VNPT
Task: Backup dữ liệu OVH lên Google Drive
```

---

## 8. Quy tắc an toàn

Không lưu trong Handbook:

- password thật
- API token
- GitLab token
- Vault token
- SSH private key
- kubeconfig production
- decoded Kubernetes Secret
- database URI chứa password thật

Dùng placeholder:

```text
<SERVER_IP>
<USER>
<PASSWORD>
<TOKEN>
<NAMESPACE>
<DATABASE>
```

Nếu publish Handbook qua domain, nên đặt Cloudflare Access phía trước vì runbook có thể tiết lộ cấu trúc hạ tầng.
