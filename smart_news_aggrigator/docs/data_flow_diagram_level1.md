# Smart News Aggregator - Data Flow Diagram (DFD Level 1)

## Overview
This Data Flow Diagram shows the movement of data through the Smart News Aggregator system, illustrating how user inputs are processed and how data flows between different components.

## Data Flow Diagram (Level 1)

```
External Entities:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    USER     │    │   NewsAPI   │    │   Firebase  │
│             │    │   .org      │    │  Services   │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   │                   │
       ▼                   ▼                   ▼
╔══════════════════════════════════════════════════════════════════════════╗
║                         SMART NEWS AGGREGATOR SYSTEM                     ║
║                                                                          ║
║  ┌─────────────────────────────────────────────────────────────────────┐ ║
║  │                         PROCESSES                                   │ ║
║  │                                                                     │ ║
║  │  1.0 ┌────────────────┐   2.0 ┌────────────────┐                  │ ║
║  │      │  AUTHENTICATE  │       │  FETCH NEWS    │                  │ ║
║  │      │     USER       │       │   ARTICLES     │                  │ ║
║  │      └────────────────┘       └────────────────┘                  │ ║
║  │            │                            │                          │ ║
║  │            │                            │                          │ ║
║  │  3.0 ┌────────────────┐   4.0 ┌────────────────┐                  │ ║
║  │      │   MANAGE       │       │  SAVE ARTICLE  │                  │ ║
║  │      │  ARTICLES      │       │   OFFLINE      │                  │ ║
║  │      └────────────────┘       └────────────────┘                  │ ║
║  │            │                            │                          │ ║
║  │            │                            │                          │ ║
║  │  5.0 ┌────────────────┐   6.0 ┌────────────────┐                  │ ║
║  │      │  RATE/PREFER   │       │   SEARCH &     │                  │ ║
║  │      │   ARTICLES     │       │   FILTER       │                  │ ║
║  │      └────────────────┘       └────────────────┘                  │ ║
║  └─────────────────────────────────────────────────────────────────────┘ ║
║                                                                          ║
║  ┌─────────────────────────────────────────────────────────────────────┐ ║
║  │                       DATA STORES                                   │ ║
║  │                                                                     │ ║
║  │  D1 ┌────────────────┐   D2 ┌────────────────┐                    │ ║
║  │     │   USERS        │      │ SAVED_ARTICLES │                    │ ║
║  │     │ (Firebase Auth)│      │   (SQLite)     │                    │ ║
║  │     └────────────────┘      └────────────────┘                    │ ║
║  │                                      │                             │ ║
║  │  D3 ┌────────────────┐   D4 ┌────────────────┐                    │ ║
║  │     │ USER_PREFS &   │      │  CATEGORIES    │                    │ ║
║  │     │   RATINGS      │      │ (Local Prefs)  │                    │ ║
║  │     │ (Firestore)    │      └────────────────┘                    │ ║
║  │     └────────────────┘                                             │ ║
║  └─────────────────────────────────────────────────────────────────────┘ ║
╚══════════════════════════════════════════════════════════════════════════╝
```

## Detailed Data Flow Description

### Process 1.0: AUTHENTICATE USER
**Input Data Flows:**
- User credentials (email, password) from USER
- Authentication requests from Flutter app

**Process Description:**
- Validates user credentials against Firebase Authentication
- Creates new user accounts for registration
- Manages user sessions and tokens

**Output Data Flows:**
- User authentication status to app interface
- User data to D1 (Users data store)
- Session tokens for authenticated access

**Data Store Interactions:**
- Reads from D1 (Users) for login verification
- Writes to D1 (Users) for new registrations

### Process 2.0: FETCH NEWS ARTICLES
**Input Data Flows:**
- News requests with parameters (category, country, search query) from USER
- API responses from NewsAPI.org

**Process Description:**
- Constructs API requests to NewsAPI.org
- Processes and filters article responses
- Formats articles for display in the app

**Output Data Flows:**
- Formatted article lists to app interface
- Article metadata for display and interaction

### Process 3.0: MANAGE ARTICLES
**Input Data Flows:**
- Article management commands from USER (view, remove, refresh)
- Saved articles data from D2 (SQLite database)

