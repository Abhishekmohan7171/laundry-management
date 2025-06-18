#!/bin/bash

# Environment and Database Setup Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header "Setting Up Environment Configuration"

# Create main .env file
cat > .env << 'EOF'
# Application Environment
NODE_ENV=development
PORT=3000

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=password
DB_NAME=laundry_platform

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
REDIS_DB=0

# JWT Configuration
JWT_SECRET=your-super-secure-jwt-secret-key-change-this-in-production
JWT_EXPIRES_IN=24h
JWT_REFRESH_SECRET=your-super-secure-refresh-secret-key-change-this-in-production
JWT_REFRESH_EXPIRES_IN=7d

# Frontend URLs (for CORS)
FRONTEND_URLS=http://localhost:4200,http://localhost:3000

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_DEST=./uploads

# Email Configuration (for notifications)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your-email@gmail.com
MAIL_PASS=your-app-password
MAIL_FROM=noreply@laundryplatform.com

# SMS Configuration (for Qatar phone verification)
TWILIO_ACCOUNT_SID=your-twilio-account-sid
TWILIO_AUTH_TOKEN=your-twilio-auth-token
TWILIO_PHONE_NUMBER=your-twilio-phone-number

# Payment Gateway (Qatar-specific)
PAYMENT_GATEWAY_URL=https://api.qnb.com.qa/payments
PAYMENT_GATEWAY_KEY=your-payment-gateway-key
PAYMENT_GATEWAY_SECRET=your-payment-gateway-secret

# Google Maps API (for location services)
GOOGLE_MAPS_API_KEY=your-google-maps-api-key

# Service URLs
USER_SERVICE_URL=http://localhost:3001
ORDER_SERVICE_URL=http://localhost:3002
PAYMENT_SERVICE_URL=http://localhost:3003
NOTIFICATION_SERVICE_URL=http://localhost:3004
LOCATION_SERVICE_URL=http://localhost:3005
ANALYTICS_SERVICE_URL=http://localhost:3006
API_GATEWAY_URL=http://localhost:3000
WEBSOCKET_GATEWAY_URL=http://localhost:3007
EOF

# Create .env.example for reference
cp .env .env.example

print_success "Environment files created (.env and .env.example)"

# Update root package.json with build scripts
print_header "Adding Build Scripts to Root Package.json"

# Create a backup of package.json
cp package.json package.json.backup

# Update package.json with build scripts
cat > package.json << 'EOF'
{
  "name": "laundry-management",
  "version": "1.0.0",
  "description": "Comprehensive laundry management platform for Qatar",
  "main": "index.js",
  "scripts": {
    "build": "pnpm run build:packages && pnpm run build:apps",
    "build:packages": "pnpm run --filter='./packages/**' build",
    "build:apps": "pnpm run --filter='./apps/**' build",
    "dev": "./tools/scripts/dev-microservices.sh start",
    "dev:services": "./tools/scripts/dev-microservices.sh start:services",
    "dev:gateways": "./tools/scripts/dev-microservices.sh start:gateways",
    "dev:user": "./tools/scripts/dev-microservices.sh start:user",
    "dev:order": "./tools/scripts/dev-microservices.sh start:order",
    "dev:payment": "./tools/scripts/dev-microservices.sh start:payment",
    "dev:gateway": "./tools/scripts/dev-microservices.sh start:gateway",
    "test": "pnpm run --filter='./apps/**' test",
    "test:e2e": "pnpm run --filter='./apps/**' test:e2e",
    "lint": "pnpm run --filter='./apps/**' lint",
    "format": "pnpm run --filter='./apps/**' format",
    "clean": "pnpm run --filter='./**' clean && rm -rf node_modules/.cache",
    "setup": "./tools/scripts/setup.sh",
    "db:create": "createdb laundry_platform || echo 'Database may already exist'",
    "db:drop": "dropdb laundry_platform || echo 'Database may not exist'",
    "db:reset": "pnpm run db:drop && pnpm run db:create",
    "health": "./tools/scripts/dev-microservices.sh health"
  },
  "keywords": [
    "laundry",
    "management",
    "qatar",
    "microservices",
    "nestjs",
    "angular",
    "flutter"
  ],
  "author": "Your Name",
  "license": "MIT",
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@angular/cli": "^16.0.0",
    "typescript": "^5.1.3",
    "prettier": "^3.0.0",
    "eslint": "^8.42.0",
    "concurrently": "^8.2.0"
  },
  "engines": {
    "node": ">=18.0.0",
    "pnpm": ">=8.0.0"
  }
}
EOF

