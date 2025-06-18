#!/bin/bash

# Development script for microservices architecture

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

# Check if running from correct directory
check_directory() {
    if [ ! -f "package.json" ] || [ ! -f "pnpm-workspace.yaml" ]; then
        print_error "Please run this script from the project root directory"
        exit 1
    fi
}

# Show help
show_help() {
    print_header "Laundry Platform Microservices Development Script"
    echo
    echo "Usage: ./tools/scripts/dev-microservices.sh [COMMAND]"
    echo
    echo "Commands:"
    echo "  setup              - Run initial setup for microservices"
    echo "  start              - Start all microservices"
    echo "  start:gateway      - Start only API Gateway"
    echo "  start:user         - Start only User Service"
    echo "  start:order        - Start only Order Service"
    echo "  start:payment      - Start only Payment Service"
    echo "  start:notification - Start only Notification Service"
    echo "  start:location     - Start only Location Service"
    echo "  start:analytics    - Start only Analytics Service"
    echo "  stop               - Stop all services"
    echo "  restart            - Restart all services"
    echo "  logs               - Show logs for all services"
    echo "  logs:service       - Show logs for specific service"
    echo "  health             - Check health of all services"
    echo "  build              - Build all microservices"
    echo "  test               - Run tests for all services"
    echo "  clean              - Clean all builds and containers"
    echo "  scale              - Scale services (Docker Compose)"
    echo "  help               - Show this help message"
    echo
}

# Start all microservices
start_all() {
    print_header "Starting All Microservices"
    
    # Start database services first
    print_success "Starting database services..."
    docker-compose -f tools/docker/docker-compose.microservices.yml up -d postgres redis
    
    # Wait for databases to be ready
    sleep 10
    
    # Start all microservices
    print_success "Starting microservices..."
    docker-compose -f tools/docker/docker-compose.microservices.yml up -d
    
    print_success "All microservices started!"
    echo
    echo "Services:"
    echo "• API Gateway:          http://localhost:3000"
    echo "• User Service:         http://localhost:3001"
    echo "• Order Service:        http://localhost:3002"
    echo "• Payment Service:      http://localhost:3003"
    echo "• Notification Service: http://localhost:3004"
    echo "• Location Service:     http://localhost:3005"
    echo "• Analytics Service:    http://localhost:3006"
    echo "• Frontend PWA:         http://localhost:4200"
    echo "• Database Admin:       http://localhost:8080"
    echo "• Redis Admin:          http://localhost:8081"
    echo
}

# Start specific service
start_service() {
    local service=$1
    print_header "Starting $service"
    
    case $service in
        "gateway")
            pnpm run dev:api-gateway
            ;;
        "user")
            pnpm run dev:user-service
            ;;
        "order")
            pnpm run dev:order-service
            ;;
        "payment")
            pnpm run dev:payment-service
            ;;
        "notification")
            pnpm run dev:notification-service
            ;;
        "location")
            pnpm run dev:location-service
            ;;
        "analytics")
            pnpm run dev:analytics-service
            ;;
        *)
            print_error "Unknown service: $service"
            echo "Available services: gateway, user, order, payment, notification, location, analytics"
            exit 1
            ;;
    esac
}

# Stop all services
stop_all() {
    print_header "Stopping All Services"
    
    # Stop Docker services
    docker-compose -f tools/docker/docker-compose.microservices.yml down
    
    # Kill any running Node.js processes
    pkill -f "nest start" 2>/dev/null || true
    
    print_success "All services stopped"
}

# Restart all services
restart_all() {
    stop_all
    sleep 5
    start_all
}

# Show logs
show_logs() {
    local service=$1
    
    if [ -z "$service" ]; then
        print_header "Showing All Service Logs"
        docker-compose -f tools/docker/docker-compose.microservices.yml logs -f
    else
        print_header "Showing Logs for $service"
        docker-compose -f tools/docker/docker-compose.microservices.yml logs -f "$service"
    fi
}

# Check service health
check_health() {
    print_header "Checking Service Health"
    
    # Database health
    if docker-compose -f tools/docker/docker-compose.microservices.yml exec postgres pg_isready -U laundry_user >/dev/null 2>&1; then
        print_success "PostgreSQL is healthy"
    else
        print_error "PostgreSQL is not responding"
    fi
    
    if docker-compose -f tools/docker/docker-compose.microservices.yml exec redis redis-cli ping >/dev/null 2>&1; then
        print_success "Redis is healthy"
    else
        print_error "Redis is not responding"
    fi
    
    # Service health checks
    services=("3000:API Gateway" "3001:User Service" "3002:Order Service" "3003:Payment Service" "3004:Notification Service" "3005:Location Service" "3006:Analytics Service")
    
    for service in "${services[@]}"; do
        port=$(echo $service | cut -d':' -f1)
        name=$(echo $service | cut -d':' -f2)
        
        if curl -s "http://localhost:$port/health" >/dev/null 2>&1; then
            print_success "$name is healthy"
        else
            print_warning "$name is not responding (may not be started)"
        fi
    done
}

# Build all services
build_all() {
    print_header "Building All Microservices"
    
    # Build shared packages first
    pnpm run build:packages
    
    # Build all services
    pnpm run build:services
    pnpm run build:gateways
    
    print_success "All services built successfully"
}

# Run tests
test_all() {
    print_header "Running Tests for All Services"
    
    pnpm run test:all
    
    print_success "All tests completed"
}

# Clean everything
clean_all() {
    print_header "Cleaning All Services"
    
    # Stop services
    stop_all
    
    # Clean Docker
    docker-compose -f tools/docker/docker-compose.microservices.yml down -v
    docker system prune -f
    
    # Clean Node.js builds
    find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
    
    print_success "Cleanup completed"
}

# Scale services
scale_services() {
    print_header "Scaling Services"
    
    echo "Current service scale:"
    docker-compose -f tools/docker/docker-compose.microservices.yml ps
    
    echo
    echo "To scale a service, use:"
    echo "docker-compose -f tools/docker/docker-compose.microservices.yml up -d --scale user-service=3"
}

# Setup microservices
setup_microservices() {
    print_header "Setting up Microservices Architecture"
    
    # Run the microservices creation script
    if [ -f "tools/scripts/create-microservices.sh" ]; then
        chmod +x tools/scripts/create-microservices.sh
        ./tools/scripts/create-microservices.sh
    else
        print_error "Microservices creation script not found"
        exit 1
    fi
    
    # Build packages
    pnpm install
    pnpm run build:packages
    
    print_success "Microservices setup completed"
}

# Main script logic
main() {
    check_directory
    
    case "$1" in
        "setup")
            setup_microservices
            ;;
        "start")
            start_all
            ;;
        "start:gateway")
            start_service "gateway"
            ;;
        "start:user")
            start_service "user"
            ;;
        "start:order")
            start_service "order"
            ;;
        "start:payment")
            start_service "payment"
            ;;
        "start:notification")
            start_service "notification"
            ;;
        "start:location")
            start_service "location"
            ;;
        "start:analytics")
            start_service "analytics"
            ;;
        "stop")
            stop_all
            ;;
        "restart")
            restart_all
            ;;
        "logs")
            show_logs
            ;;
        "logs:"*)
            service=$(echo "$1" | cut -d':' -f2)
            show_logs "$service"
            ;;
        "health")
            check_health
            ;;
        "build")
            build_all
            ;;
        "test")
            test_all
            ;;
        "clean")
            clean_all
            ;;
        "scale")
            scale_services
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