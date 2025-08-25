# Smart News Aggregator - Data Flow Diagram (DFD Level 2)

## Overview
This Level 2 DFD provides detailed decomposition of the major processes from Level 1, showing the internal sub-processes and their interactions.

## Level 2 DFD: Process 1.0 - AUTHENTICATE USER

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        PROCESS 1.0: AUTHENTICATE USER                           │
│                                                                                 │
│  ┌─────────────┐  user_credentials  ┌─────────────────┐                        │
│  │    USER     │ ────────────────→  │      1.1        │                        │
│  │             │                    │   VALIDATE      │                        │
│  │             │  ←──────────────── │   CREDENTIALS   │                        │
│  └─────────────┘  validation_result └─────────────────┘                        │
│                                              │                                  │
│                                              │ validated_data                   │
│                                              ▼                                  │
│                                     ┌─────────────────┐                        │
│                                     │      1.2        │                        │
│                                     │  CREATE/UPDATE  │                        │
│                                     │  USER SESSION   │                        │
│                                     └─────────────────┘                        │
│                                              │                                  │
│                                              │ session_data                     │
│                                              ▼                                  │
│                 ┌─────────────┐     ┌─────────────────┐                        │
│                 │     D1      │ ←── │      1.3        │                        │
│                 │   USERS     │     │   MANAGE USER   │                        │
│                 │ (Firebase)  │ ──→ │     ACCOUNT     │                        │
│                 └─────────────┘     └─────────────────┘                        │
│                                              │                                  │
│                                              │ account_status                   │
│                                              ▼                                  │
│                                     ┌─────────────────┐                        │
│                                     │      1.4        │                        │
│                                     │   HANDLE AUTH   │                        │
│                                     │     ERRORS      │                        │
│                                     └─────────────────┘                        │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Process 1.1: VALIDATE CREDENTIALS
**Input**: User credentials (email, password)
**Process**: 
- Validates email format and password strength
- Checks against Firebase Auth rules
- Handles input sanitization
**Output**: Validation result (success/failure with errors)

### Process 1.2: CREATE/UPDATE USER SESSION
**Input**: Validated user data
**Process**:
- Creates new user session for login
- Updates existing session data
- Generates authentication tokens
**Output**: Session data and tokens

### Process 1.3: MANAGE USER ACCOUNT
**Input**: Session data from 1.2
**Process**:
- Creates new user accounts (registration)
- Updates existing user profiles
- Manages account metadata
**Output**: Account status and user data
**Data Store**: Reads from/Writes to D1 (Users)

### Process 1.4: HANDLE AUTH ERRORS
**Input**: Account status from 1.3
**Process**:
- Processes authentication failures
- Formats error messages for user display
- Logs security events
**Output**: Error messages to user interface

## Level 2 DFD: Process 2.0 - FETCH NEWS ARTICLES

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                       PROCESS 2.0: FETCH NEWS ARTICLES                          │
│                                                                                 │
│  ┌─────────────┐  news_request     ┌─────────────────┐                         │
│  │    USER     │ ────────────────→ │      2.1        │                         │
│  │             │                   │  PARSE REQUEST  │                         │
│  │             │                   │   PARAMETERS    │                         │
│  └─────────────┘                   └─────────────────┘                         │
│                                             │                                   │
│                                             │ parsed_params                     │
│                                             ▼                                   │
│                ┌─────────────┐     ┌─────────────────┐                         │
│                │   NewsAPI   │ ←── │      2.2        │                         │
│                │    .org     │     │  CONSTRUCT API  │                         │
│                │             │ ──→ │    REQUEST      │                         │
│                └─────────────┘     └─────────────────┘                         │
│                                             │                                   │
│                                             │ api_response                      │
│                                             ▼                                   │
│                                    ┌─────────────────┐                         │
│                                    │      2.3        │                         │
│                                    │ PROCESS & FILTER│                         │
│                                    │   ARTICLE DATA  │                         │
│                                    └─────────────────┘                         │
│                                             │                                   │
│                                             │ filtered_articles                 │
│                                             ▼                                   │
│                                    ┌─────────────────┐                         │
│                                    │      2.4        │                         │
│                                    │  FORMAT FOR     │                         │
│                                    │    DISPLAY      │                         │
│                                    └─────────────────┘                         │
│                                             │                                   │
│                                             │ formatted_articles                │
│                                             ▼                                   │
│  ┌─────────────┐  article_display  ┌─────────────────┐                         │
│  │    USER     │ ←──────────────── │      2.5        │                         │
│  │ INTERFACE   │                   │   HANDLE API    │                         │
│  │             │ ←──────────────── │     ERRORS      │                         │
│  └─────────────┘  error_messages   └─────────────────┘                         │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Process 2.1: PARSE REQUEST PARAMETERS
**Input**: News request from user (category, search terms, filters)
**Process**:
- Extracts search parameters and filters
- Validates request format
- Sets default values for missing parameters
**Output**: Parsed parameters for API construction

