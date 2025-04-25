# BAIC Global

This repository contains the codebase for the BAIC Global website and related services.

## Project Structure

The project consists of the following components:

- **beiqi-geoip**: GeoIP service for location detection
- **beiqi-home-master**: Frontend website built with Nuxt.js
- **beiqi-service-master**: Backend services built with Java Spring Boot
  - **ruoyi-admin**: Admin backend API
  - **ruoyi-web**: Website backend API
- **beiqi-web-master**: Admin panel built with Vue.js

## Deployment

This project is designed to be deployed to Google Cloud Platform (GCP) using Cloud Build, App Engine, and Cloud Run.

For detailed deployment instructions, see the [Deployment Guide](deployment-guide.md).

## Development

### Prerequisites

- Java 17
- Node.js 14
- Maven
- MySQL

### Local Setup

1. Clone the repository
2. Set up the database
3. Configure the application properties
4. Start the backend services
5. Start the frontend applications

## License

Proprietary - All rights reserved.