**Process Description:**
- Retrieves saved articles from local storage
- Manages article collections and organization
- Handles article removal and updates

**Output Data Flows:**
- Formatted saved article lists to app interface
- Article status updates to user interface

**Data Store Interactions:**
- Reads from D2 (Saved_Articles) to display saved items
- Writes to D2 (Saved_Articles) for updates and deletions

### Process 4.0: SAVE ARTICLE OFFLINE
**Input Data Flows:**
- Save article requests from USER
- Article data from Process 2.0 (news fetching)

**Process Description:**
- Processes article save requests
- Handles duplicate detection (URL-based)
- Manages local storage operations

**Output Data Flows:**
- Save confirmation status to user interface
- Updated article metadata to saved articles list

**Data Store Interactions:**
- Writes complete article data to D2 (Saved_Articles)
- Checks existing articles for duplicate prevention

### Process 5.0: RATE/PREFER ARTICLES
**Input Data Flows:**
- User ratings and preference settings from USER
- Current preference data from D3 (Firestore)

**Process Description:**
- Processes user article ratings
- Updates user reading preferences
- Syncs preference data to cloud storage

**Output Data Flows:**
- Updated preference confirmations to user interface
- Personalized content recommendations

**Data Store Interactions:**
- Reads from D3 (User_Prefs & Ratings) for current settings
- Writes to D3 (User_Prefs & Ratings) for updates

### Process 6.0: SEARCH & FILTER
**Input Data Flows:**
- Search queries and filter criteria from USER
- Category selections from D4 (Categories)
- Article data from various sources

**Process Description:**
- Processes search requests and filters
- Applies category-based filtering
- Combines results from multiple data sources

**Output Data Flows:**
- Filtered article results to app interface
- Search suggestions and category updates

**Data Store Interactions:**
- Reads from D4 (Categories) for filter options
- May read from D2 (Saved_Articles) for local searches

## Data Stores Detail

### D1: USERS (Firebase Authentication)
**Data Elements:**
- User ID (Firebase UID)
- Email address
- Password hash (managed by Firebase)
- Creation timestamp
- Last sign-in timestamp
- Account verification status

**Access Patterns:**
- Read: Login verification, profile display
- Write: User registration, profile updates

### D2: SAVED_ARTICLES (SQLite Database)
**Data Elements:**
- id (Primary Key)
- title, author, description
- url (Unique identifier)
- urlToImage, publishedAt
- content, source
- savedAt (timestamp)

**Access Patterns:**
- Read: Display saved articles, search saved items
- Write: Save new articles, remove articles
- Update: Modify article metadata

### D3: USER_PREFS & RATINGS (Cloud Firestore)
**Data Elements:**
- User ID reference
- Article ratings (1-5 stars)
- Reading preferences (categories, sources)
- Notification settings
- Custom categories and filters

**Access Patterns:**
- Read: Load user preferences, display ratings
- Write: Save ratings, update preferences
- Sync: Cross-device preference synchronization

### D4: CATEGORIES (Local SharedPreferences)
**Data Elements:**
- Category ID and name
- Category icons and colors
- Custom user-created categories
- Category preferences and ordering

**Access Patterns:**
- Read: Display category filters, load preferences
- Write: Save custom categories, update ordering

## External Entity Interactions

### USER
**Inputs to System:**
- Login credentials (email/password)
- News search queries and filters
- Article save/remove requests
- Article ratings and preferences
- Category management commands

**Outputs from System:**
- Authentication status and user profile
- News articles and search results
- Saved articles management interface
- Preference confirmations and updates

### NewsAPI.org
**Inputs from System:**
- API requests with parameters:
  - Category selection (business, sports, etc.)
  - Country codes (us, uk, etc.)
  - Search queries and keywords
  - Date ranges and sorting preferences

**Outputs to System:**
- JSON article responses containing:
  - Article metadata (title, author, source)
  - Article content and descriptions
  - Publication timestamps
  - Image URLs and media content

### Firebase Services
**Inputs from System:**
- Authentication requests (login/register)
- User preference data for storage
- Article rating information
- Profile update requests

**Outputs to System:**
- Authentication tokens and user data
- Stored preference and rating data
- Cross-device synchronization updates
- Service status and error messages
