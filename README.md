# Monefy Note App

แอปพลิเคชันจัดการการเงินส่วนบุคคล พัฒนาด้วย Flutter

## Features

- [ ] Authentication (Sign In / Sign Up)
- [ ] Wallet Management
- [ ] Income & Expense Tracking
- [ ] Summary & Reports
- [x] Multi-language (TH/EN)
- [x] Light/Dark Theme

## Tech Stack

- **Framework:** Flutter 3.x
- **State Management:** flutter_bloc
- **Dependency Injection:** get_it + injectable
- **Navigation:** go_router
- **Localization:** easy_localization
- **Theme:** flex_color_scheme
- **Network:** dio

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── injection.dart
├── core/
│   ├── constants/
│   ├── localization/
│   ├── network/
│   ├── router/
│   ├── theme/
│   └── utils/
├── models/
├── repositories/
├── services/
├── widgets/
└── pages/
    ├── splash/
    ├── signin/
    ├── signup/
    ├── home/
    ├── wallet/
    ├── summary/
    └── setting/
```

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.3
- Dart SDK ^3.10.3

### Installation

1. Clone the repository
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Generate code (DI, Freezed)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run the app
   ```bash
   flutter run
   ```

## Development

### Generate Code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Watch Mode
```bash
dart run build_runner watch --delete-conflicting-outputs
```
