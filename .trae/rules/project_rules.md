AI Rules & Guidelines for Workout Tracker
Flutter App Development Standards & AI Integration

Overview
This document outlines the rules, guidelines, and best practices for AI integration, code standards, and contribution protocols for the Workout Tracker Flutter application. These guidelines ensure consistency, maintainability, and high code quality across the project while leveraging AI tools ethically and effectively.

 Flutter
 Fitness App
 AI Integration
 Coding Standards
 Contribution Rules
1. AI Integration Guidelines
1.1 Approved AI Tools & Platforms
The following AI tools and platforms are approved for use in the Workout Tracker project:

Tool/Platform	Approved Use Cases	Limitations
GitHub Copilot	Code completion, documentation generation, refactoring suggestions	Do not accept suggestions for security-critical code without review
ChatGPT/GPT models	Architecture ideas, debugging assistance, documentation drafting	No sharing of proprietary code; verify all generated code
TensorFlow/ML Kit	Exercise recognition, form correction, personalized recommendations	Must run efficiently on mobile devices; test on low-end devices
Flutter AI packages	Image recognition, voice commands, personalized workout generation	Must have active maintenance and community support
1.2 AI-Assisted Code Practices
Disclosure requirement: All AI-generated or AI-assisted code must be clearly marked in PR descriptions with the tag [AI-ASSISTED] and include which tool was used.
Review mandate: AI-generated code requires at least one human review before merging.
Testing coverage: AI-generated code must have 100% test coverage to ensure functionality.
Quality responsibility: The developer submitting AI-generated code is responsible for its quality, performance, and security.
Prompt logging: For significant AI contributions, log the prompts used in a docs/ai-prompts/ directory for reproducibility.
1.3 AI Features in the App
For AI features integrated into the Workout Tracker app itself (e.g., workout recommendations, form correction):

User consent: All AI features must be opt-in and clearly described to users.
Privacy-first: AI features should prioritize on-device processing where possible.
Transparency: Add a dedicated "AI Features" section in settings to explain how AI is used.
Fallback mechanisms: All AI features must have graceful degradation if AI fails or is unavailable.
Performance impact: AI features should not significantly degrade app performance or battery life.
2. Flutter Code Standards
2.1 Architecture
The Workout Tracker app follows a clean architecture approach with clearly separated layers:

Presentation layer: UI components, screens, widgets
Domain layer: Business logic, models, use cases
Data layer: Repositories, data sources, API clients
State Management
Use Provider/Riverpod for simple state management and Bloc for complex features. Avoid mixing state management approaches within a single feature.

// Example of proper Provider usage
final workoutProvider = Provider((ref) {
  return WorkoutRepositoryImpl(ref.read(databaseProvider));
});

// Example of proper Bloc/Cubit usage
class WorkoutCubit extends Cubit {
  final WorkoutRepository repository;
  
  WorkoutCubit(this.repository) : super(WorkoutInitial());
  
  Future loadWorkouts() async {
    emit(WorkoutLoading());
    try {
      final workouts = await repository.getWorkouts();
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }
}
2.2 Naming Conventions
Files: Use snake_case for file names (e.g., workout_tracker.dart)
Classes: Use PascalCase for class names (e.g., WorkoutTracker)
Variables/Functions: Use camelCase (e.g., workoutList, getWorkouts())
Constants: Use SCREAMING_SNAKE_CASE for constants (e.g., MAX_WORKOUT_COUNT)
Private members: Prefix with underscore (e.g., _privateVariable)
2.3 Code Organization
Follow this project structure:

workout_tracker/
├── lib/
│   ├── core/               # Core utilities and common functionality
│   │   ├── constants/      # App-wide constants
│   │   ├── errors/         # Error handling
│   │   ├── util/           # Utilities
│   │   └── widgets/        # Common widgets
│   │
│   ├── data/               # Data layer
│   │   ├── models/         # Data models
│   │   ├── repositories/   # Repositories implementation
│   │   └── sources/        # Data sources (local, remote)
│   │
│   ├── domain/             # Domain layer
│   │   ├── entities/       # Business entities
│   │   ├── repositories/   # Repository interfaces
│   │   └── usecases/       # Use cases
│   │
│   ├── presentation/       # Presentation layer
│   │   ├── bloc/           # Blocs/Cubits
│   │   ├── pages/          # Full screen pages
│   │   └── widgets/        # Feature-specific widgets
│   │
│   └── main.dart           # Entry point
│
├── test/                   # Test files mirroring lib/ structure
└── assets/                 # App assets
    ├── images/
    ├── fonts/
    └── icons/
2.4 Documentation Standards
Class documentation: All classes must have dartdoc comments explaining their purpose
Public APIs: All public methods and properties must be documented
Complex logic: Add inline comments to explain complex algorithms or business rules
/// A repository that manages workout data.
///
/// This repository handles CRUD operations for workouts, including
/// storing them locally and synchronizing with remote servers when online.
class WorkoutRepository {
  /// Fetches all workouts for a specific user.
  ///
  /// [userId] - The ID of the user whose workouts to fetch
  /// Returns a Future that completes with a list of [Workout] objects
  /// Throws a [NetworkException] if the server cannot be reached
  Future> getWorkoutsForUser(String userId) async {
    // Implementation
  }

