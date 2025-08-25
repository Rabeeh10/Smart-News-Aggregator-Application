# Smart News Aggregator - Data Flow Diagram (DFD Level 0 - Context Diagram)

## Overview
This Context Diagram (Level 0 DFD) shows the Smart News Aggregator system as a single process, illustrating the system's interactions with external entities.

## Context Diagram (Level 0)

```
                            ┌─────────────────────────────────┐
                            │             USER                │
                            │                                 │
                            │ • News Reader                   │
                            │ • Account Holder                │
                            │ • Content Consumer              │
                            └─────────────────────────────────┘
                                         │
                User Credentials         │         Authenticated Sessions
                News Requests           │         News Articles
                Save/Remove Commands    │         Saved Articles List
                Ratings & Preferences   │         Personalized Content
                Search Queries          │         Search Results
                                        │
                                        ▼
        ┌─────────────────────────────────────────────────────────────────────┐
        │                                                                     │
        │                    SMART NEWS AGGREGATOR                            │
        │                         SYSTEM                                      │
        │                                                                     │
        │  • Manages user authentication and sessions                         │
        │  • Fetches and displays news articles from external sources         │
        │  • Provides offline article storage and management                  │
        │  • Handles user preferences and article ratings                     │
        │  • Enables search and filtering of news content                     │
        │                                                                     │
        └─────────────────────────────────────────────────────────────────────┘
                            │                          │
                            │                          │
         API Requests       │                          │    Authentication Requests
         (Headlines,        │                          │    User Data Storage
         Search, Sources)   │                          │    Preference Sync
                           │                          │    Rating Storage
                           ▼                          ▼
    ┌─────────────────────────┐              ┌─────────────────────────┐
    │      NewsAPI.org        │              │    Firebase Services    │
    │                         │              │                         │
    │ • News Data Provider    │              │ • Authentication        │
    │ • Article Database      │              │ • Cloud Firestore       │
    │ • Real-time Updates     │              │ • User Management       │
    │ • Multiple Sources      │              │ • Cross-device Sync     │
    └─────────────────────────┘              └─────────────────────────┘
                           │                          │
         Article Data      │                          │    Auth Tokens
         (JSON Response)   │                          │    User Profile Data
         Source Information│                          │    Stored Preferences
         Media Content     │                          │    Synced Ratings
```

## External Entity Details

### USER
**Role**: Primary system user who consumes news content
**Interactions with System:**
- **Input Data Flows:**
  - User credentials for authentication
  - News search requests and category selections
  - Article save/remove commands
  - Article ratings and reading preferences
  - Profile update requests

- **Output Data Flows:**
  - Authentication status and user sessions
  - Curated news articles and headlines
  - Saved articles collection
  - Personalized content recommendations
  - Search results and filtered content

### NewsAPI.org
**Role**: External news data provider and content aggregator
**Interactions with System:**
- **Input Data Flows (from System):**
  - API requests for top headlines
  - Search queries with parameters
  - Category and country filters
  - Source-specific requests
  - Date range and sorting preferences

- **Output Data Flows (to System):**
  - JSON formatted article data
  - Article metadata (title, author, description)
  - Publication timestamps and sources
  - Image URLs and media content
  - API response status and error messages

### Firebase Services
**Role**: Cloud-based backend services for authentication and data storage
**Interactions with System:**
- **Input Data Flows (from System):**
  - User authentication requests (login/register)
  - User preference data for cloud storage
  - Article rating information
  - Profile update and sync requests
  - Cross-device synchronization data

- **Output Data Flows (to System):**
  - Authentication tokens and user verification
  - User profile and account information
  - Stored preferences and rating data
  - Cross-device synchronized settings
  - Service status and error responses

## System Boundary
The Smart News Aggregator system boundary encompasses:
- **Included**: All Flutter app components, local SQLite database, business logic, and user interface
- **Excluded**: External news sources, Firebase cloud infrastructure, and third-party authentication services

## Key Data Flows Summary

| Flow Direction | Data Type | Description |
|---|---|---|
| User → System | Authentication | Login credentials and session requests |
| User → System | Content Requests | News searches, category filters, save commands |
| User → System | Preferences | Article ratings, reading preferences, profile data |
| System → User | Content Delivery | News articles, saved articles, search results |
| System → User | Feedback | Authentication status, operation confirmations |
| System ↔ NewsAPI | News Data | API requests and article responses |
| System ↔ Firebase | User Data | Authentication, preferences, and ratings sync |

## System Objectives
1. **Content Aggregation**: Collect and present news from multiple sources
2. **User Management**: Secure authentication and profile management
3. **Offline Functionality**: Local storage for offline article access
4. **Personalization**: User-specific preferences and content curation
5. **Search & Discovery**: Flexible content search and filtering capabilities
