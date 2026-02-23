# 🤖 Telegram Shop Bot - Binance Pay & Credits System

A feature-rich Telegram bot for selling digital products.

## ✨ Features

### 💰 Payment Systems
- **Binance Pay** - USDT cryptocurrency payments with automatic verification
- **Bank Transfer** - Vietnamese bank transfers via SePay API integration
- **Automatic Payment Detection** - Monitors and confirms deposits automatically
- **QR Code Support** - Displays QR codes for easy payment

### 🪙 Dual Currency System
- **Balance (USDT/VND)** - Primary currency from deposits
- **Credits (🪙)** - Bonus currency from referrals and events
- **Flexible Payment** - Users can pay with either Balance or Credits
- **Smart Pricing** - Products can have separate pricing for each currency

### 👥 Referral System
- **Referral Codes** - Unique codes for each user
- **Instant Bonuses** - Configurable rewards for referrer and referee
- **Minimum Deposit Option** - Set minimum deposit requirement for bonus eligibility
- **Tracking** - View referral statistics and earnings

### 🛍️ Product Management
- **Stock Management** - Track available and sold items
- **Dual Pricing** - Set prices in both Balance and Credits
- **Auto-delivery** - Instant delivery of account credentials after purchase
- **Product Visibility** - Enable/disable products as needed

### 🌐 Multi-language Support
- **3 Languages** - Vietnamese, English, Chinese
- **User Preferences** - Each user can select their preferred language
- **Fully Translated** - All messages and UI elements localized

### 📊 Admin Features
- **User Management** - View all users, balances, and credits
- **Order Tracking** - Monitor all orders in real-time
- **Revenue Analytics** - Track Balance revenue and Credits usage
- **Manual Adjustments** - Add/remove balance or credits for users
- **Broadcast Messages** - Send announcements to all users (in their language)
- **Event System** - Create promotional events with bonus credits
- **Product CRUD** - Full product management interface

### 🔧 Additional Features
- **Purchase History** - Users can view their order history with timestamps
- **Transaction Logs** - Complete audit trail of all transactions
- **Atomic Operations** - Prevents race conditions and double-spending
- **Deposit Expiration** - Configurable timeout for pending deposits (default 15 min)
- **Error Handling** - Robust error handling with user-friendly messages
- **SQLite Database** - Fast, reliable, embedded database

## 📋 Requirements

