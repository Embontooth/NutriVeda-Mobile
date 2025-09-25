# NutriVeda Mobile

A Flutter application designed for dietitians to manage patients, create diet charts, and plan meals.

## Features

### 🔐 Authentication
- Login screen with email and password validation
- Secure user authentication (Firebase integration ready)

### 📊 Dashboard
- Overview of patient statistics
- Recent activities tracking
- Quick action buttons for common tasks
- Nutritional summaries and metrics

### 👥 Patient Management
- Add, edit, and delete patient records
- Search and filter functionality
- Patient history tracking
- Detailed patient profiles with conditions and visit history

### 📋 Diet Chart Builder
- Create customized diet charts for patients
- Goal-based diet planning (Weight Loss, Diabetes Management, etc.)
- Calorie and macronutrient tracking
- Diet chart templates and duplication
- Export functionality (coming soon)

### 🗓️ Food Planner
- Weekly meal planning
- Daily meal scheduling with nutritional breakdown
- Meal templates and recommendations
- Nutrition tracking (calories, proteins, carbs, fats)

## Design

### Color Theme
- **Primary Color**: `#FCD7AD` (Light Orange)
- **Secondary Color**: `#A5754D` (Chamoisee)
- **Background**: `#FFFDF8` (Warm White)

The app follows Material Design 3 principles with a warm, professional color scheme suitable for healthcare applications.

## Project Structure

```
lib/
├── main.dart              # App entry point
├── theme/
│   └── app_theme.dart     # Custom theme and colors
└── screens/
    ├── login_screen.dart           # Authentication screen
    ├── home_screen.dart            # Main navigation
    ├── dashboard_screen.dart       # Overview and statistics
    ├── patient_management_screen.dart  # Patient CRUD operations
    ├── diet_chart_builder_screen.dart  # Diet chart creation
    └── food_planner_screen.dart    # Meal planning interface
```

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Embontooth/NutriVeda-Mobile.git
cd NutriVeda-Mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Testing

Run tests with:
```bash
flutter test
```

## Future Enhancements

- [ ] Firebase Authentication integration
- [ ] Cloud Firestore database integration
- [ ] Advanced meal planning algorithms
- [ ] Nutritional analysis and recommendations
- [ ] Patient progress tracking
- [ ] Export functionality for diet charts
- [ ] Push notifications for appointments
- [ ] Multi-language support

## Contributing

This project is part of the SIH (Smart India Hackathon) Ayurveda initiative. Contributions are welcome!

## License

This project is licensed under the MIT License - see the LICENSE file for details.
