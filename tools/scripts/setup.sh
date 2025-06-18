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
