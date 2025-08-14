# Amortiza\_Mais

> Housing loan simulation and management application with automatic Euribor rate integration, amortization calculations, and cost estimations (insurance, fees, property tax, stamp duty).

## Features

* Simulation of housing loans (fixed, variable, and mixed rates).
* Management of existing contracts with real-time tracking of outstanding balances.
* Partial or full amortization calculations, affecting either loan term or installment amount.
* Additional cost calculations: insurance, bank fees, property tax (IMI), and stamp duty.
* Export of reports and simulations to PDF.
* Integration with public Euribor API (3, 6, and 12 months).
* Automatic extraction of property tax rates via web scraping.

## Tech Stack

* **Backend**: NestJS (TypeScript), Sequelize ORM, MySQL, JWT (argon2)
* **Mobile**: Flutter (Dart), Dio (HTTP client), PDF generation library
* **Web scraping**: Axios, Cheerio, iconv-lite
<div style="display: flex; justify-content: space-between; align-items: center; max-width: 300px; margin: 0 auto;">
    <p align="center">
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/nestjs/nestjs-original.svg" alt="NestJS" width="50" height="50" />
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/sequelize/sequelize-original.svg" alt="Sequelize" width="50" height="50" />
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg" alt="MySQL" width="50" height="50" />
    <img src="https://cdn.jsdelivr.net/npm/simple-icons@v10/icons/jsonwebtokens.svg" alt="JWT" width="50" height="50" />
    <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" alt="Flutter" width="50" height="50" />
    </p>
</div>


## Directory Structure

```
/
├── BACK-END/            # NestJS server (Sequelize + MySQL)
│   ├── src/
│   ├── migrations/
│   ├── models/
│   ├── config/
│   ├── dist/
│   ├── test/
│   ├── .env            # environment variables
│   ├── package.json
│   └── tsconfig.json
├── FRONTEND/            # Flutter app (iOS/Android)
│   ├── lib/
│   ├── assets/          # imi_2024.json and images
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── test/
│   ├── scripts/         # fetch-imi.js
│   ├── pubspec.yaml
│   └── package.json
└── README.md            # this file
```

## Quick Start

### Prerequisites

* Node.js ≥ 16
* npm or Yarn
* Flutter SDK ≥ 3.0
* MySQL (local or via Docker)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://gitlab.estig.ipb.pt/davide.dias/p012_amotiza_mais.git
   cd p012_amotiza_mais
   ```

2. **Install backend dependencies**

   ```bash
   # Move to backend folder
   cd BACK-END

   # Install project dependencies
   npm install

   # (Optional) Install Nest CLI globally if you want to use the "nest" command
   npm install -g @nestjs/cli

   # Install core NestJS packages
   npm install @nestjs/common @nestjs/core @nestjs/platform-express reflect-metadata rxjs

   # Install ORM and database driver
   npm install sequelize sequelize-cli mysql2

   # Install authentication libraries (JWT + Passport + Argon2)
   npm install @nestjs/jwt @nestjs/passport passport passport-jwt argon2

   # Install web scraping libraries
   npm install axios cheerio iconv-lite


3. **Install frontend dependencies**

   ```bash
   cd ../FRONTEND
   flutter pub get
   ```

### Environment Variables

In the `BACK-END/` directory, create a `.env` file with:

```ini
# JWT secrets
AT_JWT_SECRET=define_access_token_secret
RT_JWT_SECRET=define_refresh_token_secret
```

### Running the Application

* **Backend Server**

  ```bash
  cd BACK-END
  npm run start:dev
  ```

  The backend will be available at `http://localhost:3000/`.

* **Flutter App**

  ```bash
  cd FRONTEND
  flutter run
  ```
