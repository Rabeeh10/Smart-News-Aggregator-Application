# Smart News Aggregator - System Architecture Diagram

## Overview
This document presents the system architecture for the Smart News Aggregator Flutter application, showing how users interact with the app and its various components.

## System Architecture Diagram (Block Diagram)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              USER                                       │
└─────────────────────┬───────────────────────────────────────────────────┘
                     │ Interacts with
                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        FLUTTER APP                                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐        │
│  │  Login/Register │  │   Home Screen   │  │ Saved Articles  │        │
│  │     Screen      │  │                 │  │     Screen      │        │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘        │
│                                                                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐        │
│  │  News Widget    │  │  Categories     │  │   Profile       │        │
│  │                 │  │    Widget       │  │   Management    │        │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘        │
└─────────────────────────────────────────────────────────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
         ▼           ▼           ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  FIREBASE   │ │ CLOUD       │ │  NEWSAPI    │
│AUTHENTICATION│ │ FIRESTORE   │ │   .ORG      │
│             │ │             │ │             │
│• User Login │ │• User       │ │• Top        │
│• User       │ │  Ratings    │ │  Headlines  │
│  Register   │ │• User       │ │• Search     │
│• Password   │ │  Preferences│ │  Articles   │
│  Reset      │ │• Profile    │ │• Categories │
│             │ │  Data       │ │• Sources    │
└─────────────┘ └─────────────┘ └─────────────┘
         │
         │
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    ON-DEVICE SQLITE DATABASE                            │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                      saved_articles                              │   │
│  │  • id (PRIMARY KEY)        • url (UNIQUE)                       │   │
│  │  • title                   • urlToImage                         │   │
│  │  • author                  • publishedAt                        │   │
│  │  • description             • content                            │   │
│  │  • source                  • savedAt                            │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  Features:                                                              │
│  • Offline article storage                                             │
│  • Duplicate prevention (URL-based)                                    │
│  • Article metadata preservation                                       │
│  • Local search and filtering                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Component Descriptions

### Flutter App Layer
- **Login/Register Screen**: Handles user authentication via Firebase Auth
- **Home Screen**: Main interface for news consumption and navigation
- **News Widget**: Displays articles fetched from NewsAPI
- **Categories Widget**: Manages news categories and filtering
- **Saved Articles Screen**: Shows locally saved articles from SQLite
- **Profile Management**: User settings and preferences

### External Services

#### Firebase Authentication
- **Purpose**: User identity management
- **Functions**:
  - User registration with email/password
  - User login verification
  - Password reset functionality
  - Session management

#### Cloud Firestore
- **Purpose**: Cloud-based data storage for user preferences
- **Functions**:
  - Store user ratings for articles
  - Save user reading preferences
  - Sync user profile data across devices
  - Store custom categories and settings

#### NewsAPI.org
- **Purpose**: External news data provider
- **Functions**:
  - Fetch top headlines by country/category
  - Search for specific articles
  - Get articles from specific sources
  - Filter by date ranges and languages

### Local Storage (SQLite)
- **Purpose**: Offline article storage and management
- **Database Schema**:
  - **saved_articles** table with complete article metadata
  - URL-based uniqueness constraint
  - Timestamp tracking for save operations

## Data Flow Patterns

1. **Authentication Flow**: User → Flutter App → Firebase Auth
2. **News Fetching**: Flutter App → NewsAPI → Display Articles
3. **Article Saving**: User Action → SQLite Database → Confirmation
4. **Preferences Sync**: User Settings → Cloud Firestore → Cross-Device Sync
5. **Offline Access**: Local SQLite → Article Retrieval → Display

## Security Considerations
- Firebase Authentication handles secure user sessions
- API keys are securely managed within the app
- Local SQLite data is device-specific and secure
- Cloud Firestore follows Firebase security rules

## Scalability Features
- Cloud Firestore enables horizontal scaling
- SQLite provides efficient local caching
- NewsAPI handles high-volume requests
- Modular Flutter architecture supports feature expansion
