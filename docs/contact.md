# 🏋️‍♂️ FocusFit - Productivity-Focused Workout Tracker

## 📱 Tech Stack

- **Frontend**: Flutter with Dart
- **State Management**: Provider (or Riverpod for complex state)
- **Database**: SQLite (local) with cloud sync option via Supabase
- **UI Framework**: Flutter Material Design 3.0 + Custom Widgets
- **Analytics**: `fl_chart` for progress visualization
- **Timer**: Custom implementation for workout timing

---

## 🎯 Core Focus Features

1. **Distraction-Free Mode**
   - Screen dimming for better focus
   - Do Not Disturb integration
   - Workout-only screen mode
   - Timer-based exercise tracking

2. **Progress Tracking**
   - Visual progress indicators
   - Achievement system
   - Streak tracking
   - Personal records logging

3. **Smart Scheduling**
   - AI-powered workout suggestions
   - Rest period recommendations
   - Optimal workout time suggestions

---

## 🧭 Detailed App Flow

### 1. **Onboarding Experience**
- Minimalist welcome screen
- Quick 3-step onboarding:
  1. Fitness goals selection
  2. Experience level assessment
  3. Preferred workout days/times
- Authentication options:
  - Email/Password
  - Biometric login
  - Guest mode with limited features

### 2. **Home Dashboard**
- Today's workout status
- Focus metrics:
  - Current streak
  - Weekly completion rate
  - Focus time accumulated
- Quick-start button for planned workout
- Progress overview cards

### 3. **Workout Planning**
- Template-based workout creation
- Custom workout builder
- Exercise library with:
  - Form guides
  - Video demonstrations
  - Equipment requirements
- Smart rest timer suggestions

### 4. **Focus Mode Workout**
- Distraction blocking features:
  - Auto DND activation
  - Screen dimming
  - Focus time tracking
- Exercise progression:
  - Current exercise display
  - Next exercise preview
  - Rest timer with haptic feedback
  - Voice prompts (optional)
- Real-time tracking:
  - Set completion
  - Weight/reps logging
  - Rest period adherence

### 5. **Progress Analytics**
- Detailed metrics:
  - Workout completion rates
  - Focus time trends
  - Strength progression
  - Volume tracking
- Visual representations:
  - Heat maps for consistency
  - Progress charts
  - Achievement badges

### 6. **Smart Recovery**
- Rest day recommendations
- Recovery tracking
- Sleep quality integration
- Deload week suggestions

### 7. **Profile & Settings**
- User stats dashboard
- Customization options:
  - Focus mode preferences
  - Notification settings
  - Timer configurations
  - Theme selection
- Data management:
  - Export functionality
  - Backup options
  - Privacy settings

---

## 🚀 Productivity Features

### Focus Enhancement
- **Timer Presets**
  - Exercise-specific timers
  - Rest period customization
  - Circuit training modes
  
### Progress Motivation
- **Achievement System**
  - Daily streaks
  - Monthly challenges
  - Personal records
  - Focus time milestones

### Smart Notifications
- **Intelligent Reminders**
  - Based on user's active hours
  - Workout preparation alerts
  - Recovery reminders
  - Progress milestones

---

## 🔄 Future Enhancements

### Phase 1 (Month 1-2)
- Basic workout tracking
- Focus mode implementation
- Core progress metrics

### Phase 2 (Month 3-4)
- Smart scheduling
- Advanced analytics
- Social features

### Phase 3 (Month 5-6)
- AI-powered recommendations
- Wearable integration
- Advanced performance metrics

---

## 📈 Success Metrics

- User engagement rate
- Workout completion rate
- Focus time per session
- User retention metrics
- Progress achievement rate

---

## 🔐 Data Security

- Local data encryption
- Secure cloud sync
- GDPR compliance
- Regular backup options

---

For technical implementation details, refer to the API documentation and component specifications in the development guide.

# 🏋️‍♂️ FocusFit - Phase 1 Implementation Guide

## 📱 Initial Setup

### 1. Project Configuration
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.10.25
  provider: ^6.1.1
  fl_chart: ^0.65.0
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^16.3.0
```

### 2. Environment Setup
```dart
// lib/config/env.dart
class Environment {
  static const String SUPABASE_URL = 'YOUR_SUPABASE_URL';
  static const String SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
}
```

## 🎯 Phase 1: Core Focus Mode Implementation

### 1. Database Schema (Supabase)

```sql
-- workouts table
create table workouts (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users,
  name text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  focus_duration integer,
  completed boolean default false
);

-- exercises table
create table exercises (
  id uuid default uuid_generate_v4() primary key,
  workout_id uuid references workouts,
  name text not null,
  sets integer,
  reps integer,
  weight numeric,
  rest_duration integer,
  completed_sets integer default 0
);

-- focus_sessions table
create table focus_sessions (
  id uuid default uuid_generate_v4() primary key,
  workout_id uuid references workouts,
  start_time timestamp with time zone,
  end_time timestamp with time zone,
  total_focus_time integer,
  interruptions integer default 0
);
```

### 2. Core Features Implementation

#### A. Focus Mode Screen
```dart
// lib/screens/focus_mode_screen.dart

