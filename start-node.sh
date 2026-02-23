#!/bin/bash

# Script chạy bot trực tiếp với Node.js (không dùng Docker)
# Chạy: bash start-node.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🚀 Starting bot with Node.js...${NC}"

# Kiểm tra Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js chưa được cài đặt!${NC}"
    echo -e "${YELLOW}Cài đặt Node.js:${NC}"
    echo "Ubuntu/Debian: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt install -y nodejs"
    echo "Amazon Linux: sudo yum install -y nodejs npm"
    exit 1
fi

# Kiểm tra .env
if [ ! -f .env ]; then
    echo -e "${RED}❌ File .env không tồn tại!${NC}"
    exit 1
fi

# Cài dependencies
if [ ! -d node_modules ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    npm install
fi

# Cài PM2 nếu chưa có
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}📦 Installing PM2...${NC}"
    npm install -g pm2
fi

# Dừng bot cũ nếu đang chạy
pm2 delete telegram-bot 2>/dev/null || true

# Khởi động bot
echo -e "${GREEN}✅ Starting bot...${NC}"
pm2 start src/bot.js --name telegram-bot --time

# Lưu cấu hình PM2
pm2 save

# Setup auto-start khi reboot
pm2 startup

echo ""
echo -e "${GREEN}✅ Bot đã chạy thành công!${NC}"
echo ""
echo -e "${GREEN}📊 Xem logs:${NC} pm2 logs telegram-bot"
echo -e "${GREEN}🛑 Dừng bot:${NC} pm2 stop telegram-bot"
echo -e "${GREEN}🔄 Restart:${NC} pm2 restart telegram-bot"
echo -e "${GREEN}📈 Monitor:${NC} pm2 monit"
echo -e "${GREEN}📋 List:${NC} pm2 list"
echo ""
echo -e "${YELLOW}📝 Logs hiện tại:${NC}"
pm2 logs telegram-bot --lines 20 --nostream
