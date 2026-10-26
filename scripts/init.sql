CREATE TABLE IF NOT EXISTS notes (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(180) NOT NULL,
  summary TEXT NOT NULL DEFAULT '',
  category VARCHAR(50) NOT NULL,
  difficulty VARCHAR(20) NOT NULL DEFAULT 'beginner' CHECK (difficulty IN ('beginner', 'intermediate')),
  danger_level VARCHAR(20) NOT NULL DEFAULT 'safe' CHECK (danger_level IN ('safe', 'caution', 'destructive')),
  tags TEXT[] NOT NULL DEFAULT '{}',
  content TEXT NOT NULL,
  last_tested_at DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE notes ADD COLUMN IF NOT EXISTS seed_key VARCHAR(120);
CREATE UNIQUE INDEX IF NOT EXISTS idx_notes_seed_key ON notes(seed_key) WHERE seed_key IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_notes_category ON notes(category);
CREATE INDEX IF NOT EXISTS idx_notes_updated_at ON notes(updated_at DESC);

-- Gắn seed_key cho các note mẫu của bản cũ nếu chúng còn nguyên title.
UPDATE notes SET seed_key='linux-health', last_tested_at=NULL WHERE id=(SELECT id FROM notes WHERE seed_key IS NULL AND title='Linux: Checklist kiểm tra server cơ bản' ORDER BY id LIMIT 1);
UPDATE notes SET seed_key='linux-port', last_tested_at=NULL WHERE id=(SELECT id FROM notes WHERE seed_key IS NULL AND title='Linux: Tìm process đang chiếm port' ORDER BY id LIMIT 1);
UPDATE notes SET seed_key='k8s-basics', last_tested_at=NULL WHERE id=(SELECT id FROM notes WHERE seed_key IS NULL AND title='Kubernetes: Bộ lệnh kubectl cơ bản' ORDER BY id LIMIT 1);
UPDATE notes SET seed_key='docker-disk', last_tested_at=NULL WHERE id=(SELECT id FROM notes WHERE seed_key IS NULL AND title='Docker: Kiểm tra container và disk usage' ORDER BY id LIMIT 1);
UPDATE notes SET seed_key='nginx-reload', last_tested_at=NULL WHERE id=(SELECT id FROM notes WHERE seed_key IS NULL AND title='Nginx: Kiểm tra config trước khi reload' ORDER BY id LIMIT 1);
UPDATE notes SET seed_key='gitlab-runner-tags', last_tested_at=NULL WHERE id=(SELECT id FROM notes WHERE seed_key IS NULL AND title='GitLab Runner: Hiểu tags của job và runner' ORDER BY id LIMIT 1);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-health','Linux 01: Checklist kiểm tra server cơ bản','Bộ lệnh đầu tiên nên chạy khi SSH vào server: OS, uptime, CPU, RAM, disk, service và port.','linux','beginner','safe',ARRAY['linux','health-check','cpu','ram','disk','service']::TEXT[],$NOTE$![Sơ đồ Linux](/illustrations/linux-basics.svg)

## 🎯 Mục đích
Dùng khi vừa SSH vào server hoặc khi user báo "server chậm / web không vào được".

## 1. Nhận diện máy
```bash
hostname
hostnamectl
cat /etc/os-release
uname -a
whoami
pwd
```

## 2. Uptime và load
```bash
uptime
nproc
lscpu
```
`load average` nên được đọc cùng số CPU (`nproc`), không nhìn một con số riêng lẻ.

## 3. RAM
```bash
free -h
vmstat 1 5
```
Quan sát `available` thay vì chỉ nhìn `used` vì Linux dùng RAM làm cache.

## 4. Disk
```bash
df -h
df -i
lsblk
sudo du -xhd1 / 2>/dev/null | sort -h
```

## 5. Process và service
```bash
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head
systemctl --failed
systemctl --type=service --state=running
```

## 6. Port
```bash
sudo ss -lntup
```

## ✅ Checklist nhanh
- filesystem không gần 100%
- inode không gần 100%
- service quan trọng không `failed`
- port cần thiết đang `LISTEN`
- CPU/RAM không bị process lạ chiếm hết
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-navigation','Linux 02: Filesystem và di chuyển thư mục','Các lệnh pwd, ls, cd và ý nghĩa những thư mục quan trọng như /etc, /var, /home, /tmp.','linux','beginner','safe',ARRAY['linux','filesystem','pwd','ls','cd']::TEXT[],$NOTE$## Những thư mục nên nhớ
| Path | Thường chứa gì |
|---|---|
| `/etc` | cấu hình hệ thống/service |
| `/var/log` | log |
| `/var/lib` | dữ liệu state của service |
| `/home` | home user thường |
| `/root` | home của root |
| `/tmp` | file tạm |
| `/opt` | phần mềm bổ sung |
| `/usr/bin` | binary/command |

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
# nếu có tree
tree -L 2 /etc/nginx
```

## 🧠 Cần nhớ
`/` là root filesystem; `~` là home của user hiện tại. `cd -` quay lại thư mục trước đó.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-files','Linux 03: File và thư mục - tạo, copy, move, xem nội dung','Các thao tác file thường dùng: touch, mkdir, cp, mv, rm, cat, less, head, tail.','linux','beginner','caution',ARRAY['linux','file','cp','mv','rm','tail']::TEXT[],$NOTE$## Tạo
```bash
touch test.txt
mkdir logs
mkdir -p backup/nginx/2026
```

## Copy / move
```bash
cp file.conf file.conf.bak
cp -a /etc/nginx /tmp/nginx-backup
mv old.txt new.txt
mv file.txt /tmp/
```

## Đọc file
```bash
cat file.txt
less file.txt
head -n 20 file.txt
tail -n 50 file.txt
tail -f /var/log/nginx/error.log
```

## Xóa ⚠️
```bash
rm file.txt
rm -r empty-or-test-directory
```
> Trước `rm -rf`, hãy chạy `pwd` và `ls` để chắc chắn bạn đang ở đúng chỗ. Với production, ưu tiên rename/move ra thư mục backup trước.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-permissions','Linux 04: Permission, owner và chmod/chown','Hiểu rwx, user/group/other và cách đọc quyền file trước khi sửa.','linux','beginner','caution',ARRAY['linux','permission','chmod','chown','rwx']::TEXT[],$NOTE$## Đọc permission
```bash
ls -lah /path/to/file
stat /path/to/file
```
Ví dụ `-rw-r-----`:
- owner: `rw-`
- group: `r--`
- others: `---`

## Đổi owner/group
```bash
sudo chown user:group file
sudo chown -R user:group directory
```

## chmod
```bash
chmod 644 file.conf
chmod 600 secret.env
chmod 755 script.sh
chmod +x deploy.sh
```

## Giá trị số
- read = 4
- write = 2
- execute = 1
- `755` = owner `rwx`, group `r-x`, other `r-x`
- `640` = owner `rw-`, group `r--`, other `---`

## ⚠️ Tránh
Không dùng `chmod -R 777` để "chữa cháy" permission. Hãy xác định process chạy bằng user/group nào.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-users','Linux 05: User, group và sudo','Kiểm tra user hiện tại, group, tạo user và xem quyền sudo.','linux','beginner','caution',ARRAY['linux','user','group','sudo','id']::TEXT[],$NOTE$## Kiểm tra
```bash
whoami
id
id <USER>
groups <USER>
getent passwd <USER>
getent group <GROUP>
```

## User đang login
```bash
who
w
last -n 20
```

## Tạo user/group
```bash
sudo adduser <USER>
sudo groupadd <GROUP>
sudo usermod -aG <GROUP> <USER>
```
Sau khi thêm group, user thường cần logout/login lại.

## Sudo
```bash
sudo -l
sudo -u <USER> whoami
```

## Xóa user ⚠️
```bash
sudo deluser <USER>
# chỉ xóa home nếu bạn đã kiểm tra dữ liệu
sudo deluser --remove-home <USER>
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-process','Linux 06: Process, PID, jobs và signal','Tìm process ngốn CPU/RAM, hiểu PID và dừng process theo mức độ an toàn.','linux','beginner','caution',ARRAY['linux','process','pid','kill','top','htop']::TEXT[],$NOTE$## Xem process
```bash
ps aux
ps aux --sort=-%cpu | head -n 15
ps aux --sort=-%mem | head -n 15
ps -fp <PID>
pgrep -a nginx
```

## Realtime
```bash
top
htop
```

## Process tree
```bash
pstree -ap
ps -ef --forest
```

## Signal
```bash
kill <PID>          # SIGTERM: yêu cầu dừng graceful
kill -HUP <PID>     # tùy app: reload
kill -9 <PID>       # SIGKILL: chỉ dùng khi process không chịu dừng
```
> Nếu process do systemd/Docker/Kubernetes quản lý, ưu tiên thao tác qua chính công cụ quản lý thay vì kill PID trực tiếp.

## Background jobs của shell
```bash
command &
jobs
fg %1
bg %1
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-systemd','Linux 07: systemd và quản lý service','Các lệnh status/start/stop/restart/reload/enable và cách đọc unit.','linux','beginner','caution',ARRAY['linux','systemd','service','systemctl']::TEXT[],$NOTE$## Trạng thái
```bash
systemctl status nginx --no-pager
systemctl is-active nginx
systemctl is-enabled nginx
systemctl --failed
```

## Điều khiển service
```bash
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx
```
`reload` thường ít gián đoạn hơn `restart`, nhưng service phải hỗ trợ reload.

## Startup cùng máy
```bash
sudo systemctl enable nginx
sudo systemctl disable nginx
```

## Xem unit
```bash
systemctl cat nginx
systemctl show nginx
```

## Sau khi sửa unit file
```bash
sudo systemctl daemon-reload
sudo systemctl restart <SERVICE>
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-logs','Linux 08: Log và journalctl','Cách đọc log systemd theo service, thời gian, boot và follow realtime.','linux','beginner','safe',ARRAY['linux','logs','journalctl','dmesg','syslog']::TEXT[],$NOTE$## Log service
```bash
journalctl -u nginx --no-pager -n 100
journalctl -u nginx -f
```

## Theo thời gian
```bash
journalctl --since "1 hour ago"
journalctl --since today
journalctl -u ssh --since "2026-10-25 09:00" --until "2026-10-25 10:00"
```

## Boot hiện tại / boot trước
```bash
journalctl -b
journalctl -b -1
```

## Kernel
```bash
journalctl -k -n 100
sudo dmesg -T | tail -n 100
```

## Log file truyền thống
```bash
sudo tail -f /var/log/syslog
sudo grep -iE 'error|fail|oom' /var/log/syslog | tail
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-disk','Linux 09: Disk, inode và tìm thứ đang chiếm dung lượng','Quy trình khi disk full: df → inode → du → find large files → deleted-open files.','linux','beginner','caution',ARRAY['linux','disk','df','du','inode','lsof']::TEXT[],$NOTE$## 1. Filesystem nào đầy?
```bash
df -hT
df -i
```

## 2. Thư mục nào lớn?
```bash
sudo du -xhd1 / 2>/dev/null | sort -h
sudo du -xhd1 /var 2>/dev/null | sort -h
```
`-x` giúp không nhảy sang filesystem khác.

## 3. File lớn
```bash
sudo find /var -xdev -type f -size +500M -printf '%s %p\n' 2>/dev/null | sort -n | tail
```

## 4. File đã xóa nhưng process còn giữ
```bash
sudo lsof +L1
```
Nếu log bị xóa nhưng process vẫn mở file, disk chỉ được trả sau khi process đóng file descriptor (thường restart/reload đúng service).

## Docker
```bash
docker system df
docker system df -v
```

## ✅ Verify
Chạy lại `df -h` sau cleanup và kiểm tra service liên quan vẫn hoạt động.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-cpu-memory','Linux 10: CPU, RAM, load average và OOM','Đọc tài nguyên server đúng cách và tìm dấu hiệu OOM killer.','linux','beginner','safe',ARRAY['linux','cpu','ram','load','oom','vmstat']::TEXT[],$NOTE$## CPU
```bash
nproc
lscpu
uptime
top
```

## RAM / swap
```bash
free -h
swapon --show
vmstat 1 10
```

## Process tiêu thụ nhiều
```bash
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head
```

## OOM killer
```bash
journalctl -k | grep -iE 'out of memory|oom|killed process'
dmesg -T | grep -iE 'out of memory|oom|killed process'
```

## 🧠 Gợi ý đọc load
Load 8 trên máy 16 CPU có thể bình thường; load 8 trên máy 2 CPU cần điều tra. Đồng thời xem CPU `%wa`/I/O wait nếu máy chậm nhưng CPU user không cao.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-network','Linux 11: Network cơ bản trên server','IP, route, DNS, port listen, kết nối TCP và kiểm tra HTTP/TLS.','linux','beginner','safe',ARRAY['linux','network','ip','route','dns','ss','curl']::TEXT[],$NOTE$## IP và interface
```bash
ip -br addr
ip link
```

## Route
```bash
ip route
ip route get 1.1.1.1
```

## DNS
```bash
getent hosts example.com
dig example.com
nslookup example.com
```

## Port local
```bash
sudo ss -lntup
sudo ss -lntp | grep ':443'
```

## Test host/port
```bash
nc -vz <HOST> 443
curl -v http://<HOST>:<PORT>/
curl -vk https://example.com/
```

## Path
```bash
ping -c 4 <HOST>
traceroute <HOST>
# hoặc
tracepath <HOST>
```

## DNS → TCP → TLS → HTTP
Khi web lỗi, kiểm tra theo đúng chuỗi này để biết lỗi nằm ở tầng nào.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-port','Linux 12: Tìm process đang chiếm port','Khi gặp address already in use hoặc muốn biết port 80/443/3000/5432 thuộc process nào.','linux','beginner','safe',ARRAY['linux','port','ss','lsof','process']::TEXT[],$NOTE$## ss
```bash
sudo ss -lntp
sudo ss -lntp | grep ':3000'
```

## lsof
```bash
sudo lsof -nP -iTCP:3000 -sTCP:LISTEN
```

## Xem PID
```bash
ps -fp <PID>
readlink -f /proc/<PID>/exe
cat /proc/<PID>/cmdline | tr '\0' ' '
```

## Nếu là systemd
```bash
systemctl status <SERVICE>
```

## Nếu là Docker
```bash
docker ps --format 'table {{.Names}}\t{{.Ports}}'
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-ssh','Linux 13: SSH, SCP và rsync','Kết nối server, copy file và sync thư mục an toàn.','linux','beginner','caution',ARRAY['linux','ssh','scp','rsync']::TEXT[],$NOTE$## SSH
```bash
ssh user@server
ssh -p 2222 user@server
ssh -i ~/.ssh/id_ed25519 user@server
```

## Debug kết nối
```bash
ssh -v user@server
```

## SCP
```bash
scp file.txt user@server:/tmp/
scp user@server:/var/log/app.log ./
scp -r directory user@server:/tmp/
```

## rsync - nên dùng khi sync nhiều file
```bash
rsync -avh --progress ./src/ user@server:/var/www/app/
```
Dry-run trước khi dùng delete:
```bash
rsync -avhn --delete ./src/ user@server:/var/www/app/
```
> `--delete` có thể xóa file ở destination không còn trong source. Luôn dry-run trước.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-text','Linux 14: grep, find, sort, awk, sed - bộ lệnh xử lý text','Các command giúp tìm config/log nhanh trên server.','linux','beginner','safe',ARRAY['linux','grep','find','awk','sed','sort']::TEXT[],$NOTE$## grep
```bash
grep -n 'error' app.log
grep -Ri 'server_name' /etc/nginx
grep -Ei 'error|warn|fail' app.log
```

## find
```bash
find /var/log -type f -name '*.log'
find . -type f -mtime -1
find . -type f -size +100M
```

## sort / uniq
```bash
sort file.txt
sort file.txt | uniq -c | sort -nr | head
```

## cut
```bash
cut -d: -f1 /etc/passwd
```

## awk
```bash
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head
```

## sed - xem range; thay thế nên backup trước
```bash
sed -n '1,80p' file.conf
sed 's/old/new/g' file.txt
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-packages','Linux 15: APT package trên Ubuntu/Debian','Update index, kiểm tra version, cài/gỡ package và xem file package.','linux','beginner','caution',ARRAY['linux','apt','dpkg','package','ubuntu']::TEXT[],$NOTE$## Refresh package index
```bash
sudo apt update
```

## Tìm / xem version
```bash
apt search nginx
apt-cache policy nginx
apt list --installed | grep nginx
```

## Cài / nâng cấp package cụ thể
```bash
sudo apt install <PACKAGE>
sudo apt install --only-upgrade <PACKAGE>
```

## Package chứa file nào
```bash
dpkg -L <PACKAGE>
dpkg -S /path/to/file
```

## Gỡ ⚠️
```bash
sudo apt remove <PACKAGE>
sudo apt purge <PACKAGE>
```
> Trên production, đọc danh sách package APT sẽ remove trước khi xác nhận.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('linux-cron','Linux 16: Cron, timer và scheduled jobs','Xem cron của user/root và systemd timer để biết job nào chạy định kỳ.','linux','beginner','safe',ARRAY['linux','cron','systemd-timer','schedule']::TEXT[],$NOTE$## Cron user hiện tại
```bash
crontab -l
crontab -e
```

## Cron root
```bash
sudo crontab -l
```

## System cron
```bash
ls -lah /etc/cron.d /etc/cron.daily /etc/cron.hourly
```

## Systemd timers
```bash
systemctl list-timers --all
```

## Cú pháp cron
```text
* * * * * command
│ │ │ │ └─ day of week
│ │ │ └── month
│ │ └──── day of month
│ └────── hour
└──────── minute
```

Ví dụ 02:30 mỗi ngày:
```cron
30 2 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('k8s-basics','Kubernetes 01: kubectl cơ bản cần thuộc','Cluster, node, namespace, pod, deployment, service, describe và logs.','kubernetes','beginner','safe',ARRAY['kubernetes','kubectl','pod','node','deployment','service']::TEXT[],$NOTE$![Sơ đồ Kubernetes HA](/illustrations/kubernetes-ha.svg)

## Context / cluster
```bash
kubectl config current-context
kubectl config get-contexts
kubectl cluster-info
kubectl version
```

## Node
```bash
kubectl get nodes
kubectl get nodes -o wide
kubectl describe node <NODE>
kubectl top nodes
```

## Namespace
```bash
kubectl get ns
kubectl get all -n <NAMESPACE>
```

## Pod
```bash
kubectl get pods -A
kubectl get pods -n <NAMESPACE> -o wide
kubectl describe pod <POD> -n <NAMESPACE>
kubectl logs <POD> -n <NAMESPACE> --tail=200
kubectl logs -f <POD> -n <NAMESPACE>
```

## Deployment / service
```bash
kubectl get deploy,svc -n <NAMESPACE>
kubectl rollout status deploy/<DEPLOYMENT> -n <NAMESPACE>
```

## Events
```bash
kubectl get events -A --sort-by=.lastTimestamp
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('k8s-pod-debug','Kubernetes 02: Troubleshoot Pod Pending / CrashLoop / Error','Quy trình get → describe → events → logs → exec để tìm nguyên nhân pod lỗi.','kubernetes','beginner','safe',ARRAY['kubernetes','pod','troubleshooting','logs','describe']::TEXT[],$NOTE$## 1. Xem trạng thái
```bash
kubectl get pod <POD> -n <NAMESPACE> -o wide
```

## 2. Describe - đặc biệt Events
```bash
kubectl describe pod <POD> -n <NAMESPACE>
```

## 3. Logs
```bash
kubectl logs <POD> -n <NAMESPACE> --tail=200
kubectl logs <POD> -c <CONTAINER> -n <NAMESPACE> --tail=200
kubectl logs <POD> -n <NAMESPACE> --previous
```
`--previous` rất hữu ích với CrashLoopBackOff vì xem log container lần chạy trước.

## 4. Exec
```bash
kubectl exec -it <POD> -n <NAMESPACE> -- sh
```

## 5. Events
```bash
kubectl get events -n <NAMESPACE> --sort-by=.lastTimestamp
```

## Gợi ý theo trạng thái
- `Pending`: resource, PVC, node selector/taint, scheduler
- `ImagePullBackOff`: image/tag/registry secret
- `CrashLoopBackOff`: app start lỗi → logs + previous logs
- `OOMKilled`: memory limit / memory leak
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('k8s-deployment','Kubernetes 03: Deployment, rollout và rollback','Scale, xem rollout, history, undo và image hiện tại.','kubernetes','beginner','caution',ARRAY['kubernetes','deployment','rollout','rollback','scale']::TEXT[],$NOTE$## Xem deployment
```bash
kubectl get deploy -n <NAMESPACE>
kubectl describe deploy <DEPLOYMENT> -n <NAMESPACE>
```

## Replica
```bash
kubectl scale deploy/<DEPLOYMENT> --replicas=3 -n <NAMESPACE>
```

## Rollout
```bash
kubectl rollout status deploy/<DEPLOYMENT> -n <NAMESPACE>
kubectl rollout history deploy/<DEPLOYMENT> -n <NAMESPACE>
```

## Restart rollout
```bash
kubectl rollout restart deploy/<DEPLOYMENT> -n <NAMESPACE>
```

## Rollback ⚠️
```bash
kubectl rollout undo deploy/<DEPLOYMENT> -n <NAMESPACE>
kubectl rollout undo deploy/<DEPLOYMENT> --to-revision=<REVISION> -n <NAMESPACE>
```

## Verify
```bash
kubectl get pods -n <NAMESPACE> -o wide
kubectl rollout status deploy/<DEPLOYMENT> -n <NAMESPACE>
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('k8s-network','Kubernetes 04: Service, Endpoints và Ingress','Kiểm tra đường request từ Ingress/Service tới Pod.','kubernetes','beginner','safe',ARRAY['kubernetes','service','ingress','endpoint','network']::TEXT[],$NOTE$## Service
```bash
kubectl get svc -n <NAMESPACE>
kubectl describe svc <SERVICE> -n <NAMESPACE>
```

## Endpoint phía sau service
```bash
kubectl get endpoints -n <NAMESPACE>
kubectl get endpointslice -n <NAMESPACE>
```
Nếu service không có endpoint, kiểm tra selector của Service có match label Pod không.

## Ingress
```bash
kubectl get ingress -A
kubectl describe ingress <INGRESS> -n <NAMESPACE>
```

## Label / selector
```bash
kubectl get pod -n <NAMESPACE> --show-labels
kubectl get svc <SERVICE> -n <NAMESPACE> -o yaml
```

## Test từ trong cluster
```bash
kubectl run curl-test --rm -it --restart=Never --image=curlimages/curl -- sh
curl -v http://<SERVICE>.<NAMESPACE>.svc.cluster.local:<PORT>/
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('k8s-config','Kubernetes 05: ConfigMap, Secret và env','Xem resource cấu hình và xác định chúng được mount/inject vào Pod ra sao.','kubernetes','beginner','caution',ARRAY['kubernetes','configmap','secret','env','volume']::TEXT[],$NOTE$## Liệt kê
```bash
kubectl get configmap -n <NAMESPACE>
kubectl get secret -n <NAMESPACE>
```

## Xem ConfigMap
```bash
kubectl describe configmap <NAME> -n <NAMESPACE>
kubectl get configmap <NAME> -n <NAMESPACE> -o yaml
```

## Secret
```bash
kubectl describe secret <NAME> -n <NAMESPACE>
```
> Không copy secret thật vào sổ tay, chat, issue hoặc Git.

## Pod đang dùng config nào?
```bash
kubectl get pod <POD> -n <NAMESPACE> -o yaml
```
Tìm các mục `env`, `envFrom`, `volumes`, `volumeMounts`.

## Sau khi config thay đổi
Không phải ứng dụng nào cũng tự reload. Có thể cần rollout restart deployment sau khi đã xác nhận thay đổi.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('k8s-storage','Kubernetes 06: PVC, PV và StorageClass','Kiểm tra volume khi pod Pending/MountVolume lỗi.','kubernetes','beginner','safe',ARRAY['kubernetes','pvc','pv','storageclass','storage']::TEXT[],$NOTE$## StorageClass
```bash
kubectl get storageclass
```

## PVC/PV
```bash
kubectl get pvc -A
kubectl get pv
kubectl describe pvc <PVC> -n <NAMESPACE>
kubectl describe pv <PV>
```

## Pod mount volume gì?
```bash
kubectl describe pod <POD> -n <NAMESPACE>
kubectl get pod <POD> -n <NAMESPACE> -o yaml
```

## 🐛 PVC Pending
Kiểm tra:
1. StorageClass tồn tại không
2. provisioner có chạy không
3. access mode / size có phù hợp không
4. events của PVC

## ⚠️ Lưu ý MicroK8s hostpath
Hostpath là storage local theo node; trước khi drain/remove node phải biết workload stateful đang phụ thuộc dữ liệu local nào.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('k8s-node-maintenance','Kubernetes 07: Cordon, drain và uncordon node','Đưa node ra bảo trì an toàn bằng cách ngăn schedule rồi evict workload.','kubernetes','beginner','caution',ARRAY['kubernetes','node','cordon','drain','uncordon']::TEXT[],$NOTE$## Trước khi drain
```bash
kubectl get nodes -o wide
kubectl get pods -A -o wide --field-selector spec.nodeName=<NODE>
```

## Cordon
```bash
kubectl cordon <NODE>
```
Node vẫn chạy pod cũ nhưng scheduler không đặt pod mới lên node.

## Drain
```bash
kubectl drain <NODE> --ignore-daemonsets
```
Nếu pod dùng `emptyDir` và bạn chấp nhận mất dữ liệu local tạm đó:
```bash
kubectl drain <NODE> --ignore-daemonsets --delete-emptydir-data
```
> `--delete-emptydir-data` có thể xóa dữ liệu `emptyDir`. Đọc output trước khi xác nhận dùng trong production.

## Bảo trì xong
```bash
kubectl uncordon <NODE>
```

## Verify
```bash
kubectl get nodes
kubectl get pods -A -o wide
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('k8s-microk8s-ha','Kubernetes 08: MicroK8s 3 master - add/remove node an toàn','Runbook riêng cho cụm MicroK8s có 3 control-plane: kiểm tra HA, add replacement, drain, leave/remove và verify.','kubernetes','intermediate','caution',ARRAY['kubernetes','microk8s','ha','master','control-plane','add-node','remove-node','drain']::TEXT[],$NOTE$![MicroK8s 3 control-plane](/illustrations/kubernetes-ha.svg)

## 🎯 Tình huống
Bạn có **3 node đều chạy control-plane**. Với MicroK8s, cụm từ 3 node trở lên dùng HA datastore và chịu được một node lỗi.

> Nếu bạn remove 1 node khỏi đúng cụm 3 node thì chỉ còn 2 node, cụm **không còn điều kiện 3+ node để giữ HA**. Nếu mục tiêu là thay máy mà vẫn muốn giữ HA, nên **add node mới trước**, chờ Ready/HA ổn rồi mới remove node cũ.

## 1. Kiểm tra trước khi làm - chạy trên node còn khỏe
```bash
microk8s status
microk8s kubectl get nodes -o wide
microk8s kubectl get pods -A -o wide
```
Trong `microk8s status`, kiểm tra có `high-availability: yes` và danh sách datastore node.

## 2A. Add một control-plane node mới
Trên một node đang ở cluster:
```bash
microk8s add-node
```
Lệnh sẽ in ra command `microk8s join ...`.

Trên node mới, chạy command join **không thêm `--worker`** nếu muốn node mới tham gia control-plane:
```bash
microk8s join <CLUSTER_IP>:25000/<TOKEN>/<TOKEN>
```

Verify:
```bash
microk8s kubectl get nodes -o wide
microk8s status
```
Chờ node `Ready`; nếu đang thay node trong cụm HA, xác nhận HA/datastore đã ổn trước khi remove node cũ.

## 2B. Drain node cũ trước khi remove
Từ node còn lại:
```bash
microk8s kubectl get pods -A -o wide --field-selector spec.nodeName=<OLD_NODE>
microk8s kubectl cordon <OLD_NODE>
microk8s kubectl drain <OLD_NODE> --ignore-daemonsets
```
Nếu drain báo pod dùng `emptyDir` và bạn **đã xác nhận có thể mất dữ liệu tạm**:
```bash
microk8s kubectl drain <OLD_NODE> --ignore-daemonsets --delete-emptydir-data
```

## 3. Cho node cũ rời cluster
**Trên chính node cần remove:**
```bash
microk8s leave
```
Theo MicroK8s, node rời sẽ trở về trạng thái single-node MicroK8s của riêng nó.

## 4. Xóa membership ở cluster còn lại
**Trên một node còn ở cluster:**
```bash
microk8s remove-node <OLD_NODE_IP_OR_NAME>
```
Dùng tên/IP đúng như cluster nhận diện; đối chiếu với `get nodes -o wide` và output cluster trước khi chạy.

## 5. Verify sau remove
```bash
microk8s kubectl get nodes -o wide
microk8s kubectl get pods -A -o wide
microk8s status
```
Nếu mục tiêu cuối vẫn là HA, đảm bảo cluster có ít nhất 3 node control-plane và `microk8s status` báo HA.

## ↩️ Join lại node
Trên node đang trong cluster:
```bash
microk8s add-node
```
Sau đó chạy command join mới trên node cần thêm lại.

## ⚠️ Checklist trước production
- kiểm tra workload stateful/PVC có phụ thuộc local storage của node không
- kiểm tra PodDisruptionBudget có chặn drain không
- không remove 2 control-plane node cùng lúc
- giữ console/SSH tới các node còn lại
- backup cấu hình quan trọng trước thay đổi
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('k8s-cronjob','Kubernetes 09: CronJob và Job','Xem lịch, lần chạy gần nhất, tạo Job thủ công và đọc log.','kubernetes','beginner','caution',ARRAY['kubernetes','cronjob','job','schedule','logs']::TEXT[],$NOTE$## Liệt kê
```bash
kubectl get cronjob -n <NAMESPACE>
kubectl get jobs -n <NAMESPACE>
```

## Chi tiết
```bash
kubectl describe cronjob <CRONJOB> -n <NAMESPACE>
kubectl get cronjob <CRONJOB> -n <NAMESPACE> -o yaml
```

## Pod của Job
```bash
kubectl get pods -n <NAMESPACE> -l job-name=<JOB>
kubectl logs job/<JOB> -n <NAMESPACE>
```

## Tạo Job chạy ngay từ CronJob
```bash
kubectl create job --from=cronjob/<CRONJOB> <MANUAL_JOB_NAME> -n <NAMESPACE>
```

## Suspend / resume ⚠️
```bash
kubectl patch cronjob <CRONJOB> -n <NAMESPACE> -p '{"spec":{"suspend":true}}'
kubectl patch cronjob <CRONJOB> -n <NAMESPACE> -p '{"spec":{"suspend":false}}'
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('docker-basics','Docker 01: Container cơ bản','ps, inspect, logs, exec, stats, start/stop/restart và exit code.','docker','beginner','caution',ARRAY['docker','container','logs','exec','inspect']::TEXT[],$NOTE$![Docker flow](/illustrations/docker-flow.svg)

## List
```bash
docker ps
docker ps -a
```

## Inspect
```bash
docker inspect <CONTAINER>
docker inspect -f '{{.State.Status}} {{.State.ExitCode}}' <CONTAINER>
```

## Logs
```bash
docker logs --tail 200 <CONTAINER>
docker logs -f <CONTAINER>
```

## Exec
```bash
docker exec -it <CONTAINER> sh
```

## Resource
```bash
docker stats
```

## Lifecycle
```bash
docker start <CONTAINER>
docker stop <CONTAINER>
docker restart <CONTAINER>
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('docker-images','Docker 02: Image, build và registry','List/pull/build/tag/push và xem layer/history.','docker','beginner','caution',ARRAY['docker','image','build','registry','push']::TEXT[],$NOTE$## Images
```bash
docker images
docker image ls
docker image inspect <IMAGE>
docker history <IMAGE>
```

## Pull/build
```bash
docker pull nginx:alpine
docker build -t myapp:dev .
```

## Tag / push
```bash
docker tag myapp:dev registry.example.com/team/myapp:dev
docker push registry.example.com/team/myapp:dev
```

## Remove image ⚠️
```bash
docker image rm <IMAGE>
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('docker-storage-network','Docker 03: Volume, network và port','Hiểu data persistent, port publish và network giữa container.','docker','beginner','safe',ARRAY['docker','volume','network','port','mount']::TEXT[],$NOTE$## Volume
```bash
docker volume ls
docker volume inspect <VOLUME>
```

## Network
```bash
docker network ls
docker network inspect <NETWORK>
```

## Port mapping
```bash
docker port <CONTAINER>
docker ps --format 'table {{.Names}}\t{{.Ports}}'
```
`127.0.0.1:3000:3000` chỉ publish ra loopback của host; `3000:3000` thường listen trên mọi interface host.

## Inspect mount/network
```bash
docker inspect <CONTAINER> --format '{{json .Mounts}}'
docker inspect <CONTAINER> --format '{{json .NetworkSettings.Networks}}'
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('docker-compose','Docker 04: Docker Compose vận hành hằng ngày','up/down/ps/logs/config/exec/pull/build và cách tránh xóa volume.','docker','beginner','caution',ARRAY['docker','compose','logs','build','volume']::TEXT[],$NOTE$## Validate config
```bash
docker compose config
```

## Start / status
```bash
docker compose up -d
docker compose ps
```

## Logs
```bash
docker compose logs --tail=200
docker compose logs -f app
```

## Exec
```bash
docker compose exec app sh
```

## Rebuild
```bash
docker compose up -d --build
```

## Stop
```bash
docker compose stop
docker compose down
```
> `docker compose down -v` xóa named volume của project. Không chạy trên production nếu chưa backup/hiểu dữ liệu.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('docker-disk','Docker 05: Disk usage và cleanup an toàn','Xem Docker chiếm bao nhiêu disk trước khi prune.','docker','beginner','caution',ARRAY['docker','disk','prune','cleanup']::TEXT[],$NOTE$## Usage
```bash
docker system df
docker system df -v
```

## Container/image dangling
```bash
docker ps -a
docker image ls -f dangling=true
docker volume ls -f dangling=true
```

## Cleanup từng loại
```bash
docker container prune
docker image prune
docker network prune
```

## Cleanup rộng hơn ⚠️
```bash
docker system prune
```
> Không thêm `-a` hoặc `--volumes` theo thói quen. Kiểm tra volume và image cần rollback trước.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('gitlab-basics','GitLab CI 01: Pipeline, stage, job, rules','Mental model cơ bản của .gitlab-ci.yml và cách kiểm tra pipeline.','gitlab-ci','beginner','safe',ARRAY['gitlab','cicd','pipeline','rules','job','stage']::TEXT[],$NOTE$![CI/CD flow](/illustrations/cicd-flow.svg)

## Mental model
```text
commit/tag → workflow/rules → pipeline → stages → jobs → runner
```

## Ví dụ
```yaml
stages: [test, build, deploy]

build:
  stage: build
  script:
    - npm ci
    - npm run build
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

## Cần hiểu
- `workflow: rules`: có tạo pipeline hay không
- `rules`: job có xuất hiện/chạy hay không
- `stage`: thứ tự nhóm job
- `needs`: dependency giữa job
- `artifacts`: file chuyển sang job khác / tải về
- `variables`: biến CI
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('gitlab-runner-tags','GitLab CI 02: Runner và tags','Runner chỉ nhận job khi có đầy đủ tất cả tag mà job yêu cầu.','gitlab-ci','beginner','safe',ARRAY['gitlab','runner','tags','pipeline','stuck']::TEXT[],$NOTE$## Ví dụ job
```yaml
build:
  tags:
    - frontend
    - office
```
Runner cần có **cả `frontend` và `office`**. Runner có thêm tag khác không sao.

## Runner trên host
```bash
gitlab-runner --version
sudo gitlab-runner status
sudo gitlab-runner list
```

## Nếu runner chạy Docker
```bash
docker ps | grep gitlab-runner
docker logs --tail 200 <RUNNER_CONTAINER>
```

## Job stuck - check
- runner online/paused
- tags match
- protected branch/tag policy
- executor tạo container/shell được không
- concurrent limit
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('gitlab-debug','GitLab CI 03: Debug pipeline thất bại','Checklist đọc log từ lỗi syntax/rules đến build, registry và deploy.','gitlab-ci','beginner','caution',ARRAY['gitlab','debug','pipeline','variables','runner']::TEXT[],$NOTE$## Trước tiên xác định tầng lỗi
1. pipeline không được tạo → `workflow: rules`
2. job không xuất hiện → `rules/only/except`
3. job stuck → runner/tags
4. job chạy rồi fail → đọc log command đầu tiên exit non-zero

## Trong script
```bash
set -euxo pipefail
```
Chỉ bật `-x` khi log không chứa secret nhạy cảm.

## Một số biến hữu ích
```bash
echo "$CI_COMMIT_BRANCH"
echo "$CI_COMMIT_TAG"
echo "$CI_PIPELINE_SOURCE"
echo "$CI_JOB_NAME"
```

## Registry
```bash
docker login "$CI_REGISTRY" -u "$CI_REGISTRY_USER" --password-stdin
```
Không echo token/password thật ra log.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('nginx-basics','Nginx 01: Đọc config và request flow','Từ nginx.conf → sites-enabled → server_name/location → upstream.','nginx','beginner','safe',ARRAY['nginx','config','server-name','location','upstream']::TEXT[],$NOTE$![Nginx request flow](/illustrations/nginx-flow.svg)

## Version / config path
```bash
nginx -v
nginx -V
```

## Main config
```bash
sudo less /etc/nginx/nginx.conf
ls -lah /etc/nginx/sites-enabled/
ls -lah /etc/nginx/sites-available/
```

## Tìm domain
```bash
sudo grep -Rni 'server_name.*example.com' /etc/nginx
```

## Full rendered config
```bash
sudo nginx -T
```
`nginx -T` vừa test vừa in config đã include; rất hữu ích khi không biết directive đến từ file nào.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('nginx-reload','Nginx 02: Sửa config và reload an toàn','Luôn nginx -t trước reload; sau đó kiểm tra status/log/curl.','nginx','beginner','caution',ARRAY['nginx','reload','nginx-t','curl','virtual-host']::TEXT[],$NOTE$## Backup file trước sửa
```bash
sudo cp /etc/nginx/sites-available/example.conf /etc/nginx/sites-available/example.conf.bak
```

## Test syntax
```bash
sudo nginx -t
```
Chỉ reload khi output báo syntax OK và test successful.

## Reload
```bash
sudo systemctl reload nginx
```

## Verify
```bash
systemctl status nginx --no-pager
sudo tail -n 100 /var/log/nginx/error.log
curl -I http://127.0.0.1
```

## Test đúng virtual host
```bash
curl -I -H 'Host: example.com' http://127.0.0.1
curl -kI --resolve example.com:443:127.0.0.1 https://example.com/
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('nginx-logs','Nginx 03: Access log, error log và upstream 502/504','Các lệnh đọc log và phân biệt Nginx lỗi hay app upstream lỗi.','nginx','beginner','safe',ARRAY['nginx','logs','502','504','upstream']::TEXT[],$NOTE$## Logs
```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Tìm status lỗi
```bash
sudo grep ' 500 ' /var/log/nginx/access.log | tail
sudo grep ' 502 ' /var/log/nginx/access.log | tail
sudo grep ' 504 ' /var/log/nginx/access.log | tail
```

## Nếu 502/504
1. app upstream có chạy không
```bash
sudo ss -lntp | grep ':3000'
curl -v http://127.0.0.1:3000/health
```
2. xem error log Nginx
3. xem log app
4. kiểm tra DNS/network nếu upstream là host khác
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('monitoring-basics','Monitoring 01: Checklist CPU RAM Disk Service','Bộ chỉ số tối thiểu khi dashboard báo server có vấn đề.','monitoring','beginner','safe',ARRAY['monitoring','cpu','ram','disk','health']::TEXT[],$NOTE$![Monitoring flow](/illustrations/monitoring-flow.svg)

## CPU / load
```bash
uptime
top
```

## RAM
```bash
free -h
vmstat 1 5
```

## Disk
```bash
df -h
df -i
```

## Service / port
```bash
systemctl --failed
sudo ss -lntup
```

## Nguyên tắc
Dashboard cho biết **symptom**. Sau đó phải quay về host/container/pod và xem log + trạng thái thực tế trước khi thay đổi.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('monitoring-prometheus','Monitoring 02: Prometheus cơ bản','Kiểm tra target, metric endpoint và các PromQL dễ dùng.','monitoring','beginner','safe',ARRAY['monitoring','prometheus','promql','metrics','exporter']::TEXT[],$NOTE$## Metric endpoint của exporter/app
```bash
curl -s http://127.0.0.1:<PORT>/metrics | head
```

## PromQL cơ bản
```promql
up
rate(http_requests_total[5m])
rate(node_cpu_seconds_total{mode!="idle"}[5m])
node_memory_MemAvailable_bytes
```

## Khi target DOWN
- DNS/IP target đúng không
- port có listen không
- firewall/network
- `/metrics` trả HTTP 200 không
- Prometheus scrape config / service discovery
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('monitoring-grafana','Monitoring 03: Grafana - đọc dashboard và alert','Cách đọc time range, datasource, query và alert trước khi kết luận hệ thống lỗi.','monitoring','beginner','safe',ARRAY['monitoring','grafana','alert','dashboard']::TEXT[],$NOTE$## Khi panel "No data"
1. kiểm tra time range
2. datasource đúng không
3. mở Query inspector
4. chạy query trực tiếp trên datasource/Explore
5. kiểm tra label/filter dashboard variable

## Khi alert firing
Ghi lại:
- thời điểm bắt đầu
- metric/threshold
- instance/service
- thay đổi/deploy gần đó
- log cùng thời gian

## Sau khi xử lý
Không chỉ nhìn alert hết đỏ; verify bằng request thật hoặc health check của service.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('db-postgres','Database 01: PostgreSQL - kiểm tra cơ bản','Connect, database/schema/table, connection, size và query đang chạy.','database','beginner','safe',ARRAY['database','postgresql','psql','size','connection']::TEXT[],$NOTE$![Database ops](/illustrations/database-flow.svg)

## Connect
```bash
psql -h <HOST> -p 5432 -U <USER> -d <DB>
```

## Trong psql
```text
\l
\c <DB>
\dn
\dt
\d <TABLE>
\x
```

## Connection / activity
```sql
SELECT pid, usename, datname, state, client_addr, query_start, left(query,120)
FROM pg_stat_activity
ORDER BY query_start;
```

## Database size
```sql
SELECT pg_size_pretty(pg_database_size(current_database()));
```

## Table sizes
```sql
SELECT relname, pg_size_pretty(pg_total_relation_size(relid)) AS size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 20;
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('db-mysql','Database 02: MySQL/MariaDB - kiểm tra cơ bản','Connect, database/table, processlist, size và version.','database','beginner','safe',ARRAY['database','mysql','mariadb','processlist']::TEXT[],$NOTE$## Connect
```bash
mysql -h <HOST> -P 3306 -u <USER> -p
```

## Cơ bản
```sql
SELECT VERSION();
SHOW DATABASES;
USE <DB>;
SHOW TABLES;
DESCRIBE <TABLE>;
SHOW FULL PROCESSLIST;
```

## DB size
```sql
SELECT table_schema,
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS mb
FROM information_schema.tables
GROUP BY table_schema
ORDER BY mb DESC;
```

## Service trên Linux
```bash
systemctl status mysql --no-pager
sudo ss -lntp | grep ':3306'
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('db-mongo','Database 03: MongoDB - kiểm tra cơ bản','Version, database, collection, connection và Docker log.','database','beginner','safe',ARRAY['database','mongodb','mongosh','docker']::TEXT[],$NOTE$## Nếu dùng mongosh
```bash
mongosh "mongodb://<HOST>:27017"
```

## Trong shell
```javascript
db.version()
show dbs
use <DB>
show collections
db.stats()
db.serverStatus().connections
```

## Docker
```bash
docker ps | grep -i mongo
docker logs --tail 200 <MONGO_CONTAINER>
docker stats <MONGO_CONTAINER>
```

## Port
```bash
sudo ss -lntp | grep ':27017'
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('db-backup','Database 04: Backup/restore PostgreSQL và MySQL','Lệnh dump/restore cơ bản; luôn verify file backup.','database','beginner','caution',ARRAY['database','backup','restore','pg_dump','mysqldump']::TEXT[],$NOTE$## PostgreSQL backup
```bash
pg_dump -h <HOST> -U <USER> -d <DB> -Fc -f backup.dump
ls -lh backup.dump
```

## PostgreSQL restore ⚠️
```bash
pg_restore -h <HOST> -U <USER> -d <TARGET_DB> backup.dump
```

## MySQL backup
```bash
mysqldump -h <HOST> -u <USER> -p --single-transaction <DB> > backup.sql
ls -lh backup.sql
```

## MySQL restore ⚠️
```bash
mysql -h <HOST> -u <USER> -p <TARGET_DB> < backup.sql
```

## Nguyên tắc
- restore vào DB test trước nếu có thể
- backup phải có timestamp
- kiểm tra exit code + file size
- dữ liệu nhạy cảm phải được bảo vệ/encrypt theo chính sách công ty
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('network-flow','Networking 01: Quy trình debug web không truy cập được','DNS → route → TCP port → TLS → HTTP → reverse proxy → app.','network','beginner','safe',ARRAY['network','dns','tcp','tls','http','curl']::TEXT[],$NOTE$![Network troubleshooting](/illustrations/network-flow.svg)

## 1. DNS
```bash
dig +short example.com
getent hosts example.com
```

## 2. TCP port
```bash
nc -vz example.com 80
nc -vz example.com 443
```

## 3. TLS
```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null
```

## 4. HTTP
```bash
curl -v http://example.com/
curl -vk https://example.com/
```

## 5. Trên server
```bash
sudo ss -lntp
systemctl status nginx --no-pager
curl -I http://127.0.0.1
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('network-dns','Networking 02: DNS cơ bản','A/AAAA/CNAME/NS, resolver local và kiểm tra propagation.','network','beginner','safe',ARRAY['network','dns','dig','resolver','ttl']::TEXT[],$NOTE$## Query
```bash
dig example.com
dig A example.com
dig AAAA example.com
dig CNAME www.example.com
dig NS example.com
```

## Hỏi resolver cụ thể
```bash
dig @1.1.1.1 example.com
dig @8.8.8.8 example.com
```

## Local resolver
```bash
cat /etc/resolv.conf
resolvectl status
```

## Theo chain DNS
```bash
dig +trace example.com
```

## 🧠 TTL
Sau khi đổi DNS, resolver cũ có thể giữ cache đến hết TTL. So sánh nhiều resolver trước khi kết luận bản ghi chưa cập nhật.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('network-routing','Networking 03: IP, subnet, route và interface','Các lệnh nhìn interface, default gateway, route tới một IP và neighbor.','network','beginner','safe',ARRAY['network','ip','route','subnet','interface']::TEXT[],$NOTE$## Interface/IP
```bash
ip -br link
ip -br addr
```

## Route
```bash
ip route
ip route get 8.8.8.8
```

## Neighbor/ARP
```bash
ip neigh
```

## Listening/connection
```bash
ss -lntup
ss -antp
```

## Path
```bash
ping -c 4 <IP>
tracepath <IP>
traceroute <IP>
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('network-tls','Networking 04: TLS/Certificate cơ bản','Xem certificate domain, SAN, issuer và hạn dùng từ command line.','network','beginner','safe',ARRAY['network','tls','ssl','certificate','openssl']::TEXT[],$NOTE$## Xem TLS handshake + cert
```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null
```

## Chỉ lấy thông tin cert
```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null 2>/dev/null \
| openssl x509 -noout -subject -issuer -dates -ext subjectAltName
```

## curl
```bash
curl -Iv https://example.com/
```

## Cert file local
```bash
openssl x509 -in fullchain.pem -noout -subject -issuer -dates
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('security-ssh','Security 01: SSH key và hardening cơ bản','Kiểm tra authorized_keys, quyền file và config sshd trước khi reload.','security','beginner','caution',ARRAY['security','ssh','key','sshd']::TEXT[],$NOTE$![Security flow](/illustrations/security-flow.svg)

## Key local
```bash
ls -lah ~/.ssh
ssh-keygen -lf ~/.ssh/id_ed25519.pub
```

## Server authorized keys
```bash
ls -lah ~/.ssh
cat ~/.ssh/authorized_keys
```

## Permission thường dùng
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Kiểm tra sshd config
```bash
sudo sshd -t
sudo sshd -T | less
```

> Khi sửa SSH remote, giữ một session đang mở và test session mới trước khi đóng kết nối cũ.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('security-firewall','Security 02: Firewall UFW cơ bản','Xem rule trước khi allow/deny; tránh tự khóa SSH.','security','beginner','caution',ARRAY['security','firewall','ufw','port']::TEXT[],$NOTE$## Status
```bash
sudo ufw status verbose
sudo ufw status numbered
```

## Allow
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

## Delete rule ⚠️
```bash
sudo ufw status numbered
sudo ufw delete <NUMBER>
```

## Nguyên tắc
Trước khi enable firewall trên server remote, chắc chắn rule SSH/Teleport/VPN cần thiết đã được allow.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('security-secrets','Security 03: Secret - những thứ không được lưu vào sổ tay','Checklist để tránh lộ token/password/private key trong note, Git và log.','security','beginner','safe',ARRAY['security','secret','token','password','git']::TEXT[],$NOTE$## Không lưu trực tiếp
- password
- API token
- GitLab runner token
- Vault token
- kubeconfig production
- SSH private key
- database connection string có password
- Kubernetes Secret decoded

## Dùng placeholder
```text
<SERVER_IP>
<USERNAME>
<PASSWORD>
<TOKEN>
<NAMESPACE>
<DB_NAME>
```

## Trước commit
```bash
git diff --staged
git status
```

Nếu secret đã commit/push, chỉ xóa file khỏi commit là chưa đủ: cần **rotate/revoke secret** và xử lý history theo quy trình của tổ chức.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('backup-files','Backup 01: tar, gzip và checksum','Archive thư mục, xem nội dung, extract và verify checksum.','backup','beginner','safe',ARRAY['backup','tar','gzip','sha256','restore']::TEXT[],$NOTE$![Backup lifecycle](/illustrations/backup-flow.svg)

## Tar gzip
```bash
tar -czf backup-$(date +%F).tar.gz /path/to/data
```

## Xem nội dung không extract
```bash
tar -tzf backup.tar.gz | head
```

## Extract
```bash
mkdir restore-test
tar -xzf backup.tar.gz -C restore-test
```

## Checksum
```bash
sha256sum backup.tar.gz > backup.tar.gz.sha256
sha256sum -c backup.tar.gz.sha256
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('backup-rsync','Backup 02: rsync giữa server và storage','Sync file có progress, dry-run và giữ permission/timestamp.','backup','beginner','caution',ARRAY['backup','rsync','sync','dry-run']::TEXT[],$NOTE$## Copy directory
```bash
rsync -avh --progress /data/ user@backup-server:/backup/data/
```

## Dry-run
```bash
rsync -avhn /data/ user@backup-server:/backup/data/
```

## Mirror có --delete ⚠️
```bash
rsync -avhn --delete /data/ user@backup-server:/backup/data/
# chỉ bỏ -n sau khi output đúng
```

## Verify nhanh
```bash
du -sh /data/
ssh user@backup-server 'du -sh /backup/data/'
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('backup-checklist','Backup 03: Checklist backup/restore production','Những câu phải trả lời trước khi gọi một quy trình là backup hoàn chỉnh.','backup','beginner','safe',ARRAY['backup','restore','rpo','rto','checklist']::TEXT[],$NOTE$## Checklist
- backup **cái gì**? file, database, object storage, config
- lưu **ở đâu**? có khác host/zone không
- retention bao lâu
- có encrypt không
- có checksum/integrity check không
- backup có log/alert khi fail không
- restore đã test lần gần nhất khi nào
- RPO/RTO mong muốn là gì

## Verify kỹ thuật
```bash
ls -lh <BACKUP_FILE>
sha256sum <BACKUP_FILE>
```

## Quy tắc
Một backup chưa từng restore thử chỉ là **một file mà bạn hy vọng dùng được**.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('troubleshoot-method','Troubleshooting 01: Quy trình debug không đoán mò','Symptom → phạm vi → bằng chứng → thay đổi nhỏ → verify → ghi lại.','troubleshooting','beginner','safe',ARRAY['troubleshooting','debug','incident','verify']::TEXT[],$NOTE$![Troubleshooting loop](/illustrations/troubleshooting-flow.svg)

## 1. Xác định symptom
- ai bị ảnh hưởng
- bắt đầu lúc nào
- tất cả request hay một phần
- production/uat/dev

## 2. Có thay đổi gần đây không?
- deploy
- config
- DNS
- certificate
- firewall
- package update

## 3. Thu thập bằng chứng
```bash
uptime
free -h
df -h
systemctl --failed
sudo ss -lntup
```
Sau đó vào log của đúng service.

## 4. Thay đổi nhỏ nhất có thể
Mỗi lần chỉ đổi một thứ nếu có thể, để biết fix nào thật sự có tác dụng.

## 5. Verify bằng cùng test ban đầu
Nếu user báo URL lỗi, sau fix hãy test đúng URL/path/domain đó, không chỉ nhìn service `active`.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('troubleshoot-web','Troubleshooting 02: Web không vào được nhưng SSH server vẫn được','Checklist DNS, firewall, port, Nginx, upstream và app.','troubleshooting','beginner','safe',ARRAY['troubleshooting','web','nginx','dns','port']::TEXT[],$NOTE$## Từ máy client
```bash
dig +short example.com
nc -vz example.com 443
curl -vk https://example.com/
```

## Trên server
```bash
sudo ss -lntp | grep -E ':80|:443'
systemctl status nginx --no-pager
sudo nginx -t
```

## Local Nginx
```bash
curl -I -H 'Host: example.com' http://127.0.0.1
```

## Nếu reverse proxy
```bash
sudo grep -Rni 'proxy_pass' /etc/nginx
curl -v http://127.0.0.1:<APP_PORT>/
```

## Logs
```bash
sudo tail -n 100 /var/log/nginx/error.log
sudo tail -n 100 /var/log/nginx/access.log
```
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);


INSERT INTO notes (seed_key,title,summary,category,difficulty,danger_level,tags,content,last_tested_at)
VALUES ('troubleshoot-disk','Troubleshooting 03: Server đầy disk','Runbook từ df/du/lsof đến Docker logs mà không xóa nhầm dữ liệu.','troubleshooting','beginner','caution',ARRAY['troubleshooting','disk','full','docker','log']::TEXT[],$NOTE$## 1. Xác nhận
```bash
df -h
df -i
```

## 2. Khoanh vùng
```bash
sudo du -xhd1 / 2>/dev/null | sort -h
sudo du -xhd1 /var 2>/dev/null | sort -h
```

## 3. File lớn
```bash
sudo find /var -xdev -type f -size +1G -ls 2>/dev/null
```

## 4. Deleted but open
```bash
sudo lsof +L1
```

## 5. Docker
```bash
docker system df -v
sudo du -sh /var/lib/docker/* 2>/dev/null | sort -h
```

## ⚠️ Không làm theo thói quen
Đừng `rm -rf /var/lib/docker`, xóa DB log/data file, hoặc truncate file nếu chưa biết process/retention/backup.
$NOTE$,NULL)
ON CONFLICT (seed_key) WHERE seed_key IS NOT NULL DO UPDATE SET
  title=EXCLUDED.title,
  summary=EXCLUDED.summary,
  category=EXCLUDED.category,
  difficulty=EXCLUDED.difficulty,
  danger_level=EXCLUDED.danger_level,
  tags=EXCLUDED.tags,
  content=EXCLUDED.content,
  last_tested_at=COALESCE(notes.last_tested_at, EXCLUDED.last_tested_at);