### Process 2.2: CONSTRUCT API REQUEST
**Input**: Parsed parameters from 2.1
**Process**:
- Builds NewsAPI request URL with parameters
- Adds API authentication headers
- Handles rate limiting and request queuing
**Output**: API requests to NewsAPI.org
**External Entity**: Communicates with NewsAPI.org

### Process 2.3: PROCESS & FILTER ARTICLE DATA
**Input**: API response from NewsAPI.org
**Process**:
- Parses JSON response data
- Filters out removed or invalid articles
- Applies content filtering rules
**Output**: Filtered article data

### Process 2.4: FORMAT FOR DISPLAY
**Input**: Filtered articles from 2.3
**Process**:
- Converts data to Article model objects
- Formats timestamps and metadata
- Optimizes images and content for display
**Output**: Formatted articles ready for UI

### Process 2.5: HANDLE API ERRORS
**Input**: Error responses from API requests
**Process**:
- Processes different types of API errors
- Formats user-friendly error messages
- Implements retry logic for temporary failures
**Output**: Error messages to user interface

## Level 2 DFD: Process 4.0 - SAVE ARTICLE OFFLINE

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                      PROCESS 4.0: SAVE ARTICLE OFFLINE                          │
│                                                                                 │
│  ┌─────────────┐  save_request     ┌─────────────────┐                         │
│  │    USER     │ ────────────────→ │      4.1        │                         │
│  │             │                   │   VALIDATE      │                         │
│  │             │                   │    ARTICLE      │                         │
│  └─────────────┘                   └─────────────────┘                         │
│                                             │                                   │
│                                             │ validated_article                 │
│                                             ▼                                   │
│                ┌─────────────┐     ┌─────────────────┐                         │
│                │     D2      │ ←── │      4.2        │                         │
│                │ SAVED_      │     │ CHECK FOR       │                         │
│                │ ARTICLES    │ ──→ │  DUPLICATES     │                         │
│                └─────────────┘     └─────────────────┘                         │
│                                             │                                   │
│                                             │ duplicate_status                  │
│                                             ▼                                   │
│                                    ┌─────────────────┐                         │
│                                    │      4.3        │                         │
│                                    │   PREPARE       │                         │
│                                    │  ARTICLE DATA   │                         │
│                                    └─────────────────┘                         │
│                                             │                                   │
│                                             │ prepared_data                     │
│                                             ▼                                   │
│                ┌─────────────┐     ┌─────────────────┐                         │
│                │     D2      │ ←── │      4.4        │                         │
│                │ SAVED_      │     │  EXECUTE        │                         │
│                │ ARTICLES    │     │  DATABASE       │                         │
│                └─────────────┘     │  OPERATION      │                         │
│                                    └─────────────────┘                         │
│                                             │                                   │
│                                             │ operation_result                  │
│                                             ▼                                   │
│  ┌─────────────┐  save_confirmation ┌─────────────────┐                        │
│  │    USER     │ ←──────────────────│      4.5        │                        │
│  │ INTERFACE   │                    │   PROVIDE       │                        │
│  │             │ ←──────────────────│   FEEDBACK      │                        │
│  └─────────────┘  error_notification└─────────────────┘                        │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Process 4.1: VALIDATE ARTICLE
**Input**: Save request with article data from user
**Process**:
- Validates article data completeness
- Checks required fields (title, URL)
- Sanitizes content for storage
**Output**: Validated article data

### Process 4.2: CHECK FOR DUPLICATES
**Input**: Validated article from 4.1
**Process**:
- Queries database for existing URL
- Compares article metadata
- Determines if update or new save is needed
**Output**: Duplicate status
**Data Store**: Reads from D2 (Saved_Articles)

### Process 4.3: PREPARE ARTICLE DATA
**Input**: Duplicate status from 4.2
**Process**:
- Formats article data for database storage
- Adds timestamp and metadata
- Prepares database operation parameters
**Output**: Prepared data for database

### Process 4.4: EXECUTE DATABASE OPERATION
**Input**: Prepared data from 4.3
**Process**:
- Executes INSERT or UPDATE SQL operations
- Handles database transactions
- Manages database connections
**Output**: Operation result (success/failure)
**Data Store**: Writes to D2 (Saved_Articles)

