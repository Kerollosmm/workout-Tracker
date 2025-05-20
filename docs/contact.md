# Contributing to Workout Tracker

Thank you for your interest in contributing to the Workout Tracker app! This document provides guidelines for contributing to the project while maintaining a simple and effective user experience.

## Vision & Goals

Workout Tracker aims to help users track their fitness journey with a clean, intuitive interface without overwhelming them with excessive features. Our focus is on functionality, usability, and maintaining a lightweight app that performs well across devices.

## Recommended Feature Additions

Below are feature suggestions that align with our vision of keeping the app simple yet effective:

### 1. Rest Timer
A simple timer feature that allows users to track rest periods between sets. Should include:
- Configurable presets (30s, 60s, 90s, 2min)
- Simple start/pause/reset controls
- Optional sound notification

### 2. Personal Records (PRs) Tracking
Allow users to highlight and track their personal records for different exercises:
- Automatic PR detection when a user exceeds previous best
- Simple PR history view per exercise
- Optional congratulatory notification

### 3. Workout Reminders
Basic notification system to remind users of planned workouts:
- Set days/times for reminders
- Simple on/off toggle
- Option to include workout details in notification

### 4. Quick Workout Templates
Allow users to save and quickly load common workouts:
- Save current workout as template
- Name and categorize templates
- One-tap to load a template for a new workout

### 5. Basic Exercise Library
A simple database of common exercises with basic information:
- Categorized by muscle group
- Simple illustrations or descriptions
- Option for users to add custom exercises

## Design Guidelines

### UI/UX Principles
- **Simplicity First**: Every screen should have a clear purpose and minimal clutter
- **Consistency**: Maintain consistent layout, color scheme, and interaction patterns
- **Accessibility**: Support text scaling, high contrast, and screen readers
- **Quick Entry**: Minimize taps required for frequent actions like logging a workout
- **Visual Feedback**: Provide clear feedback for user actions

### Color Palette

#### Primary Colors
- Primary Blue (#3B82F6)
- Dark Gray (#1F2937)

#### Accent Colors
- Success Green (#10B981)
- Alert Red (#EF4444)

## Code Structure & Architecture

Feature-based organization: Group files by feature rather than type
- State management: Use Provider or Riverpod for simpler state management
- Data persistence: SQLite via sqflite package for local storage
- Widgets: Create reusable widgets for common UI elements

```
lib/
├── main.dart
├── app.dart
├── common/
│ ├── constants/
│ ├── widgets/
│ └── utils/
├── features/
│ ├── workout_tracking/
│ │ ├── models/
│ │ ├── screens/
│ │ ├── widgets/
│ │ └── services/
│ ├── progress_charts/
│ │ ├── models/
│ │ ├── screens/
│ │ └── widgets/
│ └── ...
└── services/
├── database/
├── navigation/
└── ...
```

## Contribution Process

### Getting Started
1. Fork the repository
2. Clone your fork: 
   ```
   git clone https://github.com/YOUR_USERNAME/workout-Tracker.git
   ```
3. Create a feature branch: 
   ```
   git checkout -b feature/your-feature-name
   ```
4. Install dependencies: 
   ```
   flutter pub get
   ```

### Development Guidelines
- Follow Flutter's official style guide and best practices
- Write clear, commented code
- Keep performance in mind – the app should run smoothly on older devices
- Ensure the app works in offline mode
- Add appropriate unit and widget tests for new features

### Pull Request Process
1. Ensure your code follows the project's style guidelines
2. Update documentation as needed
3. Include screenshots or GIFs of UI changes if applicable
4. Make sure all tests pass: 
   ```
   flutter test
   ```
5. Create a pull request with a clear description of the changes

## What to Avoid
- **Feature overload**: Adding too many features that complicate the user experience
- **Heavy dependencies**: Introducing large packages for small functionality
- **Complex UI**: Multi-step processes that could be simplified
- **Reinventing the wheel**: Building custom solutions for problems already solved by Flutter or common packages
- **Breaking offline functionality**: All features should work without internet connection

This document is a living guide and may be updated as the project evolves. Thank you for helping make Workout Tracker better while keeping it simple and focused!