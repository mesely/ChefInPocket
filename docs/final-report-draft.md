# ChefInPocket Final Report Draft

## 1. Project Title and Team Information

**Project Title:** ChefInPocket  
**Course:** CS310 - Mobile Application Development  
**Term:** Spring 2025-2026  

**Team Members**

- Mehmet Selman Yılmaz
- Cem Ozkul
- Emir Keskin
- Semse Doga Atilgan
- Nilsu Saraclar
- Bora Demirkol

## 2. Application Overview and Objectives

ChefInPocket is a Flutter-based mobile application designed to help users decide what to cook based on the ingredients already available in their kitchen. Instead of forcing users to browse long recipe catalogs manually, the application focuses on ingredient-driven discovery, guided cooking, and retrieval-assisted AI support. The main objective of the project was to transform an initially wireframed concept into a functional, data-driven mobile application that integrates authentication, cloud data storage, protected navigation, and reactive UI updates.

From a usability perspective, the project aimed to reduce friction between "I have these ingredients" and "I know what to cook." From a technical perspective, our goal was to implement a structured Flutter architecture based on named routes, provider-based state management, Firebase-backed persistence, and reusable UI components that can be extended in future milestones.

## 3. Implemented Features

The final application includes the following implemented features:

- User registration, login, logout, and authentication-aware navigation
- Protected application routes for authenticated users
- Home dashboard with recipe discovery and search
- Ingredient-based recipe filtering
- Recipe detail view with serving scaling, customization, and guided cooking
- Save and unsave recipe functionality
- Grocery list creation, update, and deletion with real-time UI refresh
- Community feed for recipe sharing and creator browsing
- User profile and public creator profile pages
- Add recipe, edit recipe, and delete recipe flows
- Provider-based shared state and SharedPreferences-based theme persistence
- Realtime Firestore updates for dynamic user content
- Context-aware Chef AI conversation interface

## 4. Firebase Usage

### 4.1 Firebase Authentication

Firebase Authentication was used to manage account creation and secure login flows. The application supports:

- Email and password sign-up
- Email and password login
- Logout
- Authentication-aware route protection

Users who are not authenticated are directed to the onboarding or login flow, while authenticated users can access the main application screens. Authentication errors such as invalid credentials or network failures are converted into user-friendly messages through the service and provider layers.

### 4.2 Cloud Firestore

Cloud Firestore is the primary database layer of the application. It stores and synchronizes the following core collections:

- `users`
- `recipes`
- `community_posts`
- `saved_recipes`
- `grocery_items`
- `assistant_messages`

Each document is structured with a unique identifier and includes ownership and timestamp metadata such as `id`, `createdBy`, and `createdAt`. Firestore streams are used for real-time updates in features such as saved recipes, grocery list items, community posts, and user-generated recipe content. This allowed the UI to react immediately to data changes without manual refresh logic.

### 4.3 Firebase Storage

In the intended deployment architecture, Firebase Storage is the dedicated media layer for recipe images uploaded by users. In the current repository, the application still uses a hybrid demo strategy based on bundled asset images and seeded network image URLs so that the UI remains demo-ready even without full media upload deployment. However, the overall architecture was planned with Storage as the long-term source of truth for recipe media, and this is the next logical infrastructure extension.

## 5. State Management Approach

We used **Provider with ChangeNotifier** as the primary state management solution. This choice was made because Provider is lightweight, easy to understand, and highly suitable for a course project where readability and maintainability are important.

The application currently separates responsibilities across multiple providers:

- `AuthProvider` for authentication state
- `AppDataProvider` for shared app content and recipe data
- `PreferencesProvider` for theme persistence through SharedPreferences

This design allowed us to avoid deeply passing shared state through widget constructors. Instead, screens react to application-wide changes through `context.watch`, `context.read`, and Firestore-driven streams. The result is a more maintainable structure and a cleaner separation between UI, state, and data access logic.

## 6. Architecture and Data Flow

