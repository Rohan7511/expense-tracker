# 💰 Expense Tracker

A clean, offline-first expense tracking app built with Flutter and Material 3. All data stays on your device — no accounts, no cloud, no internet required.

## Features

- **Add, edit & delete expenses** — log amount, item description, category, and date
- **Custom categories** — create, rename, and delete categories with safe expense migration
- **Search & filter** — find expenses by item name or filter by category using chips
- **Statistics dashboard** — view weekly, monthly, and yearly totals (overall & per-category)
- **CSV export & import** — share your data as CSV or import from an existing file
- **Configurable currency** — change the currency symbol to suit your locale (defaults to ₹)
- **Light / Dark / System theme** — switch between themes or follow the system setting
- **Fully offline** — powered by [Hive](https://pub.dev/packages/hive) local storage, no network calls

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart SDK `^3.6.0`) |
| Design System | Material 3 (`useMaterial3: true`) |
| State Management | [Provider](https://pub.dev/packages/provider) (`ChangeNotifier`) |
| Local Storage | [Hive](https://pub.dev/packages/hive) + [Hive Flutter](https://pub.dev/packages/hive_flutter) |
| CSV Handling | [csv](https://pub.dev/packages/csv) |
| File Picking | [file_picker](https://pub.dev/packages/file_picker) |
| Sharing | [share_plus](https://pub.dev/packages/share_plus) |
| Date/Number Formatting | [intl](https://pub.dev/packages/intl) |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `3.6.0` or later
- Android SDK (for Android builds)

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd expense_tracker

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Generate launcher icon

```bash
flutter pub run flutter_launcher_icons
```

The icon source is located at `assets/icon/app_icon.png`.

## Project Structure

```
lib/
├── main.dart                        # App entry point & MultiProvider setup
├── models/
│   ├── expense.dart                 # Expense data model
│   └── category.dart                # ExpenseCategory data model
├── providers/
│   ├── expense_provider.dart        # Expense CRUD, search & filter state
│   ├── category_provider.dart       # Category CRUD & expense migration
│   └── settings_provider.dart       # Theme mode & currency symbol
├── screens/
│   ├── home_screen.dart             # Bottom nav shell (Expenses / Stats / Settings)
│   ├── add_expense_screen.dart      # Add or edit an expense (form)
│   ├── categories_screen.dart       # Manage categories
│   ├── statistics_screen.dart       # Weekly / Monthly / Yearly breakdowns
│   └── settings_screen.dart         # Theme, currency, categories & CSV data
├── services/
│   ├── storage_service.dart         # Hive initialisation & default category seeding
│   └── csv_service.dart             # CSV export (with share sheet) & import
├── utils/
│   ├── theme.dart                   # Light & dark Material 3 theme definitions
│   └── formatters.dart              # Currency & date formatting helpers
└── widgets/
    ├── expense_tile.dart            # Reusable expense list item card
    └── empty_state.dart             # Placeholder shown when lists are empty
```

## Architecture Overview

The app follows a straightforward **Provider + Service** pattern:

1. **Models** — plain Dart classes with `toMap()` / `fromMap()` serialisation for Hive storage.
2. **Services** — `StorageService` manages Hive box lifecycle and seeds default categories on first launch. `CsvService` handles exporting expenses to CSV (with share-sheet) and importing from a user-selected file.
3. **Providers** — `ChangeNotifier` classes that own the in-memory state, read/write to Hive, and notify the UI on changes.
4. **Screens & Widgets** — stateless and stateful widgets that consume providers via `context.watch` / `context.read`.

## CSV Format

Exported and imported CSV files use the following columns:

| Column | Description |
|---|---|
| `id` | Unique expense identifier |
| `amount` | Expense amount (decimal) |
| `items` | Item description |
| `categoryId` | Internal category ID |
| `categoryName` | Human-readable category name |
| `date` | ISO 8601 date string |

During import, if a `categoryId` is missing but a `categoryName` is provided, the app will match an existing category by name or create a new one automatically.

## License

This project is for personal use.
