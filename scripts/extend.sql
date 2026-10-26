-- =========================================================
-- DevOps Handbook extensions
-- Task template support is handled in NoteForm.js.
-- This file enriches Linux, Database and Networking content.
-- It is safe to run many times because updates target seed_key
-- and inserts use ON CONFLICT(seed_key).
-- =========================================================

-- ---------------------------------------------------------
-- Linux: filesystem map
-- ---------------------------------------------------------
UPDATE notes
SET
  title = 'Linux 02: Filesystem và cây thư mục Linux',
  summary = 'Hiểu /, /etc, /var, /home, /root, /usr, /opt, /tmp, /proc, /sys, /dev và các lệnh di chuyển cơ bản.',
  tags = ARRAY['linux','filesystem','directory','pwd','ls','cd','tree']::TEXT[],
  content = $NOTE$![Linux Filesystem](/illustrations/linux-filesystem.svg)

## 🌳 Cây thư mục Linux

```text
/
├── etc        # config hệ thống và service
├── var
│   ├── log    # log
│   └── lib    # state/data của service
├── home       # home user thường
├── root       # home của root
├── usr
│   └── bin    # command/program
├── opt        # phần mềm cài thêm
├── tmp        # file tạm
├── boot       # bootloader/kernel
├── dev        # device
├── proc       # process + kernel runtime
├── sys        # kernel/device information
├── mnt        # mount thủ công
└── media      # removable media
```

## Những thư mục DevOps thường gặp

| Path | Ý nghĩa | Ví dụ khi làm DevOps |
|---|---|---|
| `/etc` | cấu hình hệ thống/service | `/etc/nginx`, `/etc/ssh`, `/etc/systemd` |
| `/var/log` | log | Nginx log, syslog, application log |
| `/var/lib` | dữ liệu/state service | Docker, database, package state |
| `/home` | home user thường | source/script của user |
| `/root` | home của root | file thao tác bằng root |
| `/usr/bin` | command/program | `curl`, `grep`, `ssh`... |
| `/opt` | phần mềm bên thứ ba | app tự cài |
| `/tmp` | file tạm | file test, archive tạm |
| `/proc` | thông tin process/kernel runtime | `/proc/cpuinfo`, `/proc/meminfo` |
| `/sys` | thông tin kernel/device | device, cgroup... |
| `/dev` | device | `/dev/sda`, `/dev/null` |
| `/mnt` | mount thủ công | disk/NFS tạm |
| `/media` | removable media | USB/CD |

## Di chuyển

```bash
pwd
ls
ls -lah
cd /var/log
cd ..
cd ~
cd -
```

## Xem cây thư mục

```bash
find /etc/nginx -maxdepth 2 -type f
```

Nếu có `tree`:

```bash
tree -L 2 /etc/nginx
```

## Kiểm tra mount và filesystem

```bash
df -h
findmnt
lsblk -f
mount | column -t
```

## 🧠 Cần nhớ

- `/` là root filesystem.
- `~` là home của user hiện tại.
- `cd -` quay lại thư mục trước đó.
- `/root` không phải là `/`.
- Một thư mục có thể là mount point của filesystem/disk khác.
$NOTE$,
  updated_at = NOW()
WHERE seed_key = 'linux-navigation';

-- ---------------------------------------------------------
-- PostgreSQL administration
-- ---------------------------------------------------------
UPDATE notes
SET
  title = 'Database 01: PostgreSQL - connection string và quản trị cơ bản',
  summary = 'Connect PostgreSQL, đọc connection string, quản lý database/role, xem connection, size và query đang chạy.',
  difficulty = 'beginner',
  danger_level = 'caution',
  tags = ARRAY['database','postgresql','psql','connection-string','role','admin','query']::TEXT[],
  content = $NOTE$![Database ops](/illustrations/database-flow.svg)

## 🔗 Connection String

Format:

```text
postgresql://<USER>:<PASSWORD>@<HOST>:5432/<DATABASE>
```

Ví dụ:

```text
postgresql://app_user:<PASSWORD>@10.0.0.10:5432/app_db
```

Có SSL:

```text
postgresql://<USER>:<PASSWORD>@<HOST>:5432/<DATABASE>?sslmode=require
```

> Không lưu password thật vào sổ tay. Nếu password có ký tự đặc biệt khi nằm trong URI thì cần URL-encode.

## Connect bằng psql

```bash
psql -h <HOST> -p 5432 -U <USER> -d <DATABASE>
```