The application follows a layered structure:

- **UI Layer:** Screens and reusable widgets
- **State Layer:** Provider-based state management
- **Service Layer:** Firebase and Firestore access encapsulated inside `ApiService`
- **Persistence Layer:** Firestore, Authentication, and SharedPreferences

This architecture improves clarity and testability. UI components focus on presentation and interaction, while the service layer concentrates on business logic and cloud access. The same separation also made it easier to add automated tests in the final stage.

## 7. Challenges and Solutions

### Challenge 1: Integrating Authentication with Protected Navigation

One of the main challenges was making sure that navigation changed automatically depending on login status. A direct route-based implementation without shared state quickly became difficult to manage, especially when users logged in, logged out, or re-opened the application.

**Solution:**  
We introduced `AuthProvider` and an application entry screen that listens to Firebase authentication state changes. Protected routes are wrapped with an authentication guard, so the correct screen tree is shown automatically.

### Challenge 2: Designing Real-Time Firestore Updates Without UI Duplication

Several screens depend on live data, such as saved recipes, grocery items, and community posts. Managing each screen with separate manual reload logic would have created repetitive code and inconsistent behavior.

**Solution:**  
We used Firestore streams for dynamic collections and connected them to `StreamBuilder` and provider-managed app state. This allowed the UI to update in real time and kept the reload logic centralized and predictable.

### Challenge 3: Keeping the AI Assistant Flow Compatible with a Future RAG Pipeline

The project concept included an AI cooking assistant, but directly coupling the Flutter UI to a specific backend implementation would have reduced flexibility.

**Solution:**  
We designed the client-side assistant flow around recipe context, document retrieval, and message persistence rather than a hardcoded model dependency. The current version retrieves relevant recipe documents from the app data layer before composing a response, and the same UI contract can later be connected to a larger external LLM-based backend without major refactoring of the mobile application.

## 8. Lessons Learned

This project taught us that clean architecture is especially important in mobile development once the project grows beyond a few screens. Early decisions about routing, state management, and reusable widgets strongly affected how easy it was to add Firebase features later.

We also learned the importance of separating demo content from production-oriented infrastructure. For example, using seeded images and fallback data improved demo reliability, while keeping the Firebase-based architecture ready for future expansion.

From a teamwork perspective, we learned that clearly dividing responsibilities by feature ownership reduces overlap and makes integration significantly smoother. Regular sync meetings and shared architectural decisions were especially useful once backend integration and testing started.

## 9. Breakdown of Individual Contributions

The project work was divided as follows:

- **Mehmet Selman Yılmaz:** AI interaction flow, cooking steps flow, testing strategy, final Firebase-oriented architecture cleanup, and final documentation integration
- **Cem Ozkul:** Data modeling support, backend structure review, Firestore rule planning, and quality assurance support
- **Emir Keskin:** Integration planning, repository coordination, authentication flow support, and service-layer alignment
- **Semse Doga Atilgan:** UI implementation support, layout consistency checks, presentation polishing, and communication materials
- **Nilsu Saraclar:** UI/UX direction, visual consistency, shared design language, and documentation support
- **Bora Demirkol:** Full-stack coordination, project organization, navigation validation, and cross-feature integration support

## 10. Testing and Finalization

As part of the final step, we added automated test coverage for both business logic and widget behavior:

- A **unit test** validates ingredient-based recipe filtering logic
- A **widget test** validates login screen rendering, validation, and submit behavior

These tests improve confidence in both the core application logic and the user-facing authentication flow.

## 11. Conclusion

ChefInPocket successfully evolved from a UI-focused cooking application prototype into a functional Flutter application backed by Firebase Authentication and Cloud Firestore. The project now includes protected navigation, reactive data flows, reusable architecture, lightweight retrieval-assisted AI behavior, and automated test coverage. While future work remains for media upload and full production-grade external LLM integration, the current version already demonstrates the core technical and user-experience goals of the project in a cohesive and extensible way.
