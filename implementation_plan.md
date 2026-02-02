# Implementation Plan - Tempo (Time Investment App)

This plan outlines the steps to build the MVP of "Tempo," a time investment tracking app built with Flutter.

## 📱 Tech Stack
-   **Framework**: Flutter (Mobile - iOS/Android)
-   **State Management**: Flutter Riverpod
-   **Local Database**: Isar (High performance NoSQL, ideal for time series)
-   **Navigation**: GoRouter
-   **UI/Styling**: Custom Design System (Clean, Mono-chromatic)
-   **Icons**: Lucide Icons or Cupertino/Material hybrid

## 🏗️ Phase 1: Project Initialization & Foundation
- [ ] **Initialize Flutter Project**
    - Create new project `tempo`.
    - Setup analysis options (linting).
- [ ] **Install Dependencies**
    - `flutter_riverpod`, `riverpod_annotation`
    - `go_router`
    - `isar`, `isar_flutter_libs`, `path_provider`
    - `google_fonts` (Inter or similar)
    - `intl` (Date formatting)
    - `uuid`
    - `gap` (Spacing)
- [ ] **Setup Architecture**
    - Create folder structure: `lib/core`, `lib/features`.
- [ ] **Design System Setup**
    - Define `AppTheme` (Colors: White, Black, Grays).
    - Define `AppTypography` (Clean, modern sans-serif).
    - Create basic `AppLayout` scaffold.

## 💾 Phase 2: Core Data & Logic
- [ ] **Database Schema (Isar)**
    - Create `TimeEntry` model:
        - `id` (Auto-increment)
        - `title` (String)
        - `category` (enum/String: Work, Gaming, Sleep, etc.)
        - `type` (enum: Invested, Spent)
        - `durationInMinutes` (int)
        - `startTime` (DateTime)
        - `notes` (String, optional)
    - Generate Isar code listeners.
- [ ] **Repositories**
    - Create `TimeRepository`: Methods for `addEntry`, `getEntriesForDay`, `deleteEntry`.
- [ ] **State Management**
    - Create `ledger_provider.dart`: To manage the list of entries for the selected date.
    - Create `date_provider.dart`: To manage the currently selected calendar date.

## 🎨 Phase 3: UI Implementation - Ledger Tab
- [ ] **Components**
    - `CalendarStrip`: Horizontal scrollable week view (like design Screen 1).
    - `TimeEntryCard`: List item showing Category, Title, Duration (like design Screen 1).
    - `SummaryHeader`: "Invested vs Spent" quick summary.
- [ ] **Ledger Screen**
    - Assemble the screen with CalendarStrip and TimeEntryList.
    - Implement navigation bar (Ledger, Add, Analysis).

## ➕ Phase 4: Manual Entry (The Core Feature)
- [ ] **Add Entry Modal (Screen 3)**
    - Create a custom BottomSheet or FullScreenDialog.
    - **Category Selector**: Chips for "Work", "Exercise", "Gaming", etc.
    - **Time Input**:
        - Simple duration picker (1h, 30m chips).
        - +/- Steppers for fine-tuning.
    - **Save Action**: Connect to `TimeRepository`.

## 🔄 Phase 5: Polish & Validation
- [ ] **Integration**
    - Ensure adding an entry updates the Ledger list immediately.
    - Verify persistence (restart app).
- [ ] **UX Polish**
    - Add basic animations (entry insertion).
    - Verify touch targets and accessibility.

## 🚀 Next Steps (Post-MVP)
-   Analytics/Charts (Screen 2).
-   User Auth & Cloud Sync (SaaS features).
-   Subscription Paywall.
