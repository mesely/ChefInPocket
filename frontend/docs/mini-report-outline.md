# ChefInPocket Mini Report Outline

Use this outline when preparing the Step 3 PDF submission.

## 1. Implemented Screens and Purpose

- Onboarding: introduces the app and routes users to Register or Login.
- Register: collects new user information with validation and success dialog.
- Login: signs users in with validation and a placeholder Apple option.
- Home: main dashboard with search, cuisine shortcuts, and quick-access cards.
- Browse Cuisine: lets users explore cuisine categories and curated meal groups.
- Ingredient Picker: multi-select kitchen ingredients to find matching recipes.
- Recipe Results: shows matching recipes and summary metrics.
- Recipe Detail: displays one recipe and routes users to recipe tools.
- Serving Scale: updates ingredient amounts based on the selected serving count.
- AI Chat: context-aware cooking helper with a simple conversation flow.
- Grocery List: card-based missing ingredient list with dynamic remove actions.
- Add Recipe: user-generated recipe form with validation and success dialog.
- Customize Ingredients: swap or remove ingredients while preserving the recipe flow.
- Cooking Steps: step-by-step guided cooking mode.
- Community: social feed for recipe sharing and creator discovery.
- Profile: personal account summary and menu shortcuts.

## 2. Navigation Flow

- Initial route: `OnboardingScreen`
- Auth flow: Onboarding -> Register/Login -> Home
- Discovery flow: Home -> Browse Cuisine -> Ingredient Picker -> Recipe Results -> Recipe Detail
- Recipe tool flow: Recipe Detail -> Serving Scale / Customize Ingredients / Cooking Steps / AI Chat
- Utility flow: Home -> Grocery List / Add Recipe / Community / Profile
- Main navigation pattern: named routes + bottom navigation bar on core destination screens

## 3. Matching the Wireframes

- The app keeps the warm neutral background, rounded cards, soft blue accent, and bold heading style from the wireframes.
- Typography uses `Syne` for display titles and `Inter` for body text.
- Main cards, pills, spacing, and layout rhythm follow the original wireframe proportions.
- Responsive padding and grid counts adjust on larger screens while preserving the mobile-first design.

## 4. Technical Features

### Named Routes

- All screens are registered inside `frontend/lib/app.dart`
- Route names are centralized in `frontend/lib/routes/app_routes.dart`
- The initial route is defined as `/`

### Utility Classes

- `frontend/lib/utils/app_colors.dart`
- `frontend/lib/utils/app_spacing.dart`
- `frontend/lib/utils/app_text_styles.dart`

### Images

- Asset images are stored under `frontend/assets/images/`
- Network images are used in Recipe Detail and Community cards

### Custom Font

- `Inter.ttf` and `Syne.ttf` are registered in `frontend/pubspec.yaml`
- The global theme applies the font system through `AppTheme`

### Card List with Remove Functionality

- Grocery List uses the `GroceryItem` model
- Each list item is rendered inside a `Card`
- Users can remove items with a trailing delete button

### Form Validation

- Register screen validates full name, email, password, and confirm password
- Add Recipe validates title, ingredients, prep time, and servings
- Successful submissions show an `AlertDialog`

### Responsiveness

- Shared `ChefPage` constrains content width on larger displays
- Grid layouts adapt between 2, 3, and 4 columns depending on available width
- Screens remain scrollable and readable in portrait and wider layouts

## 5. Backend Summary

- API Gateway routes `/api/auth`, `/api/recipes`, `/api/pantry`, `/api/community`, and `/api/assistant`
- Each microservice connects to MongoDB with its own `DB_NAME`
- Services include seed data for demo-ready endpoints
- Docker Compose runs the backend services as separate containers

## 6. Contribution Section Template

Replace the names below with your final contribution mapping.

- Member 1: Onboarding, Register, Login
- Member 2: Home, Browse Cuisine, Ingredient Picker
- Member 3: Recipe Results, Recipe Detail, Serving Scale, Customize Ingredients
- Member 4: AI Chat, Grocery List, Add Recipe, Cooking Steps, Community, Profile
