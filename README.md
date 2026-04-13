---
title: ChefInPocket
emoji: 🍳
colorFrom: yellow
colorTo: red
sdk: docker
app_port: 7860
pinned: false
---

# ChefInPocket

ChefInPocket is a CS310 Step 3 monorepo that includes:

- A Flutter UI implementation based on the team wireframes.
- Beginner-friendly Node.js microservices for auth, recipes, pantry, community, and AI assistant flows.
- Docker support for the backend stack and a separate Dockerfile for the Flutter web build.

## Project Structure

```text
chef_in_pocket/
├── frontend/
│   └── frontend/              # Flutter mobile/web UI
├── backend/
│   ├── api-gateway/           # Single entry point for service routing
│   └── services/
│       ├── auth-service/
│       ├── recipe-service/
│       ├── pantry-service/
│       ├── community-service/
│       └── assistant-service/
├── docker-compose.yml
└── .env.example
```

## Frontend Highlights

- 16 named-route screens that follow the wireframe flow
- Shared utility files for colors, spacing, and text styles
- Custom fonts: Inter and Syne
- Asset images and network images
- Form validation with inline errors and success `AlertDialog`
- Card-based grocery list with dynamic remove buttons
- Responsive layouts for narrow and wide screens

## Backend Highlights

- Microservice-ready Express + MongoDB services
- API Gateway that forwards all `/api/*` requests
- Seed data so the services are useful on first run
- Dockerized backend services for a clean local setup

## Local Run

### Flutter

```bash
cd frontend
flutter pub get
flutter run
```

### Backend with Docker

1. Copy `.env.example` to `.env`
2. Fill in your MongoDB Atlas credentials locally
3. Run:

```bash
docker compose up --build
```

The API gateway will be available at `http://localhost:8080`.

## Frontend Docker

The frontend has its own Dockerfile for a Flutter web build:

```bash
cd frontend
docker build -t chefinpocket-frontend .
docker run -p 3000:80 chefinpocket-frontend
```
