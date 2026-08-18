# 📱 Vibe Habits

A lightweight iOS habit tracker built with SwiftUI and SwiftData, designed with Apple's Human Interface Guidelines in mind.

## ✨ Features

- **Visual Streak Tracking**: 12-week grid visualization with GitHub-style intensity colors
- **Flexible Tracking**: Support for daily goals, weekly frequency, and hourly targets
- **Progress Insights**: Comprehensive statistics including streaks, completion rates, and motivational messages
- **Daily Reminders**: Push notifications to help maintain consistency (9 PM daily)
- **Per-habit Reminders**: Choose a reminder time while creating a habit
- **Starter Templates**: Begin with practical examples during onboarding
- **Portable Backups**: Export and restore your data as a JSON file you control
- **Home Screen Widgets**: Glance at today's completed habits without opening the app
- **English & Brazilian Portuguese**: Localized app and App Store listing
- **Native iOS Design**: Clean, intuitive interface following HIG principles

## 🏗 Architecture

### Models
- **Habit**: Core habit entity with name, frequency type, and target value
- **HabitLog**: Individual progress entries linked to habits
- **FrequencyType**: Enum supporting daily goals, times per week, and hours per week

### Views
- **MainTabView**: Tab-based navigation (Habits & Settings)
- **HabitsListView**: Main screen with habit cards
- **HabitCardView**: Individual habit display with 12-week grid and stats
- **AddHabitView**: Form-based habit creation modal
- **ProgressLogView**: Numeric input for logging progress
- **InsightsView**: Detailed statistics and motivational messaging
- **SettingsView**: App configuration and tips

### Services
- **HabitStore**: State management using SwiftData's ModelContext
- **NotificationManager**: Daily reminder scheduling with UserNotifications

## 🚀 Getting Started

1. Open `habits tracker.xcodeproj` in Xcode 16+
2. Select your target device (iOS 18.6+)
3. Build and run (⌘R)

## 🚢 App Store releases

Fastlane and GitHub Actions upload every new semantic version tag (`vMAJOR.MINOR.PATCH`) to App Store Connect/TestFlight and synchronize the version's metadata and screenshots. See [docs/APP_STORE_RELEASE.md](docs/APP_STORE_RELEASE.md) for the one-time signing setup, required GitHub secrets, and the App Store submission checklist.

## 📊 Key Statistics Tracked

- Current & longest streaks
- Total completed days
- Completion rate
- Perfect days count
- Cumulative totals

## 🎨 Design Principles

- Clean, minimal interface
- Native SF Symbols icons
- Adaptive Dark Mode support
- Dynamic Type accessibility
- Spring-based animations

## 📝 License

Built with [Claude Code](https://claude.com/claude-code)
