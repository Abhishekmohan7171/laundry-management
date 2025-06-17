# 🧺 Laundry Platform

> End-to-end laundry service platform connecting customers, laundry shops, and delivery partners in Qatar

## 📋 Overview

A comprehensive platform that bridges the gap between customers seeking laundry services and laundry shop owners in Qatar, featuring real-time order tracking, integrated payments, and seamless delivery management.

### 🎯 Core Features

- **Customer Mobile App** (Flutter): Shop discovery, order booking, real-time tracking
- **Shop Management PWA** (Angular): Order management, CRM, analytics, POS system
- **Delivery Tracking**: Optional delivery partner integration
- **Real-time Updates**: Live order status via WebSocket connections
- **Payment Integration**: Qatar-specific payment gateways + international options
- **Geolocation Services**: Smart shop discovery within 3km radius

## 🏗️ Architecture

### Monorepo Structure
```
laundry-platform/
├── apps/
│   ├── backend/         # NestJS API
│   ├── frontend/        # Angular PWA (Shop Management)
│   └── mobile/          # Flutter App (Customer)
├── packages/
│   ├── shared-types/    # TypeScript interfaces
│   ├── constants/       # Shared constants
│   └── ui-components/   # Reusable UI components
├── tools/
│   ├── docker/          # Docker configurations
│   ├── scripts/         # Development scripts
│   └── database/        # Database utilities
└── docs/                # Documentation
```

### Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend** | NestJS + TypeScript | RESTful API & WebSocket server |
| **Database** | PostgreSQL + Redis | Primary storage & caching |
| **Frontend** | Angular 16 + PWA | Shop management interface |
| **Mobile** | Flutter 3.x | Customer mobile application |
| **Auth** | JWT + Firebase Auth | Authentication & authorization |
| **Payments** | Stripe + Qatar Banks | Payment processing |
| **Maps** | Google Maps API | Location services |
| **Notifications** | Firebase FCM | Push notifications |

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ ([Download](https://nodejs.org/))
- **PNPM** 8+ (Will be installed automatically)
- **Flutter** 3.10+ ([Install Guide](https://docs.flutter.dev/get-started/install))
- **Docker** & Docker Compose ([Install Guide](https://docs.docker.com/get-docker/))

### One-Command Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/laundry-platform.git
cd laundry-platform

# Run automated setup
chmod +x tools/scripts/setup.sh
./tools/scripts/setup.sh
```

### Manual Setup

```bash
# Install dependencies
pnpm install

# Setup environment
cp .env.example .env
# Edit .env with your configuration

# Build shared packages
pnpm run build:packages

# Start database services
pnpm run db:up

# Start development servers
pnpm run dev:backend    # Backend API (Port 3000)
pnpm run dev:frontend   # Shop PWA (Port 4200)
pnpm run dev:mobile     # Flutter app
```

### Docker Development

```bash
# Start all services
pnpm run docker:dev

# Start specific services
docker-compose -f tools/docker/docker-compose.yml up postgres redis
```

## 📱 Applications

### Backend API (NestJS)
- **URL**: http://localhost:3000
- **Docs**: http://localhost:3000/api/docs
- **Features**: RESTful API, WebSocket, Authentication, File uploads

### Shop Management PWA (Angular)
- **URL**: http://localhost:4200
- **Features**: Order management, Analytics, POS, CRM
- **PWA**: Installable on mobile/desktop

### Customer Mobile App (Flutter)
- **Platform**: Android & iOS
- **Features**: Shop discovery, Order tracking, Payments
- **Development**: Hot reload enabled

## 🗄️ Database

### Development Databases
- **PostgreSQL**: localhost:5432 (Main database)
- **Redis**: localhost:6379 (Caching & sessions)
- **Adminer**: http://localhost:8080 (Database GUI)
- **Redis Commander**: http://localhost:8081 (Redis GUI)

### Connection Details
```bash
Database: laundry_db
Username: laundry_user
Password: [from .env file]
```

## 🛠️ Development

### Available Scripts

```bash
# Development
pnpm run dev:backend     # Start backend with hot reload
pnpm run dev:frontend    # Start Angular dev server
pnpm run dev:mobile      # Start Flutter app

# Building
pnpm run build:all       # Build all applications
pnpm run build:packages  # Build shared packages only

# Testing
pnpm run test:all        # Run all tests
pnpm run lint:all        # Lint all code

# Database
pnpm run migration:generate  # Generate new migration
pnpm run migration:run       # Run pending migrations

# Docker
pnpm run docker:dev      # Start all services
pnpm run db:up          # Start database services only
```

### Code Organization

#### Shared Packages
- **shared-types**: TypeScript interfaces used across all apps
- **constants**: API endpoints, validation rules, Qatar-specific config
- **ui-components**: Reusable Angular components

#### Backend Structure
```
apps/backend/src/
├── auth/           # Authentication & authorization
├── users/          # User management
├── shops/          # Shop management & services
├── orders/         # Order processing & tracking
├── payments/       # Payment integration
├── notifications/  # Push notifications
└── analytics/      # Reporting & analytics
```

## 🌍 Qatar Market Specific

### Localization
- **Currency**: QAR (Qatari Riyal)
- **Timezone**: Asia/Qatar
- **Languages**: English, Arabic
- **Phone Format**: +974XXXXXXXX

### Payment Integration
- **Local Banks**: QIB, CBQ, Doha Bank, Ahli Bank
- **Digital Wallets**: Fawry Pay, Ooredoo Money
- **International**: Stripe (Cards, Apple Pay, Google Pay)

### Delivery Zones
- **Zone 1**: Central Doha (5 QAR, 5km)
- **Zone 2**: Greater Doha (10 QAR, 15km)
- **Zone 3**: Extended Areas (15 QAR, 25km)

## 🔧 Configuration

### Environment Variables
```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=laundry_user
DB_PASSWORD=your_password
DB_NAME=laundry_db

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your_secret_key
JWT_EXPIRES_IN=7d

# Google Maps
GOOGLE_MAPS_API_KEY=your_api_key

# Firebase
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
```

### API Documentation
Interactive API documentation is available at `/api/docs` when running the backend in development mode.

## 📚 Documentation

- [API Documentation](docs/api/) - Detailed API reference
- [Database Schema](docs/database/) - Database design & migrations
- [Deployment Guide](docs/deployment/) - Production deployment
- [Architecture Overview](docs/architecture/) - System design

## 🚢 Deployment

### Production Build
```bash
# Build all applications
pnpm run build:all

# Backend (NestJS)
cd apps/backend && npm run build

# Frontend (Angular PWA)
cd apps/frontend && npm run build:prod

# Mobile (Flutter)
cd apps/mobile && flutter build apk --release
```

### Docker Production
```bash
docker-compose -f tools/docker/docker-compose.prod.yml up -d
```

## 🧪 Testing

```bash
# Unit tests
pnpm run test:all

# E2E tests
pnpm --filter=backend run test:e2e
pnpm --filter=frontend run e2e

# Coverage
pnpm --filter=backend run test:cov
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow TypeScript strict mode
- Use conventional commits
- Add tests for new features
- Update documentation
- Ensure all lints pass

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Email**: support@laundryplatform.qa
- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/yourusername/laundry-platform/issues)

---

**Made with ❤️ for the Qatar market** 🇶🇦