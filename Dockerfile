# Use Node.js LTS version
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json ./

# Install dependencies (không cần package-lock.json)
RUN npm install --production --no-package-lock

# Copy application files
COPY . .

# Create data directory for SQLite database
RUN mkdir -p /app/data

# Expose port (optional, for health checks)
EXPOSE 3000

# Start the bot
CMD ["npm", "start"]
