# 🏗️ Vibe Habits Architecture

This document provides a comprehensive overview of the Vibe Habits project structure and architectural decisions.

## 📂 Project Structure

```
habits tracker/
├── habits tracker/
│   ├── habits_trackerApp.swift       # App entry point + splash screen logic
│   ├── Models/                        # Data models
│   │   ├── Habit.swift               # Core habit entity
│   │   ├── HabitLog.swift            # Progress tracking entries
│   │   └── FrequencyType.swift       # Tracking mode enum
│   ├── ViewModels/                    # Business logic
│   │   └── HabitStore.swift          # State management & data operations
│   ├── Views/                         # UI components
│   │   ├── MainTabView.swift         # Root tab navigation
│   │   ├── HabitsListView.swift      # Main habits list screen
│   │   ├── HabitCardView.swift       # Individual habit card with grid
│   │   ├── AddHabitView.swift        # Habit creation form
│   │   ├── ProgressLogView.swift     # Log progress modal
│   │   ├── EditLogView.swift         # Edit/delete log modal
│   │   ├── InsightsView.swift        # Detailed statistics
│   │   ├── SettingsView.swift        # App settings
│   │   └── SplashScreenView.swift    # Animated launch screen
│   ├── Managers/                      # Services
│   │   └── NotificationManager.swift # Daily reminders
│   ├── Assets.xcassets/              # Images & colors
│   ├── ContentView.swift             # (Unused - legacy)
│   └── Item.swift                    # (Unused - legacy)
├── habits trackerTests/              # Unit tests
├── habits trackerUITests/            # UI tests
├── AppIconImages/                    # Generated app icons
├── generate_icon.swift               # Icon generation script
├── README.md                         # Project overview
├── CLAUDE.md                         # This file - Claude Code guide
└── docs/                             # Extended documentation
    └── ARCHITECTURE.md               # Architecture details
```

## 🔄 Data Flow

### 1. App Launch
```
habits_trackerApp
    ↓
SplashScreenView (2.5s animation)
    ↓
MainTabView
    ↓
HabitsListView (with HabitStore)
```

### 2. Habit Creation
```
User taps "+" button
    ↓
AddHabitView modal opens
    ↓
User fills form (name, frequency, target)
    ↓
HabitStore.addHabit()
    ↓
SwiftData saves to persistent store
    ↓
UI automatically updates via @Query
```

### 3. Progress Logging
```
User taps "Log Progress"
    ↓
ProgressLogView modal opens
    ↓
User enters value
    ↓
HabitStore.logProgress()
    ↓
Creates/updates HabitLog entry
    ↓
Grid updates with new intensity color
```

### 4. Editing Past Logs
```
User taps colored square in grid
    ↓
EditLogView modal opens
    ↓
User edits value or deletes
    ↓
HabitStore.logProgress() or deleteLog()
    ↓
Grid square updates
```

## 🧩 Core Components

### Models Layer

#### `Habit.swift`
```swift
@Model
final class Habit {
    var id: UUID
    var name: String
    var frequencyType: FrequencyType
    var targetValue: Double
    var createdAt: Date
}
```
- SwiftData model for persistence
- Unique ID for tracking
- Supports three frequency types
- Tracks creation date for stats

#### `HabitLog.swift`
```swift
@Model
final class HabitLog {
    var id: UUID
    var habitId: UUID          // Links to parent habit
    var date: Date             // Day of log
    var value: Double          // Progress amount
    var completed: Bool        // Met target?
}
```
- One log per day per habit
- Stores actual progress value
- Completion status calculated from target

#### `FrequencyType.swift`
```swift
enum FrequencyType: String, Codable, CaseIterable {
    case daily = "Daily Goal"
    case timesPerWeek = "Times per Week"
    case hoursPerWeek = "Hours per Week"
}
```
- Three tracking modes
- Determines button behavior and stats calculation

### ViewModel Layer

#### `HabitStore.swift`
Central state management class with:

**CRUD Operations:**
- `addHabit()` - Create new habit
- `updateHabitName()` - Rename habit
- `deleteHabit()` - Remove habit and logs
- `logProgress()` - Add/update log entry
- `deleteLog()` - Remove specific log

**Data Queries:**
- `getLogs()` - Fetch all logs for habit
- `getLog(date:)` - Get specific day's log

**Statistics:**
- `getTodayValue()` - Current day progress
- `getWeekValue()` - Last 7 days total
- `getTotalDays()` - Count of completed days
- `getCurrentStreak()` - Active streak count
- `getLongestStreak()` - Best streak ever
- `getCompletionRate()` - Percentage calculation
- `getTotalCompleted()` - Cumulative sum

**Grid Generation:**
- `getLast12Weeks()` - Returns WeekData array for grid
- Calculates intensity levels
- Marks today's square

### View Layer

#### Navigation Hierarchy
```
MainTabView
├── HabitsListView (Tab 1)
│   ├── HabitCardView (per habit)
│   │   ├── StreakGridView
│   │   │   └── DaySquareView (84 squares)
│   │   └── Modals:
│   │       ├── ProgressLogView
│   │       ├── EditLogView
│   │       └── InsightsView
│   └── Modal: AddHabitView
└── SettingsView (Tab 2)
```

#### Key Views Explained

**HabitsListView**
- Main screen showing all habits
- Empty state with call-to-action
- Creates HabitStore from model context
- Presents AddHabitView as sheet

