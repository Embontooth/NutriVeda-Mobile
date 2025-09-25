# Development Setup Guide

## Project Overview
NutriVeda Mobile is a Flutter application designed for dietitians to manage patients, create diet charts, and plan meals. The app implements all the requested features with a professional healthcare-focused design.

## Installation & Setup

### Prerequisites
```bash
# Install Flutter SDK
# Visit: https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor

# Install dependencies
flutter pub get
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run on web (for development)
flutter run -d web

# Run tests
flutter test
```

## App Structure

### Color Scheme (As Requested)
- **Primary Color**: `#FCD7AD` (Light Orange)
- **Secondary Color**: `#A5754D` (Chamoisee)  
- **Background**: `#FFFDF8` (Warm White)
- **Text**: `#2D2D2D` (Dark Gray)

### Screen Flow
```
LoginScreen (Entry Point)
    ↓ (After successful login)
HomeScreen (Bottom Navigation)
    ├── DashboardScreen (Tab 0)
    ├── PatientManagementScreen (Tab 1)
    ├── DietChartBuilderScreen (Tab 2)
    └── FoodPlannerScreen (Tab 3)
```

## Features Implementation

### ✅ Login Page
- Email/password validation
- Secure input fields with visibility toggle
- Custom themed UI matching color requirements
- Navigation to main app after login
- Firebase-ready for future authentication

### ✅ Dashboard
- Patient statistics overview
- Recent activities feed
- Quick action buttons
- Professional card-based layout
- Greeting and user info display

### ✅ Patient Management
- **Add Patients**: Form with name, age, gender, condition
- **Search & Filter**: Real-time search functionality
- **Patient List**: Card-based display with status indicators
- **Actions**: View details, edit, delete, history
- **Sample Data**: Pre-populated for demonstration

### ✅ Diet Chart Builder
- **Create Charts**: Patient selection, goal-based planning
- **Calorie Tracking**: Target calorie specification
- **Status Management**: Active, Draft, Completed states
- **Actions**: View, edit, duplicate, export, delete
- **Meal Planning**: Integration with nutritional data

### ✅ Food Planner  
- **Weekly Plans**: Create and manage weekly meal plans
- **Daily Planning**: Date-based meal scheduling
- **Nutritional Breakdown**: Calories, proteins, carbs, fats
- **Meal Management**: Add, edit, delete individual meals
- **Timing**: Specific meal times and descriptions

## Code Quality
- ✅ Proper Flutter project structure
- ✅ Material Design 3 implementation
- ✅ Responsive UI design
- ✅ State management with StatefulWidget
- ✅ Custom theme implementation
- ✅ Consistent code formatting
- ✅ Widget testing setup

## Future Enhancements (Ready for Implementation)
- [ ] Firebase Authentication integration
- [ ] Firestore database connectivity
- [ ] Advanced nutritional calculations
- [ ] PDF export functionality
- [ ] Push notifications
- [ ] User profile management
- [ ] Data synchronization
- [ ] Offline capabilities

## Firebase Integration Notes
The app is structured to easily integrate with Firebase:
- Authentication flow is ready in `login_screen.dart`
- Data models can be adapted for Firestore
- User state management prepared
- Cloud storage ready for file uploads

## Technical Specifications
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **Design**: Material Design 3
- **Architecture**: Widget-based with proper separation
- **Testing**: Flutter test framework
- **Platform**: Android & iOS ready