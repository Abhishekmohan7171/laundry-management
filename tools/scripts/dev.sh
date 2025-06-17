#!/bin/bash

# Development helper script for laundry platform

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

# Show help
show_help() {
    print_header "Laundry Platform Development Script"
    echo
    echo "Usage: ./tools/scripts/dev.sh [COMMAND]"
    echo
    echo "Commands:"
    echo "  setup         - Run initial setup"
    echo "  start         - Start all development services"
    echo "  start:backend - Start only backend"
    echo "  start:frontend- Start only frontend"
    echo "  start:mobile  - Start only mobile"
    echo "  stop          - Stop all services"
    echo "  clean         - Clean all builds and dependencies"
    echo "  reset         - Reset database and restart"
    echo "  logs          - Show all service logs"
    echo "  test          - Run all tests"
    echo "  build         - Build all applications"
    echo "  db:reset      - Reset database"
    echo "  db:migrate    - Run database migrations"
    echo "  db:seed       - Seed database with test data"
    echo "  health        - Check health of all services"
    echo "  help          - Show this help message"
    echo
}

# Check if running from correct directory
check_directory() {
    if [ ! -f "package.json" ] || [ ! -f "pnpm-workspace.yaml" ]; then
        print_error "Please run this script from the project root directory"
        exit 1
    fi
}

# Start all services
start_all() {
    print_header "Starting All Development Services"
    
    # Start database services
    print_success "Starting database services..."
    docker-compose -f tools/docker/docker-compose.yml up -d postgres redis
    
    # Wait for services to be ready
    sleep 5
    
    # Start backend in background
    print_success "Starting backend..."
    pnpm run dev:backend &
    BACKEND_PID=$!
    
    # Wait a bit for backend to start
    sleep 10
    
    # Start frontend in background
    print_success "Starting frontend..."
    pnpm run dev:frontend &
    FRONTEND_PID=$!
    
    # Start mobile (if Flutter is available)
    if command -v flutter >/dev/null 2>&1; then
        print_success "Flutter detected. You can start mobile with: pnpm run dev:mobile"
    else
        print_warning "Flutter not found. Skipping mobile app."
    fi
    
    print_success "All services started!"
    echo
    echo "Services:"
    echo "• Backend API:    http://localhost:3000"
    echo "• API Docs:       http://localhost:3000/api/docs"
    echo "• Frontend PWA:   http://localhost:4200"
    echo "• Database Admin: http://localhost:8080"
    echo "• Redis Admin:    http://localhost:8081"
    echo
    echo "Press Ctrl+C to stop all services"
    
    # Wait for interrupt
    trap 'kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit' INT
    wait
}

# Stop all services
stop_all() {
    print_header "Stopping All Services"
    
    # Kill Node.js processes
    pkill -f "nest start" 2>/dev/null || true
    pkill -f "ng serve" 2>/dev/null || true
    
    # Stop Docker services
    docker-compose -f tools/docker/docker-compose.yml down
    
    print_success "All services stopped"
}

# Clean everything
clean_all() {
    print_header "Cleaning All Builds and Dependencies"
    
    # Stop services first
    stop_all
    
    # Clean Node.js
    print_success "Cleaning Node.js dependencies..."
    rm -rf node_modules
    find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
    find . -name ".angular" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # Clean Flutter
    if [ -d "apps/mobile" ]; then
        print_success "Cleaning Flutter..."
        cd apps/mobile
        flutter clean 2>/dev/null || true
        cd ../..
    fi
    
    # Clean Docker
    print_success "Cleaning Docker..."
    docker-compose -f tools/docker/docker-compose.yml down -v
    docker system prune -f
    
    print_success "Cleanup completed"
}

# Reset database
reset_database() {
    print_header "Resetting Database"
    
    # Stop and remove database container
    docker-compose -f tools/docker/docker-compose.yml down postgres
    docker volume rm $(docker volume ls -q | grep postgres) 2>/dev/null || true
    
    # Start fresh database
    docker-compose -f tools/docker/docker-compose.yml up -d postgres redis
    
    # Wait for database to be ready
    sleep 10
    
    # Run migrations
    print_success "Running migrations..."
    pnpm run migration:run
    
    print_success "Database reset completed"
}

# Check health of services
check_health() {
    print_header "Checking Service Health"
    
    # Check database
    if docker-compose -f tools/docker/docker-compose.yml exec postgres pg_isready -U laundry_user >/dev/null 2>&1; then
        print_success "PostgreSQL is healthy"
    else
        print_error "PostgreSQL is not responding"
    fi
    
    # Check Redis
    if docker-compose -f tools/docker/docker-compose.yml exec redis redis-cli ping >/dev/null 2>&1; then
        print_success "Redis is healthy"
    else
        print_error "Redis is not responding"
    fi
    
    # Check backend
    if curl -s http://localhost:3000/health >/dev/null 2>&1; then
        print_success "Backend is healthy"
    else
        print_warning "Backend is not responding (may not be started)"
    fi
    
    # Check frontend
    if curl -s http://localhost:4200 >/dev/null 2>&1; then
        print_success "Frontend is healthy"
    else
        print_warning "Frontend is not responding (may not be started)"
    fi
}

# Main script logic
main() {
    check_directory
    
    case "$1" in
        "setup")
            ./tools/scripts/setup.sh
            ;;
        "start")
            start_all
            ;;
        "start:backend")
            docker-compose -f tools/docker/docker-compose.yml up -d postgres redis
            pnpm run dev:backend
            ;;
        "start:frontend")
            pnpm run dev:frontend
            ;;
        "start:mobile")
            pnpm run dev:mobile
            ;;
        "stop")
            stop_all
            ;;
        "clean")
            clean_all
            ;;
        "reset")
            reset_database
            ;;
        "logs")
            docker-compose -f tools/docker/docker-compose.yml logs -f
            ;;
        "test")
            pnpm run test:all
            ;;
        "build")
            pnpm run build:all
            ;;
        "db:reset")
            reset_database
            ;;
        "db:migrate")
            pnpm run migration:run
            ;;
        "db:seed")
            pnpm --filter=backend run seed
            ;;
        "health")
            check_health
            ;;
        "help"|"")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"