### Process 4.5: PROVIDE FEEDBACK
**Input**: Operation result from 4.4
**Process**:
- Formats success/error messages
- Triggers UI notifications
- Updates article state in interface
**Output**: Save confirmation or error notification to user

## Level 2 DFD: Process 5.0 - RATE/PREFER ARTICLES

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                     PROCESS 5.0: RATE/PREFER ARTICLES                           │
│                                                                                 │
│  ┌─────────────┐  rating_input     ┌─────────────────┐                         │
│  │    USER     │ ────────────────→ │      5.1        │                         │
│  │             │                   │   VALIDATE      │                         │
│  │             │                   │   RATING DATA   │                         │
│  └─────────────┘                   └─────────────────┘                         │
│                                             │                                   │
│                                             │ validated_rating                  │
│                                             ▼                                   │
│                ┌─────────────┐     ┌─────────────────┐                         │
│                │     D3      │ ←── │      5.2        │                         │
│                │ USER_PREFS  │     │ CHECK EXISTING  │                         │
│                │ & RATINGS   │ ──→ │   PREFERENCES   │                         │
│                └─────────────┘     └─────────────────┘                         │
│                                             │                                   │
│                                             │ existing_prefs                    │
│                                             ▼                                   │
│                                    ┌─────────────────┐                         │
│                                    │      5.3        │                         │
│                                    │   UPDATE        │                         │
│                                    │  PREFERENCE     │                         │
│                                    │     DATA        │                         │
│                                    └─────────────────┘                         │
│                                             │                                   │
│                                             │ updated_prefs                     │
│                                             ▼                                   │
│                ┌─────────────┐     ┌─────────────────┐                         │
│                │  Firebase   │ ←── │      5.4        │                         │
│                │ Firestore   │     │ SYNC TO CLOUD   │                         │
│                │             │ ──→ │   STORAGE       │                         │
│                └─────────────┘     └─────────────────┘                         │
│                                             │                                   │
│                                             │ sync_result                       │
│                                             ▼                                   │
│  ┌─────────────┐  preference_update ┌─────────────────┐                        │
│  │    USER     │ ←───────────────── │      5.5        │                        │
│  │ INTERFACE   │                    │   GENERATE      │                        │
│  │             │ ←───────────────── │ RECOMMENDATIONS │                        │
│  └─────────────┘  recommendations   └─────────────────┘                        │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Process 5.1: VALIDATE RATING DATA
**Input**: Rating input from user (star rating, preferences)
**Process**:
- Validates rating values (1-5 stars)
- Checks preference data format
- Ensures user authentication
**Output**: Validated rating data

### Process 5.2: CHECK EXISTING PREFERENCES
**Input**: Validated rating from 5.1
**Process**:
- Queries existing user preferences
- Retrieves current rating history
- Identifies preference conflicts
**Output**: Existing preferences data
**Data Store**: Reads from D3 (User_Prefs & Ratings)

### Process 5.3: UPDATE PREFERENCE DATA
**Input**: Existing preferences from 5.2
**Process**:
- Merges new ratings with existing data
- Updates preference algorithms
- Calculates preference trends
**Output**: Updated preferences data

### Process 5.4: SYNC TO CLOUD STORAGE
**Input**: Updated preferences from 5.3
**Process**:
- Formats data for Firestore storage
- Executes cloud database operations
- Handles synchronization conflicts
**Output**: Sync result
**Data Store**: Writes to D3 via Firebase Firestore

### Process 5.5: GENERATE RECOMMENDATIONS
**Input**: Sync result from 5.4
**Process**:
- Analyzes updated preference data
- Generates personalized content recommendations
- Formats recommendations for display
**Output**: Preference updates and recommendations to user interface

## Data Store Details for Level 2

### D1: USERS (Firebase Authentication)
- **Structure**: Firebase-managed user accounts
- **Operations**: Create, Read, Update user accounts
- **Access Patterns**: Authentication validation, profile management

### D2: SAVED_ARTICLES (SQLite Database)
- **Structure**: Local relational database table
- **Operations**: Create, Read, Update, Delete saved articles
- **Access Patterns**: Duplicate checking, article retrieval, storage management

### D3: USER_PREFS & RATINGS (Cloud Firestore)
- **Structure**: Document-based NoSQL storage
- **Operations**: Create, Read, Update preference documents
- **Access Patterns**: Preference synchronization, recommendation generation