Từ chính server DB:

```bash
sudo -u postgres psql
```

## Thông tin hiện tại

```sql
SELECT version();
SELECT current_database();
SELECT current_user;
```

Trong `psql`:

```text
\conninfo
\l+
\dn+
\dt+
\du
```

## 👤 Role / User

Xem role:

```sql
SELECT rolname, rolsuper, rolcreatedb, rolcanlogin
FROM pg_roles
ORDER BY rolname;
```

Tạo login role:

```sql
CREATE ROLE <USER> LOGIN;
```

Đặt/đổi password an toàn hơn ngay trong `psql`:

```text
\password <USER>
```

Cấp quyền connect:

```sql
GRANT CONNECT ON DATABASE <DATABASE> TO <USER>;
```

Cấp quyền dùng schema:

```sql
GRANT USAGE ON SCHEMA public TO <USER>;
```

Chỉ đọc table hiện có:

```sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO <USER>;
```

## 🗄 Database

Tạo database:

```sql
CREATE DATABASE <DATABASE> OWNER <USER>;
```

Xem kích thước database:

```sql
SELECT
  datname,
  pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database
ORDER BY pg_database_size(datname) DESC;
```

Top table lớn:

```sql
SELECT
  schemaname,
  relname,
  pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 20;
```

## 🔌 Connections

```sql
SELECT
  pid,
  usename,
  datname,
  client_addr,
  state,
  query_start,
  left(query, 120) AS query
FROM pg_stat_activity
ORDER BY query_start;
```

Đếm connection:

```sql
SELECT count(*) FROM pg_stat_activity;
```

Theo database:

```sql
SELECT datname, count(*)
FROM pg_stat_activity
GROUP BY datname
ORDER BY count(*) DESC;
```

Max connections:

```sql
SHOW max_connections;
```

## Query đang chạy lâu

```sql
SELECT
  pid,
  now() - query_start AS duration,
  usename,
  datname,
  state,
  left(query, 150) AS query
FROM pg_stat_activity
WHERE state <> 'idle'
ORDER BY duration DESC;
```

## ⚠️ Terminate connection

Trước tiên xem đúng PID, user, database và query.

```sql
SELECT pg_terminate_backend(<PID>);
```

> Đây là thao tác CAUTION vì có thể làm transaction/query của application bị ngắt.

## Backup nhanh

```bash
pg_dump -h <HOST> -U <USER> -d <DATABASE> -Fc -f backup.dump
```

Restore vào database test trước khi dùng production:

```bash
pg_restore -h <HOST> -U <USER> -d <DATABASE> --clean --if-exists backup.dump
```
$NOTE$,
  updated_at = NOW()
WHERE seed_key = 'db-postgres';

-- ---------------------------------------------------------
-- MySQL / MariaDB administration
-- ---------------------------------------------------------
UPDATE notes
SET
  title = 'Database 02: MySQL/MariaDB - connection string và quản trị cơ bản',
  summary = 'Connect MySQL/MariaDB, đọc connection string, quản lý user/quyền, database, processlist và size.',
  danger_level = 'caution',
  tags = ARRAY['database','mysql','mariadb','connection-string','user','grant','processlist']::TEXT[],
  content = $NOTE$## 🔗 Connection String

```text
mysql://<USER>:<PASSWORD>@<HOST>:3306/<DATABASE>
```

Ví dụ:

```text
mysql://app_user:<PASSWORD>@10.0.0.20:3306/app_db
```

> Không lưu password thật vào note. Password trong URI có ký tự đặc biệt thì cần URL-encode.

## Connect CLI

```bash
mysql -h <HOST> -P 3306 -u <USER> -p <DATABASE>
```

Kiểm tra version:

```sql
SELECT VERSION();
```

## Database / table

```sql
SHOW DATABASES;
USE <DATABASE>;
SHOW TABLES;
SHOW TABLE STATUS;
```

Tạo database:

