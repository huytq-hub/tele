// Main Bot Entry Point
const TelegramBot = require('node-telegram-bot-api');
const config = require('./config');
const db = require('./database/index');
const Payment = require('./services/payment');
const i18n = require('./locales');
const commandHandlers = require('./handlers/commands');
const callbackHandlers = require('./handlers/callbacks');
const adminHandlers = require('./handlers/admin');
const messageHandlers = require('./handlers/messages');

const PAYMENT_CHECK_INTERVAL = 30000;

async function startBot() {
  console.log('🚀 Starting bot...');
  await db.initDB();

  Payment.loadPendingDeposits();

  const User = require('./database/models/user');
  const users = User.getAll(10000);
  i18n.loadUserLangs(users);
  console.log(`🌐 Loaded languages for ${users.length} users`);

  const bot = new TelegramBot(config.BOT_TOKEN, { 
    polling: { 
      params: { timeout: 10 }, 
      interval: 1000,
      autoStart: true
    },
    filepath: false // Fix deprecation warning
  });

  try {
    bot.botInfo = await bot.getMe();
    console.log(`🤖 Bot: @${bot.botInfo.username}`);
  } catch (err) {
    console.error('Failed to get bot info:', err.message);
    throw err;
  }

  bot.setMyCommands([
    { command: 'start', description: 'Start / 开始 / Bắt đầu' },
    { command: 'menu', description: 'Shop / 商店 / Mua hàng' },
    { command: 'balance', description: 'Balance / 余额 / Số dư' },
    { command: 'referral', description: 'Referral / 邀请 / Giới thiệu' },
    { command: 'history', description: 'History / 历史 / Lịch sử' },
    { command: 'lang', description: 'Language / 语言 / Ngôn ngữ' }
  ]).catch(err => console.error('Failed to set commands:', err.message));

  commandHandlers.register(bot);
  callbackHandlers.register(bot);
  adminHandlers.registerCommands(bot);
  adminHandlers.registerCallbacks(bot);
  messageHandlers.register(bot);

  // Xử lý lỗi polling tốt hơn
  bot.on('polling_error', (err) => {
    if (err.code === 'EFATAL') {
      console.error('Fatal polling error:', err.message);
    } else if (err.code === 'ECONNRESET' || err.code === 'ETIMEDOUT') {
      console.log('Connection lost, will retry...');
    } else {
      console.error('Polling error:', err.message);
    }
  });

  // Xử lý callback query cũ
  bot.on('callback_query', (query) => {
    // Nếu query quá cũ, answer để tránh lỗi
    bot.answerCallbackQuery(query.id).catch(() => {});
  });

  startPaymentChecker(bot);
  console.log(`🏪 ${config.SHOP_NAME} is running!`);
}

function startPaymentChecker(bot) {
  setInterval(async () => {
    try {
      await Payment.checkPendingDeposits((userId, amount, method, chatId, depositBonuses, creditAmount, currency) => {
        const displayCurrency = currency || (method === 'binance' ? 'USDT' : 'VND');
        let msg;
        
        if (method === 'bank') {
          msg = `✅ ${i18n.t(userId, 'deposit_success', { amount: `${amount} ${displayCurrency}` })}\n💰 +${creditAmount} USDT`;
        } else {
          msg = i18n.t(userId, 'deposit_success', { amount: `${amount} ${displayCurrency}` });
        }
        
        if (depositBonuses?.length > 0) {
          msg += '\n\n🎁 BONUS:';
          depositBonuses.forEach(b => {
            msg += `\n• ${b.eventName}: +${b.amount} credits`;
          });
        }
        
        if (chatId) 
          bot.sendMessage(chatId, msg).catch(() => { });
        
        config.ADMIN_IDS.forEach(id => {
          const adminMsg = method === 'bank'
            ? `💰 DEPOSIT\n👤 ${userId}\n💵 ${amount} ${displayCurrency} → ${creditAmount} USDT\n📱 ${method}`
            : `💰 DEPOSIT\n👤 ${userId}\n💵 ${amount} ${displayCurrency}\n📱 ${method}`;
          bot.sendMessage(id, adminMsg).catch(() => { });
        });
      });
    } catch (err) {
      console.error('Deposit checker error:', err.message);
    }
  }, PAYMENT_CHECK_INTERVAL);
}

startBot().catch(err => {
  console.error('Failed to start bot:', err);
  process.exit(1);
});

// Xử lý graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n🛑 Shutting down gracefully...');
  process.exit(0);
});

// Xử lý unhandled rejection
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});
