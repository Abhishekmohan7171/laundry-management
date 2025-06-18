#!/bin/bash

# Comprehensive script to create all microservices and gateways

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

# Ensure we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "pnpm-workspace.yaml" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_header "Creating All Microservices and Gateways"

# Run individual scripts
echo "Step 1: Creating all microservices..."
if [ -f "tools/scripts/create-services.sh" ]; then
    chmod +x tools/scripts/create-services.sh
    ./tools/scripts/create-services.sh
else
    print_warning "create-services.sh not found, skipping services creation"
fi

echo ""
echo "Step 2: Creating all gateways..."
if [ -f "tools/scripts/create-gateways.sh" ]; then
    chmod +x tools/scripts/create-gateways.sh
    ./tools/scripts/create-gateways.sh
else
    print_warning "create-gateways.sh not found, skipping gateways creation"
fi

echo ""
echo "Step 3: Installing dependencies..."
pnpm install

echo ""
echo "Step 4: Building shared packages..."
pnpm run build:packages

print_success "All projects created successfully!"

echo ""
echo "🎉 Complete Architecture Created!"
echo "=================================="
echo ""
echo "📁 Project Structure:"
echo "apps/"
echo "├── services/"
echo "│   ├── user-service/         (Port 3001)"
echo "│   ├── order-service/        (Port 3002)"
echo "│   ├── payment-service/      (Port 3003)"
echo "│   ├── notification-service/ (Port 3004)"
echo "│   ├── location-service/     (Port 3005)"
echo "│   └── analytics-service/    (Port 3006)"
echo "├── gateways/"
echo "│   ├── api-gateway/          (Port 3000)"
echo "│   └── websocket-gateway/    (Port 3007)"
echo "├── frontend/                 (Port 4200)"
echo "└── mobile/                   (Flutter)"
echo ""
echo "🚀 Quick Start Commands:"
echo "# Start all services"
echo "./tools/scripts/dev-microservices.sh start"
echo ""
echo "# Start individual services"
echo "./tools/scripts/dev-microservices.sh start:user"
echo "./tools/scripts/dev-microservices.sh start:gateway"
echo ""
echo "# Check service health"
echo "./tools/scripts/dev-microservices.sh health"
echo ""
echo "🌐 Access Points:"
echo "• API Gateway:    http://localhost:3000/api/docs"
echo "• User Service:   http://localhost:3001/api/docs"
echo "• Order Service:  http://localhost:3002/api/docs"
echo "• Frontend PWA:   http://localhost:4200"
echo "• Database Admin: http://localhost:8080"