class FocusModeScreen extends StatefulWidget {
  final Workout workout;
  
  @override
  _FocusModeScreenState createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  late Timer _focusTimer;
  late Timer _restTimer;
  bool _isInFocusMode = false;
  int _currentExerciseIndex = 0;
  
  // Focus mode settings
  final _screenBrightness = 0.5;
  final _defaultRestDuration = 90; // seconds
  
  @override
  void initState() {
    super.initState();
    _initializeFocusMode();
  }
  
  Future<void> _initializeFocusMode() async {
    // Request DND permissions
    await FlutterDnd.requestPermissions();
    // Dim screen
    await Screen.setBrightness(_screenBrightness);
    // Start focus session
    _startFocusSession();
  }
  
  void _startFocusSession() {
    setState(() {
      _isInFocusMode = true;
    });
    _focusTimer = Timer.periodic(Duration(seconds: 1), _updateFocusTimer);
  }
  
  // ... rest of implementation
}
```

#### B. Exercise Timer Component
```dart
// lib/widgets/exercise_timer.dart

class ExerciseTimer extends StatelessWidget {
  final int duration;
  final Function onComplete;
  
  @override
  Widget build(BuildContext context) {
    return CircularCountDownTimer(
      duration: duration,
      initialDuration: 0,
      controller: _controller,
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.height / 2,
      ringColor: Colors.grey[300]!,
      fillColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      strokeWidth: 20.0,
      strokeCap: StrokeCap.round,
      textStyle: TextStyle(
        fontSize: 33.0,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      textFormat: CountdownTextFormat.S,
      isReverse: true,
      isReverseAnimation: true,
      isTimerTextShown: true,
      autoStart: true,
      onComplete: () => onComplete(),
    );
  }
}
```

#### C. Focus Session Provider
```dart
// lib/providers/focus_session_provider.dart

class FocusSessionProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  FocusSession? _currentSession;
  
  Future<void> startSession(String workoutId) async {
    try {
      final response = await _supabase
          .from('focus_sessions')
          .insert({
            'workout_id': workoutId,
            'start_time': DateTime.now().toIso8601String(),
          })
          .execute();
      
      _currentSession = FocusSession.fromJson(response.data[0]);
      notifyListeners();
    } catch (e) {
      print('Error starting focus session: $e');
      throw e;
    }
  }
  
  Future<void> endSession() async {
    if (_currentSession == null) return;
    
    try {
      await _supabase
          .from('focus_sessions')
          .update({
            'end_time': DateTime.now().toIso8601String(),
            'total_focus_time': _calculateTotalFocusTime(),
          })
          .eq('id', _currentSession!.id)
          .execute();
      
      _currentSession = null;
      notifyListeners();
    } catch (e) {
      print('Error ending focus session: $e');
      throw e;
    }
  }
  
  int _calculateTotalFocusTime() {
    if (_currentSession == null) return 0;
    final now = DateTime.now();
    final start = DateTime.parse(_currentSession!.startTime);
    return now.difference(start).inSeconds;
  }
}
```

### 3. User Interface Implementation

#### A. Focus Mode UI
```dart
// lib/widgets/focus_mode_display.dart

class FocusModeDisplay extends StatelessWidget {
  final Exercise currentExercise;
  final int remainingTime;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentExercise.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ExerciseTimer(
            duration: remainingTime,
            onComplete: () => _handleExerciseComplete(),
          ),
          SizedBox(height: 20),
          ExerciseDetails(exercise: currentExercise),
          NextExercisePreview(),
        ],
      ),
    );
  }
}
```

### 4. Testing Implementation

```dart
// test/focus_mode_test.dart

void main() {
  group('Focus Mode Tests', () {
    test('Should start focus session', () async {
      final provider = FocusSessionProvider();
      await provider.startSession('test-workout-id');
      expect(provider.currentSession, isNotNull);
    });
    
    test('Should calculate focus time correctly', () {
      // Add focus time calculation tests
    });
    
    test('Should handle exercise transitions', () {
      // Add exercise transition tests
    });
  });
}
```

## 📝 Next Steps

1. **Implement User Authentication**
   - Set up Supabase auth
   - Create login/signup flows
   - Implement session management

2. **Add Exercise Library**
   - Create exercise database
   - Implement search and filtering
   - Add exercise details and instructions

3. **Implement Progress Tracking**
   - Create progress charts
   - Implement streak tracking
   - Add achievement system

---

## 🔍 Testing Guidelines

1. **Unit Tests**
   - Test focus timer functionality
   - Test exercise transitions
   - Test data persistence

2. **Integration Tests**
   - Test focus mode flow
   - Test data syncing with Supabase
   - Test notifications and DND mode

3. **User Testing**
   - Test screen brightness changes
   - Test timer accuracy
   - Test exercise flow

---

## 📱 Running the App

1. Clone the repository
2. Add your Supabase credentials to `lib/config/env.dart`
3. Run `flutter pub get`
4. Run `flutter run`

---

For the next phase, we will implement the smart scheduling system and advanced analytics. But first, let's ensure this core functionality is working perfectly.