```sql
CREATE DATABASE <DATABASE>
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

## 👤 User

```sql
SELECT user, host
FROM mysql.user
ORDER BY user, host;
```

Xem quyền:

```sql
SHOW GRANTS FOR '<USER>'@'<HOST_PATTERN>';
```

Tạo user:

```sql
CREATE USER '<USER>'@'<HOST_PATTERN>'
IDENTIFIED BY '<PASSWORD>';
```

Ví dụ chỉ cho localhost:

```sql
CREATE USER 'app'@'localhost'
IDENTIFIED BY '<PASSWORD>';
```

Cấp quyền CRUD cho một database:

```sql
GRANT SELECT, INSERT, UPDATE, DELETE
ON <DATABASE>.*
TO '<USER>'@'<HOST_PATTERN>';
```

Kiểm tra lại:

```sql
SHOW GRANTS FOR '<USER>'@'<HOST_PATTERN>';
```

> `'<USER>'@'%'` cho phép match mọi source host. Không nên dùng `%` theo thói quen nếu không thực sự cần.

## 🔌 Connection / process

```sql
SHOW FULL PROCESSLIST;
```

Hoặc:

```sql
SELECT *
FROM information_schema.processlist
ORDER BY TIME DESC;
```

Max connections:

```sql
SHOW VARIABLES LIKE 'max_connections';
SHOW STATUS LIKE 'Threads_connected';
```

## Size database

```sql
SELECT
  table_schema AS database_name,
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS size_mb
FROM information_schema.tables
GROUP BY table_schema
ORDER BY size_mb DESC;
```

Top table lớn:

```sql
SELECT
  table_schema,
  table_name,
  ROUND((data_length + index_length) / 1024 / 1024, 2) AS size_mb
FROM information_schema.tables
ORDER BY (data_length + index_length) DESC
LIMIT 20;
```

## ⚠️ Kill process

Xem kỹ `SHOW FULL PROCESSLIST` trước:

```sql
KILL <PROCESS_ID>;
```

## Backup

```bash
mysqldump -h <HOST> -P 3306 -u <USER> -p \
  --single-transaction <DATABASE> > backup.sql
```

Restore:

```bash
mysql -h <HOST> -P 3306 -u <USER> -p <DATABASE> < backup.sql
```
$NOTE$,
  updated_at = NOW()
WHERE seed_key = 'db-mysql';

-- ---------------------------------------------------------
-- MongoDB administration
-- ---------------------------------------------------------
UPDATE notes
SET
  title = 'Database 03: MongoDB - connection string và quản trị cơ bản',
  summary = 'Connect MongoDB, đọc URI, xem database/collection/user/connection, replica set và statistics.',
  danger_level = 'caution',
  tags = ARRAY['database','mongodb','mongosh','connection-string','replica-set','admin']::TEXT[],
  content = $NOTE$## 🔗 Connection String

Không authentication:

```text
mongodb://<HOST>:27017/<DATABASE>
```

Có authentication:

```text
mongodb://<USER>:<PASSWORD>@<HOST>:27017/<DATABASE>?authSource=admin
```

Replica Set:

```text
mongodb://<USER>:<PASSWORD>@mongo01:27017,mongo02:27017,mongo03:27017/<DATABASE>?replicaSet=<REPLICA_SET>&authSource=admin
```

SRV URI thường gặp ở managed service:

```text
mongodb+srv://<USER>:<PASSWORD>@<CLUSTER>/<DATABASE>
```

> Không lưu password thật. Password trong URI có ký tự như `@`, `:`, `/` cần URL-encode.

## Connect bằng mongosh

```bash
mongosh 'mongodb://<HOST>:27017/<DATABASE>'
```

Hoặc:

```bash
mongosh 'mongodb://<USER>:<PASSWORD>@<HOST>:27017/<DATABASE>?authSource=admin'
```

## Database / collection

```javascript
show dbs
use <DATABASE>
show collections
```

Stats:

```javascript
db.stats()
db.<COLLECTION>.stats()
```

## 👤 User

```javascript
use admin
db.getUsers()
```

Xem user của DB hiện tại:

```javascript
db.getUsers()
```

## 🔌 Connections

```javascript
db.serverStatus().connections
```

Operation đang chạy:

```javascript
db.currentOp()
```

## Replica Set

```javascript
rs.status()
rs.conf()
```

Những field cần để ý trong `rs.status()`:
- node nào là PRIMARY
- node nào là SECONDARY
- member nào không healthy
- replication lag nếu có

## Index

```javascript
db.<COLLECTION>.getIndexes()
```

Query explain:

```javascript
db.<COLLECTION>.find({ <FIELD>: <VALUE> }).explain('executionStats')
```

## Backup cơ bản

```bash
mongodump \
  --uri='mongodb://<USER>:<PASSWORD>@<HOST>:27017/<DATABASE>?authSource=admin' \
  --out=./mongo-backup
```

Restore:

```bash
mongorestore \
  --uri='mongodb://<USER>:<PASSWORD>@<HOST>:27017/<DATABASE>?authSource=admin' \
  ./mongo-backup
