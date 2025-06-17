#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "🚀 Setting up Laundry Platform Development Environment"
echo "====================================================="

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists node; then
    print_error "Node.js is required but not installed. Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js version 18+ is required. Current version: $(node --version)"
    exit 1
fi

if ! command_exists pnpm; then
    print_warning "PNPM not found. Installing globally..."
    npm install -g pnpm
    if [ $? -eq 0 ]; then
        print_success "PNPM installed successfully"
    else
        print_error "Failed to install PNPM"
        exit 1
    fi
fi

if ! command_exists flutter; then
    print_warning "Flutter not found. Please install Flutter from https://docs.flutter.dev/get-started/install"
    print_warning "Flutter is required for mobile app development"
fi

if ! command_exists docker; then
    print_warning "Docker not found. Please install Docker from https://docs.docker.com/get-docker/"
    print_warning "Docker is required for database services"
fi

print_success "Prerequisites check completed"

# Install dependencies
print_status "Installing dependencies..."
pnpm install

if [ $? -eq 0 ]; then
    print_success "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi

# Setup environment files
print_status "Setting up environment files..."
if [ ! -f .env ]; then
    cp .env.example .env
    print_success "Created .env file"
    print_warning "Please update .env file with your configuration before starting services"
else
    print_warning ".env file already exists"
fi

# Build shared packages
print_status "Building shared packages..."
pnpm run build:packages

if [ $? -eq 0 ]; then
    print_success "Shared packages built successfully"
else
    print_error "Failed to build shared packages"
    exit 1
fi

# Start database services
if command_exists docker; then
    print_status "Starting database services..."
    docker-compose -f tools/docker/docker-compose.yml up -d postgres redis
    
    if [ $? -eq 0 ]; then
        print_success "Database services started"
        
        # Wait for database to be ready
        print_status "Waiting for database to be ready..."
        sleep 10
        
        # Check if database is accepting connections
        if docker exec laundry_postgres pg_isready -U laundry_user > /dev/null 2>&1; then
            print_success "Database is ready"
            
            # Run database migrations (when backend is ready)
            print_status "Database migrations will be run when you start the backend"
        else
            print_warning "Database might not be fully ready yet. Please wait a moment before starting the backend"
        fi
    else
        print_error "Failed to start database services"
        print_warning "You can start them manually with: docker-compose -f tools/docker/docker-compose.yml up -d"
    fi
else
    print_warning "Docker not available. Please start PostgreSQL and Redis manually"
fi

# Flutter setup
if command_exists flutter; then
    print_status "Setting up Flutter..."
    cd apps/mobile
    flutter pub get
    if [ $? -eq 0 ]; then
        print_success "Flutter dependencies installed"
    else
        print_warning "Failed to install Flutter dependencies"
    fi
    cd ../..
fi

print_success "Setup completed successfully! 🎉"
echo ""
echo "Next steps:"
echo "==========="
echo "1. Update .env file with your configuration"
echo "2. Start the development servers:"
echo "   • Backend:  pnpm run dev:backend"
echo "   • Frontend: pnpm run dev:frontend"
echo "   • Mobile:   pnpm run dev:mobile"
echo ""
echo "3. Or start all services with Docker:"
echo "   • All:      pnpm run docker:dev"
echo ""
echo "4. Access the applications:"
echo "   • Backend API:    http://localhost:3000"
echo "   • API Docs:       http://localhost:3000/api/docs"
echo "   • Frontend PWA:   http://localhost:4200"
echo "   • Database Admin: http://localhost:8080"
echo "   • Redis Admin:    http://localhost:8081"
echo ""
print_warning "Make sure to configure your environment variables in .env before starting!"