- Node.js v16 or higher
- Telegram Bot Token (from [@BotFather](https://t.me/BotFather))
- Binance Pay account (for crypto payments)
- SePay account (for Vietnamese bank transfers)

## 🚀 Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd bot_binance_pay
```

### 2. Install dependencies

```bash
npm install
```

### 3. Configure environment variables

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```env
# Bot Configuration
BOT_TOKEN=your_telegram_bot_token_from_botfather
BOT_USERNAME=your_bot_username
SHOP_NAME=Your Shop Name

# Admin Configuration
ADMIN_IDS=123456789,987654321
ADMIN_USER_NAME=your_admin_username

# Binance Pay Configuration
BINANCE_API_KEY=your_binance_api_key
BINANCE_SECRET_KEY=your_binance_secret_key
BINANCE_PAY_ID=your_binance_pay_id

# Bank Transfer (SePay) Configuration
SEPAY_API_KEY=your_sepay_api_key
BANK_ACCOUNT=your_bank_account_number
BANK_NAME=Vietcombank
BANK_OWNER=NGUYEN VAN A
BANK_BIN=970436

# Referral Configuration
REFERRER_BONUS=1
REFEREE_BONUS=0.5
MIN_DEPOSIT_FOR_BONUS=5
DEPOSIT_EXPIRES_MINUTES=15
```

### 4. Add Binance QR Code (Optional)

Place your Binance Pay QR code image at:
```
public/bnc_qr.png
```

### 5. Start the bot

```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

## 📁 Project Structure

```
bot_binance_pay/
├── src/
│   ├── bot.js                 # Main entry point
│   ├── config.js              # Configuration loader
│   ├── database/
│   │   ├── index.js           # Database initialization
│   │   └── models/            # Data models
│   │       ├── user.js        # User model
│   │       ├── product.js     # Product model
│   │       ├── order.js       # Order model
│   │       └── transaction.js # Transaction model
│   ├── handlers/
│   │   ├── commands.js        # /start, /menu, /balance commands
│   │   ├── callbacks.js       # Button click handlers
│   │   ├── messages.js        # Text message handlers
│   │   └── admin.js           # Admin commands & UI
│   ├── services/
│   │   ├── wallet.js          # Balance & credits operations
│   │   ├── referral.js        # Referral system logic
│   │   ├── events.js          # Event system (bonuses)
│   │   └── payment/
│   │       ├── index.js       # Payment orchestration
│   │       ├── binance.js     # Binance Pay integration
│   │       └── sepay.js       # SePay bank transfer
│   ├── utils/
│   │   ├── helpers.js         # Helper functions
│   │   └── keyboard.js        # Keyboard builders
│   └── locales/
│       ├── index.js           # i18n loader
│       ├── vi.js              # Vietnamese
│       ├── en.js              # English
│       └── zh.js              # Chinese
├── data/
│   └── shop.db                # SQLite database (auto-created)
├── public/
│   └── bnc_qr.png            # Binance QR code
├── .env                       # Environment config (git-ignored)
├── .env.example              # Example configuration
└── package.json              # Dependencies
```

## 🎮 User Commands

- `/start` - Start bot and show main menu
- `/menu` - Browse products
- `/balance` - View balance, credits, and statistics
- `/referral` - View referral code and earnings
- `/history` - View purchase history
- `/lang` - Change language

## 🛠️ Admin Commands

- `/users` - List all users with balances
- `/orders` - View recent orders
- `/revenue` - View revenue analytics
- `/addbalance [user_id] [amount]` - Add balance to user
- `/addcredits [user_id] [amount]` - Add credits to user
- `/broadcast` - Send message to all users
- `/addevent [type] [amount] [code] [name]` - Create bonus event
- `/clear` - Clear chat messages
- `/products` - Manage products (via inline menu)

### Admin Product Management
- Add/edit products
- Set dual pricing (Balance + Credits)
- Manage stock (add/view inventory)
- Enable/disable products
- View sales statistics

## 💳 Payment Flow

### Deposit Process
1. User selects deposit method (Binance Pay or Bank Transfer)
2. User chooses amount or enters custom amount
3. Bot generates payment instructions with QR code
4. Bot monitors payment status automatically
5. Upon confirmation, balance is credited and user notified
6. Referral bonuses processed if applicable

### Purchase Process
1. User browses products
2. Selects quantity and payment method (Balance or Credits)
3. Bot verifies sufficient funds
4. Bot atomically reserves stock
5. Bot processes payment
6. Account credentials delivered instantly
7. Admin notified of purchase
8. Transaction logged

## 🔒 Security Features

- **Atomic Operations** - Prevents double-spending and race conditions
- **Transaction Logs** - Complete audit trail
- **Admin Authentication** - Commands restricted to authorized admins
- **Input Validation** - All user inputs sanitized
- **Error Recovery** - Automatic refunds on failed orders

## 🗄️ Database Schema

### Users Table
- id, first_name, username, language
- balance, credits
- balance_spent, credits_spent
- referral_code, referred_by
- created_at

### Products Table
- id, name, description
- price (Balance price)
- credits_price, credits_enabled
- is_active
- created_at

### Orders Table
- id, user_id, product_id
- quantity, unit_price, total_price
- payment_method, payment_code
- status, chat_id
- created_at, completed_at

### Transactions Table
- id, user_id, type
- amount, currency
- payment_method, reference_id
- status, note
- created_at

### Pending Deposits Table
- id, user_id, amount, currency
- payment_method, payment_code
- status, expires_at
- created_at

### Stock Table
- id, product_id, account_data
- status (available/sold/reserved)
- order_id, reserved_at, sold_at

### Events Table
- id, code, name, type
- reward_amount, reward_type
- max_per_user, is_active
- created_at

## 🌍 Localization

Add new languages by creating a file in `src/locales/`:

```javascript
// src/locales/es.js
module.exports = {
  // Main Menu
  shop_btn: '🛍️ Tienda',
  balance_btn: '💰 Saldo',
  // ... more translations
};
```

Register in `src/locales/index.js`:

```javascript
const es = require('./es');
const languages = { vi, en, zh, es };
```

## 🔧 Configuration Options

### Referral System
- `REFERRER_BONUS` - Credits given to referrer (default: 1)
- `REFEREE_BONUS` - Credits given to referee (default: 0.5)
- `MIN_DEPOSIT_FOR_BONUS` - Minimum deposit to unlock bonus (default: 5)
  - Set to `0` for instant bonus on referral code entry

### Deposit Settings
- `DEPOSIT_EXPIRES_MINUTES` - Timeout for pending deposits (default: 15)

### Payment Methods
- Set `BANK_ENABLED=false` to disable bank transfers
- Leave Binance or SePay credentials empty to disable respective methods

## 📊 Analytics & Reporting

The bot tracks:
- Total revenue (Balance + Credits usage)
- Revenue split by payment method
- Total orders and completion rate
- Stock availability and sold items
- User registration trends
- Referral conversion rates

## 🐛 Troubleshooting

### Bot not responding
- Check BOT_TOKEN is correct
- Verify bot has privacy mode disabled in BotFather
- Check Node.js process is running

### Payments not detected
- Verify API credentials are correct
- Check payment polling interval (30 seconds default)
- Review logs for API errors

### Database issues
- Database is loaded into memory at startup
- External DB edits require bot restart
- Use admin commands for live updates

### Display issues with numbers
- All numbers automatically format without unnecessary decimals
- `2.00` displays as `2`
- `2.50` displays as `2.5`

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

ISC License - See LICENSE file for details

## 👤 Author

****

## 🙏 Acknowledgments

- [node-telegram-bot-api](https://github.com/yagop/node-telegram-bot-api)
- [sql.js](https://github.com/sql-js/sql.js/)
- Binance Pay API
- SePay API

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Contact admin via Telegram

---

**⚠️ Important Notes:**
- Keep `.env` file secure and never commit it
- Backup `data/shop.db` regularly
- Test in a staging environment before production
- Monitor bot performance and API rate limits
- Database changes require bot restart to take effect
