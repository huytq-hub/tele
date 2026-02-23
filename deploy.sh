#!/bin/bash

# Script deploy 1 click cho AWS EC2
# Chạy: bash deploy.sh

set -e

echo "🚀 Starting deployment..."

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Kiểm tra Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}📦 Docker chưa cài đặt. Đang cài đặt...${NC}"
    
    # Detect OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    fi
    
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt update
        sudo apt install -y docker.io docker-compose
    elif [ "$OS" = "amzn" ]; then
        sudo yum update -y
        sudo yum install -y docker
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo -e "${RED}❌ OS không được hỗ trợ. Vui lòng cài Docker thủ công.${NC}"
        exit 1
    fi
    
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}✅ Docker đã được cài đặt${NC}"
    echo -e "${YELLOW}⚠️  Vui lòng logout và login lại, sau đó chạy lại script này${NC}"
    exit 0
fi

# Kiểm tra docker-compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}📦 Docker Compose chưa cài đặt. Đang cài đặt...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose đã được cài đặt${NC}"
fi

# Kiểm tra file .env
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  File .env không tồn tại${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Đã tạo .env từ .env.example${NC}"
        echo -e "${RED}❌ Vui lòng cấu hình file .env trước khi tiếp tục!${NC}"
        echo -e "${YELLOW}Chạy: nano .env${NC}"
        exit 1
    else
        echo -e "${RED}❌ Không tìm thấy .env.example${NC}"
        exit 1
    fi
fi

# Kiểm tra BOT_TOKEN trong .env
if ! grep -q "BOT_TOKEN=.*[^[:space:]]" .env; then
    echo -e "${RED}❌ BOT_TOKEN chưa được cấu hình trong .env${NC}"
    echo -e "${YELLOW}Chạy: nano .env${NC}"
    exit 1
fi

# Tạo thư mục data nếu chưa có
mkdir -p data

# Hỏi user muốn chạy Docker hay Node trực tiếp
echo -e "${YELLOW}Chọn cách chạy:${NC}"
echo "1) Docker (khuyến nghị)"
echo "2) Node.js trực tiếp"
read -p "Nhập lựa chọn (1 hoặc 2): " choice

if [ "$choice" = "2" ]; then
    # Chạy trực tiếp với Node.js
    echo -e "${GREEN}📦 Installing dependencies...${NC}"
    npm install
    
    # Dừng process cũ nếu có
    pkill -f "node src/bot.js" || true
    
    echo -e "${GREEN}🚀 Starting bot with PM2...${NC}"
    
    # Cài PM2 nếu chưa có
    if ! command -v pm2 &> /dev/null; then
        npm install -g pm2
    fi
    
    # Chạy với PM2
    pm2 delete telegram-bot 2>/dev/null || true
    pm2 start src/bot.js --name telegram-bot
    pm2 save
    pm2 startup
    
    echo -e "${GREEN}✅ Bot đã chạy với PM2!${NC}"
    echo ""
    echo -e "${GREEN}📊 Xem logs:${NC} pm2 logs telegram-bot"
    echo -e "${GREEN}🛑 Dừng bot:${NC} pm2 stop telegram-bot"
    echo -e "${GREEN}🔄 Restart:${NC} pm2 restart telegram-bot"
    echo -e "${GREEN}📈 Monitor:${NC} pm2 monit"
    
else
    # Chạy với Docker
    # Dừng container cũ nếu đang chạy
    if [ "$(docker ps -q -f name=telegram-shop-bot)" ]; then
        echo -e "${YELLOW}🛑 Đang dừng container cũ...${NC}"
        docker-compose down
    fi

    # Build và chạy
    echo -e "${GREEN}🔨 Building Docker image...${NC}"
    docker-compose build

    echo -e "${GREEN}🚀 Starting bot...${NC}"
    docker-compose up -d
fi

# Đợi 3 giây để bot khởi động
sleep 3

# Kiểm tra trạng thái
if [ "$choice" = "2" ]; then
    # Kiểm tra PM2
    if pm2 list | grep -q "telegram-bot.*online"; then
        echo -e "${GREEN}✅ Bot đã chạy thành công!${NC}"
        echo ""
        echo -e "${YELLOW}📝 Logs hiện tại:${NC}"
        pm2 logs telegram-bot --lines 20 --nostream
    else
        echo -e "${RED}❌ Bot không chạy được. Kiểm tra logs:${NC}"
        pm2 logs telegram-bot --lines 50 --nostream
        exit 1
    fi
else
    # Kiểm tra Docker
    if [ "$(docker ps -q -f name=telegram-shop-bot)" ]; then
        echo -e "${GREEN}✅ Bot đã chạy thành công!${NC}"
        echo ""
        echo -e "${GREEN}📊 Xem logs:${NC} docker-compose logs -f"
        echo -e "${GREEN}🛑 Dừng bot:${NC} docker-compose down"
        echo -e "${GREEN}🔄 Restart:${NC} docker-compose restart"
        echo ""
        echo -e "${YELLOW}📝 Logs hiện tại:${NC}"
        docker-compose logs --tail=20
    else
        echo -e "${RED}❌ Bot không chạy được. Kiểm tra logs:${NC}"
        docker-compose logs
        exit 1
    fi
fi
