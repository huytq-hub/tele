#!/bin/bash

# Script dừng bot Node.js
# Chạy: bash stop-node.sh

echo "🛑 Stopping bot..."
pm2 stop telegram-bot
echo "✅ Bot stopped"
