# ChefInPocket Demo Video Script

## 5-Minute Demonstration Outline

### 0:00 - 0:30 | Introduction

- Introduce the project name: **ChefInPocket**
- State the course and team context briefly
- Explain the core idea in one sentence:
  "ChefInPocket helps users decide what to cook based on the ingredients they already have, while also providing guided cooking and an AI assistant."

### 0:30 - 1:15 | Authentication Flow

- Open the onboarding screen
- Show the Register and Login entry points
- Demonstrate user registration or login
- Explain that Firebase Authentication is used for secure account management
- Mention that protected routes prevent unauthenticated access to main app screens

### 1:15 - 2:10 | Core Ingredient-to-Recipe Flow

- Open the Home screen
- Show the search area and cuisine shortcuts
- Navigate to the ingredient picker
- Select a few ingredients such as eggs, tomatoes, and feta
- Continue to the recipe results screen
- Open one matching recipe
- Explain that recipe discovery is driven by ingredient filtering logic and Firestore-backed data

### 2:10 - 2:55 | Recipe Tools and Guided Cooking

- On the recipe detail screen, show:
  - Save recipe
  - Adjust servings
  - Customize ingredients
  - Start Cooking
- Open the cooking steps screen briefly
- Explain that the recipe flow is designed to keep users inside one consistent cooking journey

### 2:55 - 3:35 | AI Assistant

- Open the Chef AI screen from the recipe detail page
- Type a simple cooking question such as:
  "What can I substitute for feta?"
- Show the assistant response
- Explain that the assistant is context-aware because it knows which recipe the user is viewing
- Mention that the assistant first retrieves matching recipe data before composing the reply

### 3:35 - 4:20 | Real-Time Firestore Data

- Open the Community screen
- Show recipe posts and creator navigation
- Save or unsave a recipe and mention that the saved list updates through Firestore
- Open the Grocery List
- Add an item, mark it complete, or remove it
- Explain that the Firestore stream updates the UI in real time without manual refresh

### 4:20 - 4:45 | Profile and Local Persistence

- Open the Profile screen
- Show saved counts, published recipes, and user information
- Toggle the theme mode
- Explain that SharedPreferences is used for local persistence of the user’s interface preference

### 4:45 - 5:00 | Conclusion

- Summarize the technical stack:
  - Flutter
  - Firebase Authentication
  - Cloud Firestore
  - Provider
  - SharedPreferences
- Close with a short conclusion:
  "ChefInPocket is now a functional, reactive mobile application that connects ingredient-based cooking support with authentication, cloud persistence, and a scalable architecture."
