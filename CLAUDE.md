# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby on Rails 7.2 application for learning about file upload implementation, specifically focused on AWS S3 presigned URL uploads. The project uses Docker for development environment setup.

## Development Commands

### Setup and Installation
```bash
# Build Docker containers
docker-compose build web

docker-compose up -d

# Install dependencies
docker-compose exec web bundle install

# Start the application
docker-compose up web
```

### Testing
```bash
# Run all tests
docker-compose exec web rails test

# Run specific test file
docker-compose exec web rails test test/controllers/files_controller_test.rb
```

### Code Quality
```bash
# Run Rubocop linter (Rails Omakase style)
docker-compose exec web rubocop

# Run security analysis with Brakeman
docker-compose exec web brakeman
```

### Database Operations
```bash
# Run migrations
docker-compose exec web rails db:migrate

# Reset database
docker-compose exec web rails db:reset
```

## Architecture Overview

### Core Components

**Files Upload Flow:**
- `/` (root) → `FilesController#index` - Main upload interface
- `POST /files/presigned_url` → `FilesController#presigned_url` - Returns S3 presigned URL data

**Frontend Architecture:**
- **Hotwire/Turbo:** SPA-like experience without heavy JavaScript
- **Stimulus Controllers:** `files_controller.js` handles file selection and presigned URL requests
- **Importmap:** Manages JavaScript dependencies without bundling

**Backend Structure:**
- **FilesController:** Currently returns mock S3 presigned URL data (not yet connected to real AWS S3)
- **Active Storage:** Configured but not yet integrated (see `config/storage.yml`)
- **AWS SDK:** `aws-sdk-s3` gem included for S3 integration


### Development Environment

**Docker Setup:**
- PostgreSQL 15 database (`db` service)
- Rails app (`web` service) on port 3000
- Shared volume for live code reloading

**Database:** PostgreSQL (configured via `DATABASE_URL` environment variable)

## Current Implementation Status

This is a learning project with basic file upload UI and presigned URL endpoint structure in place. The S3 integration returns mock data and needs to be implemented with real AWS credentials and bucket configuration.

## Testing Approach

Uses standard Rails testing with:
- `test/controllers/` - Controller tests
- `test/system/` - System/integration tests (Capybara + Selenium)
- `test/test_helper.rb` - Test configuration