```

> Hãy test restore trên môi trường test trước khi dùng với production.
$NOTE$,
  updated_at = NOW()
WHERE seed_key = 'db-mongo';

-- ---------------------------------------------------------
-- Redis administration
-- ---------------------------------------------------------
INSERT INTO notes (
  seed_key,
  title,
  summary,
  category,
  difficulty,
  danger_level,
  tags,
  content,
  last_tested_at
)
VALUES (
  'db-redis',
  'Database 05: Redis - connection string và quản trị cơ bản',
  'Connect Redis, kiểm tra health, memory, client, slowlog và duyệt key an toàn.',
  'database',
  'beginner',
  'caution',
  ARRAY['database','redis','redis-cli','connection-string','memory','slowlog']::TEXT[],
$NOTE$## 🔗 Connection String

Không auth:

```text
redis://<HOST>:6379/0
```

Có username/password:

```text
redis://<USER>:<PASSWORD>@<HOST>:6379/0
```

TLS:

```text
rediss://<USER>:<PASSWORD>@<HOST>:6379/0
```

## Connect

```bash
redis-cli -h <HOST> -p 6379
```

Có TLS/auth thì dùng option phù hợp với hệ thống của bạn, tránh để password lộ trong shell history.

## Health

```text
PING
INFO server
INFO clients
INFO memory
INFO stats
DBSIZE
```

Expected:

```text
PONG
```

## Client

```text
CLIENT LIST
```

## Slow command

```text
SLOWLOG LEN
SLOWLOG GET 20
```

## Memory

```text
MEMORY STATS
INFO memory
```

## Duyệt key

Ưu tiên:

```text
SCAN 0 COUNT 100
```

Không nên dùng trên production lớn theo thói quen:

```text
KEYS *
```

vì có thể block Redis trong lúc quét toàn bộ keyspace.

## TTL

```text
TTL <KEY>
PTTL <KEY>
```

## ⚠️ Lệnh cần rất cẩn thận

```text
DEL <KEY>
FLUSHDB
FLUSHALL
```

`FLUSHDB` và `FLUSHALL` có thể xóa dữ liệu. Không chạy nếu chưa xác định đúng DB, impact và backup/rollback.
$NOTE$,
NULL
)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at),
  updated_at=NOW();

-- ---------------------------------------------------------
-- Networking: OSI/TCP-IP learning note
-- ---------------------------------------------------------
INSERT INTO notes (
  seed_key,
  title,
  summary,
  category,
  difficulty,
  danger_level,
  tags,
  content,
  last_tested_at
)
VALUES (
  'network-osi',
  'Networking 00: Mô hình OSI và TCP/IP',
  'Hiểu các tầng mạng và biết command nào kiểm tra tầng nào khi troubleshooting.',
  'network',
  'beginner',
  'safe',
  ARRAY['network','osi','tcp-ip','tcp','udp','ip','dns','tls','http']::TEXT[],
$NOTE$![OSI và TCP/IP](/illustrations/osi-model.svg)

## 🧠 Vì sao DevOps cần hiểu mô hình tầng mạng?

Khi user nói:

> Web không truy cập được

đừng nghĩ ngay là Nginx lỗi.

Request đi qua nhiều lớp. Mô hình tầng giúp mình kiểm tra **từ thấp lên cao** và biết lỗi nằm ở đâu.

## OSI và TCP/IP

| OSI | Ví dụ | TCP/IP |
|---|---|---|
| 7 Application | HTTP, HTTPS, DNS, SSH | Application |
| 6 Presentation | TLS, encoding | Application |
| 5 Session | session/connection management | Application |
| 4 Transport | TCP, UDP, port | Transport |
| 3 Network | IP, routing, ICMP | Internet |
| 2 Data Link | Ethernet, MAC, ARP | Network Access |
| 1 Physical | cable, fiber, Wi-Fi radio | Network Access |

## Layer 1 - Physical

Cable, NIC, Wi-Fi, link state.

```bash
ip link
```

Nếu interface đang `DOWN`, kiểm tra tầng cao hơn chưa có nhiều ý nghĩa.

## Layer 2 - Data Link

MAC, Ethernet, neighbor/ARP.

```bash
ip link
ip neigh
```

## Layer 3 - Network

IP và routing.

```bash
ip addr
ip route
ip route get 8.8.8.8
ping -c 4 8.8.8.8
```

## Layer 4 - Transport

TCP/UDP và port.

```bash
ss -lntup
nc -vz <HOST> 443
```

Một số port thường gặp:

| Port | Service thường gặp |
|---:|---|
| 22 | SSH |
| 53 | DNS |
| 80 | HTTP |
| 443 | HTTPS |
| 3306 | MySQL |
| 5432 | PostgreSQL |
| 6379 | Redis |
| 27017 | MongoDB |

> Port chỉ là convention/default. Service hoàn toàn có thể chạy port khác.

## Layer 5-7 - Application

DNS:

```bash
dig example.com
```

TLS:

```bash
openssl s_client \
  -connect example.com:443 \
  -servername example.com
