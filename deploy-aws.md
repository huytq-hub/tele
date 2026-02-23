# Hướng dẫn Deploy lên AWS Server

## 🚀 Deploy 1 Click

### Bước 1: Upload code lên server
```bash
# Từ máy local, upload code lên EC2
scp -r -i your-key.pem ./* ec2-user@your-server-ip:/home/ec2-user/bot/

# Hoặc dùng Git
ssh -i your-key.pem ec2-user@your-server-ip
git clone <repository-url>
cd <project-folder>
```

### Bước 2: Cấu hình .env
```bash
nano .env
# Điền đầy đủ: BOT_TOKEN, ADMIN_IDS, BINANCE_API_KEY, etc.
```

### Bước 3: Chạy 1 lệnh duy nhất
```bash
bash deploy.sh
```

Script sẽ tự động:
- ✅ Cài đặt Docker & Docker Compose (nếu chưa có)
- ✅ Kiểm tra file .env
- ✅ Build Docker image
- ✅ Chạy bot
- ✅ Hiển thị logs

## 📝 Các lệnh quản lý nhanh

```bash
bash deploy.sh   # Deploy/Restart bot
bash logs.sh     # Xem logs real-time
bash stop.sh     # Dừng bot
bash update.sh   # Update code mới và restart
bash backup.sh   # Backup database
```

---

## 📖 Hướng dẫn chi tiết

## Yêu cầu
- AWS EC2 instance (Ubuntu/Amazon Linux)
- File `.env` đã cấu hình đầy đủ

## Cài đặt thủ công Docker (nếu cần)

### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### Amazon Linux 2:
```bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
```

Sau đó logout và login lại để áp dụng quyền docker.

## Bước 2: Upload code lên server

### Cách 1: Sử dụng Git
```bash
git clone <repository-url>
cd <project-folder>
```

### Cách 2: Sử dụng SCP
```bash
# Từ máy local
scp -r -i your-key.pem ./* ec2-user@your-server-ip:/home/ec2-user/bot/
```

## Bước 3: Cấu hình file .env

Tạo file `.env` từ template:
```bash
cp .env.example .env
nano .env
```

Điền đầy đủ thông tin:
- BOT_TOKEN
- ADMIN_IDS
- BINANCE_API_KEY, BINANCE_SECRET_KEY
- SEPAY_API_KEY (nếu dùng)
- Các thông tin ngân hàng

## Bước 4: Build và chạy Docker

```bash
# Build image
docker-compose build

# Chạy container
docker-compose up -d

# Xem logs
docker-compose logs -f

# Kiểm tra trạng thái
docker-compose ps
```

## Bước 5: Quản lý container

### Dừng bot:
```bash
docker-compose down
```

### Khởi động lại:
```bash
docker-compose restart
```

### Xem logs:
```bash
docker-compose logs -f telegram-bot
```

### Update code mới:
```bash
git pull  # hoặc upload file mới
docker-compose down
docker-compose build
docker-compose up -d
```

## Bước 6: Backup database

```bash
# Backup
docker cp telegram-shop-bot:/app/data/shop.db ./backup-$(date +%Y%m%d).db

# Restore
docker cp backup-20240101.db telegram-shop-bot:/app/data/shop.db
docker-compose restart
```

## Lưu ý bảo mật

1. Mở port cần thiết trong Security Group của EC2
2. Không commit file `.env` lên Git
3. Backup database định kỳ
4. Sử dụng IAM roles thay vì hardcode credentials
5. Cập nhật hệ thống thường xuyên:
```bash
sudo apt update && sudo apt upgrade -y
```

## Troubleshooting

### Bot không chạy:
```bash
docker-compose logs telegram-bot
```

### Kiểm tra container:
```bash
docker ps -a
docker inspect telegram-shop-bot
```

### Vào trong container:
```bash
docker exec -it telegram-shop-bot sh
```

### Xóa và build lại:
```bash
docker-compose down
docker system prune -a
docker-compose up -d --build
```
