# 🤖 Building Vibe Habits with Claude Code

This document explains the basics of the Vibe Habits project and how it was built with Claude Code.

## 📱 Project Overview

**Vibe Habits** is a lightweight iOS habit tracker built entirely with SwiftUI and SwiftData. The app helps users build consistency through intuitive progress tracking, visual streaks, and meaningful insights.

## 🎯 Core Philosophy

The app was designed with three key principles:
1. **Simplicity First** - Clean, minimal interface following Apple's Human Interface Guidelines
2. **Visual Progress** - GitHub-style 12-week grid for instant motivation
3. **Native Feel** - Built with SwiftUI, feels like a first-party iOS app

## 🏗️ Technology Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData (iOS 17+)
- **Notifications**: UserNotifications framework
- **Architecture**: MVVM-like pattern with Observable objects

## ✨ Key Features

### 1. Habit Tracking
- **Three tracking modes**: Daily goals, times per week, hours per week
- **Visual 12-week grid**: GitHub-style contribution graph
- **Intensity colors**: Visual feedback based on completion percentage
- **Tap to edit**: Long-press any day to edit or delete progress

### 2. Progress Insights
- Longest streak tracking
- Total completed days
- Completion rate percentage
- Dynamic motivational messages
- Cumulative totals

### 3. User Experience
- Animated splash screen on launch
- Custom app icon with gradient design
- Daily reminders at 9 PM
- Dark mode support
- Smooth animations throughout

## 🎨 Design Decisions

### Color System
- **Primary**: Blue (#4D7FFF) - Action buttons and accents
- **Grid Colors**: Green gradient for completion intensity
- **Today Indicator**: Blue border on current day square

### Layout
- Full-width streak grid with proper spacing
- Cards with subtle shadows and rounded corners
- Two-column metrics layout in insights
- Compact action buttons with icons

### Animations
- Spring-based for natural feel
- Ripple effects on splash screen
- Smooth transitions between views
- Grid squares animate on load

## 🚀 Getting Started

### Prerequisites
- Xcode 16.0+
- iOS 17.0+ (target deployment)
- macOS Sonoma or later

### Installation
```bash
git clone https://github.com/raphaelcangucu/vibe-habits.git
cd vibe-habits
open "habits tracker.xcodeproj"
```

### Running the App
1. Select your target device (simulator or physical device)
2. Press ⌘R to build and run
3. The app will show the animated splash screen, then the main interface

## 📁 Project Structure

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed structure documentation.

## 🔧 Development Workflow

### Adding a New Feature
1. Create model if needed in `Models/`
2. Add business logic to `HabitStore.swift`
3. Create view in `Views/`
4. Update navigation in `MainTabView.swift`
5. Test on simulator and device

### Modifying the Icon
Run the icon generator script:
```bash
swift generate_icon.swift
```
Then drag the generated images into Assets.xcassets

## 📊 Data Model

- **Habit**: Core entity (name, frequency type, target value)
- **HabitLog**: Individual progress entries (date, value, completed status)
- **FrequencyType**: Enum defining tracking modes

All data is persisted with SwiftData and automatically syncs across views.

## 🎯 Future Enhancements

Potential features to consider:
- [ ] iCloud sync across devices
- [ ] Widgets for home screen
- [ ] Apple Watch companion app
- [ ] Habit categories and tags
- [ ] Export data to CSV
- [ ] Custom notification times
- [ ] Habit reminders per habit
- [ ] Weekly/monthly reports
- [ ] Social sharing of achievements

## 🤝 Contributing

This is a personal project, but feel free to:
- Fork and experiment
- Open issues for bugs
- Suggest features via discussions
- Share your own habit tracking ideas

## 📝 License

Built with [Claude Code](https://claude.com/claude-code) by Anthropic.

## 🙏 Acknowledgments

- Apple's Human Interface Guidelines for design inspiration
- GitHub's contribution graph for the streak visualization concept
- SwiftUI and SwiftData for making iOS development delightful

---

**Built with ❤️ and Claude Code**
