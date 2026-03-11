# API Integration Plan - Monefy Note App

## Overview
เชื่อมต่อ Flutter app กับ Node.js backend API โดยยังคง **offline-first** approach

**Backend:** `monefy-note-api` (Node.js + Express + TypeScript + Prisma + PostgreSQL)
- Base URL: `http://localhost:3001/api/v1`
- JWT Auth (access: 15min, refresh: 7 days)
- Endpoints: Auth, Wallets, Transactions, Categories, Budgets, Transfers

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    User Action                       │
└────────────────────────┬────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────┐
│               1. Save to Local Storage               │
│                  (Always succeeds)                   │
└────────────────────────┬────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────┐
│                 2. Check Network                     │
└───────┬─────────────────────────────┬───────────────┘
        │ Online                      │ Offline
        ▼                             ▼
┌───────────────────┐         ┌───────────────────────┐
│ 3a. Sync to API   │         │ 3b. Queue Operation   │
│     immediately   │         │     for later sync    │
└───────────────────┘         └───────────────────────┘
```

**Conflict Resolution:** Last-Write-Wins (local changes take priority)

---

## Progress

### Phase 1: Network Foundation - DONE
| File | Description | Status |
|------|-------------|--------|
| `lib/core/constants/api_endpoint.dart` | API URL constants | Done |
| `lib/core/network/dio_client.dart` | HTTP client with interceptors | Done |
| `lib/core/network/auth_interceptor.dart` | JWT auto-attach + refresh | Done |
| `lib/core/network/error_interceptor.dart` | HTTP error mapping | Done |
| `lib/core/services/token_service.dart` | Secure token storage | Done |

### Phase 2: Models & Exceptions - DONE
| File | Description | Status |
|------|-------------|--------|
| `lib/core/errors/exceptions.dart` | ApiException hierarchy | Done |
| `lib/core/models/user.dart` | User model (Freezed) | Done |
| `lib/core/models/auth_token.dart` | AuthTokens model (Freezed) | Done |

### Phase 3: Auth Flow - DONE (Sign In only)
| File | Description | Status |
|------|-------------|--------|
| `lib/core/datasources/remote/auth_remote_datasource.dart` | Auth API calls | Done |
| `lib/core/repositories/auth_repository.dart` | Auth business logic | Done |
| `lib/core/cubit/auth/auth_cubit.dart` | Auth state management | Done |
| `lib/core/cubit/auth/auth_state.dart` | Auth states (Freezed) | Done |
| `lib/core/di/auth_module.dart` | DI module for auth | Done |
| `lib/pages/sign-in/page/sign_in_page.dart` | Connected to AuthCubit | Done |

---

## Remaining Tasks

### Phase A: Sign Up + Auth Testing
- [ ] เชื่อม SignUpPage กับ AuthCubit
- [ ] ทดสอบ Sign In / Sign Up กับ backend จริง
- [ ] แก้ Splash page ให้ check auth status

### Phase B: Remote DataSources (CRUD)
- [ ] `wallet_remote_datasource.dart` - CRUD /wallets
- [ ] `transaction_remote_datasource.dart` - CRUD /transactions + summary
- [ ] `category_remote_datasource.dart` - CRUD /categories
- [ ] `budget_remote_datasource.dart` - CRUD /budgets + status
- [ ] `transfer_remote_datasource.dart` - CRUD /transfers

### Phase C: Sync Infrastructure
- [ ] `sync_metadata.dart` model - track sync status per entity
- [ ] `sync_operation.dart` model - pending operations
- [ ] `sync_queue_datasource.dart` - queue storage
- [ ] `sync_metadata_datasource.dart` - ID mapping (local <-> remote)

### Phase D: Sync Repositories
- [ ] `sync_wallet_repository.dart` - offline-first wallet
- [ ] `sync_transaction_repository.dart` - offline-first transaction
- [ ] `sync_category_repository.dart` - offline-first category
- [ ] `sync_budget_repository.dart` - offline-first budget
- [ ] `sync_transfer_repository.dart` - offline-first transfer
- [ ] Update DI - replace Local repos with Sync repos

### Phase E: Sync Service
- [ ] `sync_service.dart` - orchestrate sync
- [ ] Auto-sync when online
- [ ] `data_migration_service.dart` - migrate local data to server

### Phase F: UI Updates
- [ ] Home page - show sync status
- [ ] Settings - sign out button
- [ ] Error handling UI improvements

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| HTTP Client | Dio 5.9.0 |
| Token Storage | flutter_secure_storage 10.0.0 |
| Local Storage | SharedPreferences (JSON) |
| State Management | flutter_bloc (Cubit) |
| DI | GetIt + Injectable |
| Models | Freezed (sealed class) |
| Navigation | GoRouter |

---

## Key Patterns

- **Freezed models** ใช้ `sealed class` + `@freezed` (pattern ของ project นี้)
- **DI modules** แยกเป็น `AuthModule`, `RepositoryModule`, `ServiceModule`
- **SharedPreferences** instance เป็น public variable `sharedPreferencesInstance` ใน `repository_module.dart`
- **Auth flow**: SignIn -> AuthCubit -> AuthRepository -> AuthRemoteDatasource -> API
- **Token refresh**: AuthInterceptor จัดการ auto-refresh เมื่อ token หมดอายุ