**HabitCardView**
- Displays single habit
- Editable title (tap to edit)
- Action buttons (log/complete + details)
- 12-week grid visualization
- Stats bar (week, total, streak)
- Color legend

**StreakGridView**
- HStack of 12 weeks (columns)
- VStack of 7 days per week (rows)
- 3pt spacing between squares
- Dynamic sizing based on width

**DaySquareView**
- Individual square in grid
- Color based on IntensityLevel
- Blue border for today
- Tap to edit (if has log)
- Shows EditLogView modal

**AddHabitView**
- Form-based input
- Name text field
- Frequency selection (3 cards)
- Target value input
- Examples section
- Validation (disabled until valid)

**ProgressLogView**
- Medium-sized sheet
- Large numeric input
- Target displayed
- Update button (disabled if invalid)

**EditLogView**
- Shows existing value
- Update or delete options
- Custom drag indicator
- Rounded number input
- Icon-based buttons

**InsightsView**
- Left-aligned header
- 2×2 grid of compact metrics
- Full-width total completed card
- Motivational message with icon
- Dynamic content based on streak

**SettingsView**
- Native List layout
- Notifications toggle
- About section with version
- Tips for success

**SplashScreenView**
- Gradient background
- Animated 3×3 grid
- Ripple effect circles
- Text fade-in
- 2.5s total duration
- Spring animations

### Services Layer

#### `NotificationManager.swift`
- Singleton pattern
- Requests notification permission
- Schedules daily reminder (9 PM)
- Cancels notifications on toggle off
- Uses UNUserNotificationCenter

## 🎨 Design Patterns

### 1. Observable Objects
- `HabitStore` uses `@Observable` macro
- Automatic UI updates on data changes
- No need for `objectWillChange.send()`

### 2. SwiftData Integration
- `@Model` macro on entities
- `@Query` property wrapper in views
- `ModelContext` for operations
- Automatic persistence

### 3. Environment Injection
- ModelContext injected via `.modelContainer()`
- Passed to HabitStore on init
- Accessible throughout view hierarchy

### 4. Sheet Presentations
- `.sheet(isPresented:)` for modals
- `.presentationDetents()` for sizing
- Dismissal via `@Environment(\.dismiss)`

### 5. Computed Properties
- Grid data calculated on-demand
- Stats computed from logs
- No cached state (source of truth)

## 🔒 Data Persistence

### SwiftData Schema
```swift
Schema([
    Habit.self,
    HabitLog.self
])
```

### Storage Location
- Local device storage
- SQLite under the hood
- Automatic migration handling

### Fetch Descriptors
```swift
FetchDescriptor<HabitLog>(
    predicate: #Predicate { log in
        log.habitId == habitId
    },
    sortBy: [SortDescriptor(\.date, order: .reverse)]
)
```

### Query Performance
- Predicate limitations (can't use computed dates in predicate)
- Solution: Fetch all + filter in Swift
- Acceptable for habit tracking use case

## 🎯 State Management

### App-Level State
- `showSplash` in `habits_trackerApp`
- Controls splash → main transition

### View-Level State
- `@State` for local UI state
- `showingAddHabit`, `showingEditLog`, etc.
- Modal presentation flags

### Persistent State
- SwiftData handles persistence
- `@AppStorage` for settings (notifications)
- No manual UserDefaults needed

## 🚀 Performance Considerations

### Efficient Rendering
- SwiftUI only re-renders changed views
- `@Query` automatically optimizes
- Grid uses GeometryReader for sizing

### Memory Management
- No retain cycles
- Weak references in closures
- SwiftData handles cleanup

### Animation Performance
- Spring animations are GPU-accelerated
- Minimal layout calculations
- 60 FPS on modern devices

## 🧪 Testing Strategy

### Unit Tests
- Test HabitStore logic
- Verify stat calculations
- Mock ModelContext if needed

### UI Tests
- Test navigation flows
- Verify modal presentations
- Check empty states

### Manual Testing
- Test on multiple device sizes
- Verify Dark Mode support
- Check accessibility with VoiceOver

## 📱 Device Support

### iOS Versions
- **Target**: iOS 17.0+
- **Reason**: SwiftData requires iOS 17

### Devices
- iPhone SE (2nd gen) and newer
- iPad support (adaptive layout)
- Mac Catalyst compatible

### Orientations
- Portrait (primary)
- Landscape (supported)
- Adaptive grid sizing

## 🔮 Scalability

### Adding Features
- New models: Add to Schema
- New views: Add to Views/
- New stats: Extend HabitStore

### Performance at Scale
- Tested with 50+ habits
- 12 weeks × 7 days = 84 logs max visible
- Fetch optimization via predicates

### Data Migration
- SwiftData handles schema changes
- Add new properties with defaults
- Migrations are automatic

## 🛠️ Development Tips

### Debugging SwiftData
```swift
let descriptor = FetchDescriptor<Habit>()
let habits = try? modelContext.fetch(descriptor)
print("Habits: \(habits?.count ?? 0)")
```

### Testing Splash Screen
- Change delay in `SplashScreenView`
- Set `showSplash = false` to skip

### Previews with SwiftData
```swift
#Preview {
    let container = try! ModelContainer(
        for: Habit.self,
        HabitLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    return MyView()
        .modelContainer(container)
}
```

### Custom Colors
- Use `Color(.systemBlue)` for system colors
- Define custom in Assets.xcassets
- Support Dark Mode variants

## 📚 Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

---

**Last Updated**: October 2025
**Built with**: Claude Code by Anthropic