  // Other methods...
}
2.5 Testing Requirements
Unit tests: Required for all repositories, use cases, and complex logic
Widget tests: Required for all reusable widgets
Integration tests: Required for critical user journeys
Coverage target: Aim for at least 80% test coverage
3. AI-Specific Implementation Guidelines
3.1 Workout Recognition & Form Correction
For AI-powered exercise recognition and form correction features:

On-device processing: Use TensorFlow Lite or ML Kit for on-device machine learning to preserve privacy
Model size constraints: Exercise recognition models must be under 10MB to avoid bloating the app
Accuracy metrics: Document accuracy metrics for each model in docs/ai-models/
User feedback: Implement feedback mechanisms to improve models over time
// Example of proper ML model implementation
class ExerciseRecognitionService {
  late tfl.Interpreter _interpreter;
  final int inputSize;
  final double confidenceThreshold;

  ExerciseRecognitionService({
    required this.inputSize,
    this.confidenceThreshold = 0.7,
  });

  Future loadModel() async {
    try {
      final modelFile = await _loadModelFile('assets/models/exercise_recognition.tflite');
      _interpreter = await tfl.Interpreter.fromBuffer(modelFile);
      log.info('Exercise recognition model loaded successfully');
    } catch (e) {
      log.error('Failed to load exercise recognition model: $e');
      throw ModelLoadException('Could not load exercise recognition model');
    }
  }

  Future recognizeExercise(List poses) async {
    // Implementation
  }
}
3.2 Personalized Recommendations
For AI-powered workout recommendations:

Transparency: Clearly communicate to users how recommendations are generated
Progressive data collection: Build user profiles gradually through explicit onboarding and implicit usage patterns
Local-first: Process recommendations on-device when possible
Explainability: Include a brief explanation with each recommendation
3.3 Performance Optimization
Background processing: Run intensive AI tasks on background isolates
Power awareness: Reduce AI feature frequency when battery is low
Caching: Cache AI results to avoid redundant processing
Progressive enhancement: Provide basic functionality without AI, enhance with AI when available
4. Contribution Protocols
4.1 Issue Tracking
All work must be associated with an issue in the GitHub issue tracker.

Issue Templates:
Bug report: For reporting bugs (include steps to reproduce, expected vs. actual behavior)
Feature request: For requesting new features (include user story, acceptance criteria)
AI integration: Specific template for AI-related features (include model details, privacy implications)
4.2 Branching Strategy
Follow this Git branching strategy:

main: Production-ready code only
develop: Integration branch for features
feature/[issue-number]-[brief-description]: For new features
bugfix/[issue-number]-[brief-description]: For bug fixes
ai/[issue-number]-[brief-description]: For AI-specific features or integrations
4.3 Pull Request Process
Create branch: Branch from develop using the naming convention above
Develop & test: Implement the feature and write tests
Submit PR: Create a pull request targeting the develop branch
PR Template: Fill out the PR template completely, including:
Issue reference
Description of changes
Testing performed
Screenshots/videos (for UI changes)
AI disclosure (if applicable)
Code Review: At least one approval is required before merging
CI Checks: All tests, lints, and builds must pass
4.4 Commit Guidelines
Use conventional commits format:

type(scope): subject

[optional body]

[optional footer]
Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore

AI-related commits should use the scope "ai" and include the specific AI tool used in the commit body.

Example: feat(ai): add workout recommendation engine
Using TensorFlow Lite for on-device recommendation generation based on user history
[AI-ASSISTED: GitHub Copilot used for model integration code]
5. AI Ethics & User Privacy
5.1 User Data Protection
Minimized data collection: Collect only the data necessary for core functionality
On-device processing: Prioritize on-device AI processing over cloud-based processing
Anonymization: If data must be sent to servers, anonymize it first
Transparency: Clearly communicate what data is collected and how it's used
Control: Provide users with controls to opt out of AI features or delete their data
5.2 Feature Transparency
For all AI-powered features:

Clear labeling: Mark AI-powered features with a subtle indicator
Explanation: Provide a "How this works" link for each AI feature
Limitations: Be transparent about the capabilities and limitations of AI features
Human oversight: Indicate when and where human review is involved
5.3 Accessibility & Inclusivity
Diverse training data: Ensure AI models are trained on diverse datasets to avoid bias
Alternative interfaces: Provide non-AI alternatives for all core features
Accessibility: Ensure AI features work well with assistive technologies
Regular bias audits: Review AI feature performance across different user demographics
6. Learning Resources
6.1 Recommended Resources
Topic	Resource	Type
Flutter Architecture	Flutter Clean Architecture Guide	Documentation
AI in Flutter	TensorFlow Lite for Flutter	Tutorial
State Management	Flutter Bloc Library Documentation	Documentation
Testing	Testing Flutter Apps	Guide
AI Ethics	Responsible AI Practices	Guidelines
6.2 Project Documentation Structure
All project documentation should be maintained in the 
Conclusion
These guidelines aim to ensure high-quality code, ethical AI integration, and effective collaboration in the Workout Tracker project. All contributors are expected to follow these guidelines and help maintain them as the project evolves.

The guidelines should be reviewed and updated quarterly or when significant changes to AI technologies or Fl