```

HTTP:

```bash
curl -Iv https://example.com
```

## 🔎 Mental model troubleshooting web

```text
Web không vào
     |
     v
Interface/link UP?
     |
     v
Có IP đúng?
     |
     v
Route đúng?
     |
     v
DNS resolve được?
     |
     v
TCP port 443 connect được?
     |
     v
TLS handshake được?
     |
     v
HTTP response?
     |
     v
Nginx / reverse proxy?
     |
     v
Backend application?
     |
     v
Database / dependency?
```

## 🧪 Bộ lệnh kiểm tra nhanh

```bash
ip -br addr
ip route
ip route get 8.8.8.8
cat /etc/resolv.conf
dig example.com
nc -vz example.com 443
curl -Iv https://example.com
```

## 🧠 Cần nhớ

Không phải lúc nào cũng cần debug đủ 7 tầng. OSI là **mental model để chia nhỏ vấn đề**, không phải checklist cứng nhắc.
$NOTE$,
NULL
)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at),
  updated_at=NOW();

-- ---------------------------------------------------------
-- Task: sample runbook so the category is not empty on first start
-- ---------------------------------------------------------
INSERT INTO notes (
  seed_key,
  title,
  summary,
  category,
  difficulty,
  danger_level,
  tags,
  content,
  last_tested_at
)
VALUES (
  'task-example-runbook',
  'Task mẫu: Ghi lại một thay đổi trên server theo chuẩn runbook',
  'Ví dụ cách ghi một task thật: yêu cầu, hiện trạng, backup, command, verify, rollback và bài học.',
  'task',
  'beginner',
  'caution',
  ARRAY['task','runbook','verify','rollback','example']::TEXT[],
$NOTE$![Task Runbook](/illustrations/task-runbook.svg)

## 🎫 Thông tin Task

**Ticket:** `<TICKET-ID>`  
**Ngày thực hiện:** `<YYYY-MM-DD>`  
**Environment:** DEV / QA / UAT / PROD  
**Server / Cluster:** `<SERVER_OR_CLUSTER>`  
**Người yêu cầu:** `<REQUESTER>`

## 🎯 Mục tiêu

Ví dụ: sửa cấu hình một service nhưng không làm gián đoạn hệ thống ngoài kế hoạch.

## 🔎 Hiện trạng trước khi làm

```bash
hostname
uptime
df -h
free -h
systemctl --failed
```

Nếu task liên quan service:

```bash
systemctl status <SERVICE> --no-pager
journalctl -u <SERVICE> -n 100 --no-pager
```

## 💾 Backup / Snapshot

Ví dụ backup config trước khi sửa:

```bash
sudo cp -a /etc/<SERVICE> /etc/<SERVICE>.bak-$(date +%F-%H%M)
```

## 🛠️ Thực hiện

Ghi từng bước, không chỉ lưu command rời rạc.

```bash
# Bước 1: kiểm tra config
# Bước 2: sửa
# Bước 3: validate
# Bước 4: reload/restart khi cần
```

## ✅ Verify

```bash
systemctl is-active <SERVICE>
systemctl status <SERVICE> --no-pager
```

Nếu là web:

```bash
curl -I https://<DOMAIN>
```

## ↩️ Rollback

```bash
# restore file backup / image / release cũ
```

Ghi rõ rollback **trước khi** làm task có rủi ro.

## 🐛 Lỗi gặp phải

Lưu error message ngắn, nguyên nhân và cách xử lý. Không lưu secret.

## 🧠 Mình học được gì?

Tự giải thích:

1. command này dùng để làm gì
2. output cần nhìn chỗ nào
3. vì sao bước verify chứng minh task đã thành công
4. nếu làm lại thì thứ tự nào an toàn hơn
$NOTE$,
NULL
)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at),
  updated_at=NOW();
