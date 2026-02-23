#!/bin/bash

# Script update code và restart bot
# Chạy: bash update.sh

set -e

echo "🔄 Updating bot..."

# Màu sắc
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Pull code mới (nếu dùng git)
if [ -d .git ]; then
    echo -e "${YELLOW}📥 Pulling latest code...${NC}"
    git pull
fi

# Backup database
if [ -f data/shop.db ]; then
    echo -e "${YELLOW}💾 Backing up database...${NC}"
    cp data/shop.db data/shop.db.backup-$(date +%Y%m%d-%H%M%S)
    echo -e "${GREEN}✅ Database backed up${NC}"
fi

# Rebuild và restart
echo -e "${YELLOW}🔨 Rebuilding...${NC}"
docker-compose down
docker-compose build
docker-compose up -d

sleep 3

# Kiểm tra
if [ "$(docker ps -q -f name=telegram-shop-bot)" ]; then
    echo -e "${GREEN}✅ Bot updated successfully!${NC}"
    docker-compose logs --tail=20
else
    echo -e "${RED}❌ Update failed. Check logs:${NC}"
    docker-compose logs
    exit 1
fi
