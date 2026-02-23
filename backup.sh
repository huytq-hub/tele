#!/bin/bash

# Script backup database
# Chạy: bash backup.sh

set -e

BACKUP_DIR="backups"
mkdir -p $BACKUP_DIR

if [ -f data/shop.db ]; then
    BACKUP_FILE="$BACKUP_DIR/shop-$(date +%Y%m%d-%H%M%S).db"
    cp data/shop.db $BACKUP_FILE
    echo "✅ Database backed up to: $BACKUP_FILE"
    
    # Giữ lại 10 backup gần nhất
    ls -t $BACKUP_DIR/shop-*.db | tail -n +11 | xargs -r rm
    echo "📦 Keeping last 10 backups"
else
    echo "❌ Database not found"
    exit 1
fi