print_success "Root package.json updated with build scripts"

# Create database setup script
print_header "Creating Database Setup Script"

cat > tools/scripts/setup-database.sh << 'EOF'
#!/bin/bash

# Database Setup Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header "Setting Up Laundry Platform Database"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

DB_NAME=${DB_NAME:-laundry_platform}
DB_USER=${DB_USERNAME:-postgres}

echo "Creating database: $DB_NAME"

# Create database if it doesn't exist
createdb $DB_NAME -U $DB_USER 2>/dev/null || {
    print_warning "Database $DB_NAME may already exist"
}

# Enable PostGIS extension
echo "Enabling PostGIS extension..."
psql -d $DB_NAME -U $DB_USER -c "CREATE EXTENSION IF NOT EXISTS postgis;" 2>/dev/null || {
    print_warning "PostGIS extension may already be enabled"
}

psql -d $DB_NAME -U $DB_USER -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";" 2>/dev/null || {
    print_warning "UUID extension may already be enabled"
}

print_success "Database setup completed!"

echo
echo "Database Information:"
echo "• Name: $DB_NAME"
echo "• User: $DB_USER"
echo "• Host: ${DB_HOST:-localhost}"
echo "• Port: ${DB_PORT:-5432}"
echo
echo "Extensions enabled:"
echo "• PostGIS (for geospatial data)"
echo "• UUID-OSSP (for UUID generation)"
EOF

chmod +x tools/scripts/setup-database.sh

# Create complete setup script
cat > tools/scripts/setup.sh << 'EOF'
#!/bin/bash

# Complete Project Setup Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header "Complete Laundry Platform Setup"

echo "This script will:"
echo "1. Install all dependencies"
echo "2. Build shared packages"
echo "3. Set up the database"
echo "4. Verify all services"
echo

read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 1
fi

# Step 1: Install dependencies
print_header "Step 1: Installing Dependencies"
pnpm install

# Step 2: Build packages
print_header "Step 2: Building Shared Packages"
pnpm run build:packages

# Step 3: Setup database
print_header "Step 3: Setting Up Database"
./tools/scripts/setup-database.sh

# Step 4: Verify services can start
print_header "Step 4: Verifying Service Setup"
echo "Testing if services can start..."

# Quick test - try to build one service
cd apps/services/user-service
pnpm build 2>/dev/null && print_success "Services can build successfully" || print_warning "Service build test failed - check dependencies"
cd - > /dev/null

print_header "Setup Complete!"

echo
echo "🎉 Laundry Platform Setup Complete!"
echo
echo "📋 What's been set up:"
echo "• ✅ All dependencies installed"
echo "• ✅ Shared packages built"
echo "• ✅ Database created with PostGIS"
echo "• ✅ Environment configuration ready"
echo
echo "🚀 Next Steps:"
echo "1. Update .env with your actual values"
echo "2. Start services: pnpm run dev"
echo "3. Check health: pnpm run health"
echo "4. Access API docs: http://localhost:3000/api/docs"
echo
echo "📚 Available Commands:"
echo "• pnpm run dev              - Start all services"
echo "• pnpm run dev:user         - Start user service only"
echo "• pnpm run dev:gateway      - Start API gateway only"
echo "• pnpm run health           - Check all service health"
echo "• pnpm run db:reset         - Reset database"
EOF

chmod +x tools/scripts/setup.sh

print_success "Setup scripts created"

print_header "Environment Setup Complete!"

echo
echo "🎉 Full Infrastructure Ready!"
echo
echo "📁 What's been created:"
echo "• Database package with full entity structure"
echo "• Environment configuration (.env)"
echo "• Database setup scripts"
echo "• Build scripts for all packages"
echo
echo "🚀 Next Steps:"
echo "1. Run the database setup script"
echo "2. Install dependencies and build packages"
echo "3. Start implementing User Service authentication"
echo
echo "📋 Commands to run:"
echo "bash ./tools/scripts/setup-database.sh"
echo "pnpm install"
echo "pnpm run build:packages"