# Smart News Aggregator - Data Flow Diagram (DFD Level 3)

## Overview
This Level 3 DFD provides the most detailed decomposition of selected critical processes from Level 2, showing the fine-grained operations and data transformations.

## Level 3 DFD: Process 2.2 - CONSTRUCT API REQUEST

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    PROCESS 2.2: CONSTRUCT API REQUEST                           │
│                                                                                 │
│  ┌─────────────┐                   ┌─────────────────┐                         │
│  │   Process   │  parsed_params   │     2.2.1       │                         │
│  │     2.1     │ ────────────────→│  BUILD BASE     │                         │
│  │             │                  │     URL         │                         │
│  └─────────────┘                  └─────────────────┘                         │
│                                            │                                   │
│                                            │ base_url                          │
│                                            ▼                                   │
│                                   ┌─────────────────┐                         │
│                                   │     2.2.2       │                         │
│                                   │  ADD QUERY      │                         │
│                                   │  PARAMETERS     │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ url_with_params                   │
│                                            ▼                                   │
│                                   ┌─────────────────┐                         │
│                                   │     2.2.3       │                         │
│                                   │  ADD API KEY    │                         │
│                                   │ & HEADERS       │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ complete_request                  │
│                                            ▼                                   │
│                                   ┌─────────────────┐                         │
│                                   │     2.2.4       │                         │
│                                   │  VALIDATE       │                         │
│                                   │  REQUEST        │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ validated_request                 │
│                                            ▼                                   │
│                ┌─────────────┐    ┌─────────────────┐                         │
│                │   NewsAPI   │←───│     2.2.5       │                         │
│                │    .org     │    │  EXECUTE HTTP   │                         │
│                │             │───→│    REQUEST      │                         │
│                └─────────────┘    └─────────────────┘                         │
│                                            │                                   │
│                                            │ api_response                      │
│                                            ▼                                   │
│  ┌─────────────┐                  ┌─────────────────┐                         │
│  │   Process   │  response_data   │     2.2.6       │                         │
│  │     2.3     │ ←────────────────│  HANDLE         │                         │
│  │             │                  │  RESPONSE       │                         │
│  └─────────────┘                  └─────────────────┘                         │
│                                                                                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Process 2.2.1: BUILD BASE URL
**Input**: Parsed parameters (category, country, search terms)
**Process**:
- Determines endpoint type (headlines vs everything)
- Constructs base NewsAPI URL
- Sets request method (GET)
**Output**: Base URL string
**Logic**:
```
if (category or country specified):
    base_url = "https://newsapi.org/v2/top-headlines"
else if (search_query specified):
    base_url = "https://newsapi.org/v2/everything"
else:
    base_url = "https://newsapi.org/v2/top-headlines"
```

### Process 2.2.2: ADD QUERY PARAMETERS
**Input**: Base URL and parsed parameters
**Process**:
- Encodes parameters for URL safety
- Builds query string
- Handles special characters and spacing
**Output**: URL with query parameters
**Operations**:
- URL encoding of search terms
- Parameter validation and formatting
- Query string construction

### Process 2.2.3: ADD API KEY & HEADERS
**Input**: URL with parameters
**Process**:
- Adds NewsAPI authentication key
- Sets required HTTP headers
- Configures request timeout settings
**Output**: Complete request configuration
**Headers Added**:
- `X-Api-Key`: Authentication
- `User-Agent`: Application identification
- `Accept`: JSON response format

### Process 2.2.4: VALIDATE REQUEST
**Input**: Complete request configuration
**Process**:
- Validates URL format and parameters
- Checks API key presence
- Verifies request size limits
**Output**: Validated request ready for execution
**Validation Rules**:
- URL length < 2048 characters
- Required parameters present
- API key format valid

### Process 2.2.5: EXECUTE HTTP REQUEST
**Input**: Validated request
**Process**:
- Sends HTTP GET request to NewsAPI
- Handles network timeouts and retries
- Manages connection pooling
**Output**: Raw API response
**Error Handling**:
- Network connectivity issues
- Timeout management
- Rate limit detection

### Process 2.2.6: HANDLE RESPONSE
**Input**: Raw API response
**Process**:
- Checks HTTP status codes
- Validates response format
- Extracts response data or error information
**Output**: Response data for further processing
**Status Code Handling**:
- 200: Success - forward data
- 401: Unauthorized - API key error
- 429: Rate limited - retry logic
- 500: Server error - error handling

## Level 3 DFD: Process 4.4 - EXECUTE DATABASE OPERATION

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                  PROCESS 4.4: EXECUTE DATABASE OPERATION                        │
│                                                                                 │
│  ┌─────────────┐                   ┌─────────────────┐                         │
│  │   Process   │  prepared_data   │     4.4.1       │                         │
│  │     4.3     │ ────────────────→│  OPEN DATABASE  │                         │
│  │             │                  │   CONNECTION    │                         │
│  └─────────────┘                  └─────────────────┘                         │
│                                            │                                   │
│                                            │ db_connection                     │
│                                            ▼                                   │
│                                   ┌─────────────────┐                         │
│                                   │     4.4.2       │                         │
│                                   │ BEGIN           │                         │
│                                   │ TRANSACTION     │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ transaction_context               │
│                                            ▼                                   │
│                ┌─────────────┐    ┌─────────────────┐                         │
│                │     D2      │←───│     4.4.3       │                         │
│                │ SAVED_      │    │  PREPARE SQL    │                         │
│                │ ARTICLES    │───→│   STATEMENT     │                         │
│                └─────────────┘    └─────────────────┘                         │
│                                            │                                   │
│                                            │ sql_statement                     │
│                                            ▼                                   │
│                ┌─────────────┐    ┌─────────────────┐                         │
│                │     D2      │←───│     4.4.4       │                         │
│                │ SAVED_      │    │  EXECUTE SQL    │                         │
│                │ ARTICLES    │───→│   OPERATION     │                         │
│                └─────────────┘    └─────────────────┘                         │
│                                            │                                   │
│                                            │ execution_result                  │
│                                            ▼                                   │
│                                   ┌─────────────────┐                         │
│                                   │     4.4.5       │                         │
│                                   │  VALIDATE       │                         │
│                                   │   RESULT        │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ validated_result                  │
│                                            ▼                                   │
│                                   ┌─────────────────┐                         │
│                                   │     4.4.6       │                         │
│                                   │  COMMIT/        │                         │
│                                   │  ROLLBACK       │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ final_result                      │
│                                            ▼                                   │
│  ┌─────────────┐                  ┌─────────────────┐                         │
│  │   Process   │  operation_result│     4.4.7       │                         │
│  │     4.5     │ ←────────────────│  CLOSE          │                         │
│  │             │                  │  CONNECTION     │                         │
│  └─────────────┘                  └─────────────────┘                         │
│                                                                                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Process 4.4.1: OPEN DATABASE CONNECTION
**Input**: Prepared data from Process 4.3
**Process**:
- Initializes SQLite database connection
- Checks database file existence
- Handles database creation if needed
**Output**: Database connection object
**Operations**:
- Database path resolution
- Connection pooling management
- Database schema verification

### Process 4.4.2: BEGIN TRANSACTION
**Input**: Database connection
**Process**:
- Starts database transaction
- Sets isolation level
- Prepares rollback capability
**Output**: Transaction context
**Transaction Properties**:
- ACID compliance
- Isolation level: READ_COMMITTED
- Auto-rollback on error

### Process 4.4.3: PREPARE SQL STATEMENT
**Input**: Transaction context and prepared data
**Process**:
- Constructs parameterized SQL statement
- Binds article data parameters
- Validates SQL syntax
**Output**: Prepared SQL statement
**SQL Operations**:
```sql
-- For new articles
INSERT INTO saved_articles 
(title, author, description, url, urlToImage, publishedAt, content, source, savedAt) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)

-- For duplicate handling
INSERT OR REPLACE INTO saved_articles 
(title, author, description, url, urlToImage, publishedAt, content, source, savedAt) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
```

### Process 4.4.4: EXECUTE SQL OPERATION
**Input**: Prepared SQL statement
**Process**:
- Executes the SQL operation
- Captures affected row count
- Handles SQL errors and constraints
**Output**: Execution result
**Error Handling**:
- Constraint violations (duplicate URLs)
- Data type mismatches
- Storage space limitations

### Process 4.4.5: VALIDATE RESULT
**Input**: Execution result
**Process**:
- Checks affected row count
- Validates operation success
- Determines if rollback is needed
**Output**: Validated result
**Validation Criteria**:
- Row count > 0 for success
- No SQL error messages
- Data integrity maintained

### Process 4.4.6: COMMIT/ROLLBACK
**Input**: Validated result
**Process**:
- Commits transaction on success
- Rolls back on failure
- Cleans up transaction resources
**Output**: Final result status
**Logic**:
```
if (validated_result == SUCCESS):
    COMMIT transaction
    final_result = SUCCESS
else:
    ROLLBACK transaction
    final_result = FAILURE
```

### Process 4.4.7: CLOSE CONNECTION
**Input**: Final result
**Process**:
- Closes database connection
- Releases connection resources
- Logs operation completion
**Output**: Operation result to Process 4.5
**Cleanup Operations**:
- Connection pool management
- Resource deallocation
- Performance logging

## Level 3 DFD: Process 5.4 - SYNC TO CLOUD STORAGE

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                   PROCESS 5.4: SYNC TO CLOUD STORAGE                            │
│                                                                                 │
│  ┌─────────────┐                   ┌─────────────────┐                         │
│  │   Process   │  updated_prefs   │     5.4.1       │                         │
│  │     5.3     │ ────────────────→│  AUTHENTICATE   │                         │
│  │             │                  │   FIRESTORE     │                         │
│  └─────────────┘                  └─────────────────┘                         │
│                                            │                                   │
│                                            │ auth_token                        │
│                                            ▼                                   │
│                                   ┌─────────────────┐                         │
│                                   │     5.4.2       │                         │
│                                   │  PREPARE        │                         │
│                                   │  DOCUMENT       │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ document_data                     │
│                                            ▼                                   │
│                                   ┌─────────────────┐                         │
│                                   │     5.4.3       │                         │
│                                   │  CHECK          │                         │
│                                   │  CONFLICTS      │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ conflict_resolution               │
│                                            ▼                                   │
│                ┌─────────────┐    ┌─────────────────┐                         │
│                │  Firebase   │←───│     5.4.4       │                         │
│                │ Firestore   │    │  EXECUTE        │                         │
│                │             │───→│  FIRESTORE      │                         │
│                └─────────────┘    │  OPERATION      │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ operation_response                │
│                                            ▼                                   │
│                                   ┌─────────────────┐                         │
│                                   │     5.4.5       │                         │
│                                   │  HANDLE         │                         │
│                                   │  RESPONSE       │                         │
│                                   └─────────────────┘                         │
│                                            │                                   │
│                                            │ sync_result                       │
│                                            ▼                                   │
│  ┌─────────────┐                  ┌─────────────────┐                         │
│  │   Process   │  result_status   │     5.4.6       │                         │
│  │     5.5     │ ←────────────────│  LOG & NOTIFY   │                         │
│  │             │                  │    RESULT       │                         │
│  └─────────────┘                  └─────────────────┘                         │
│                                                                                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Process 5.4.1: AUTHENTICATE FIRESTORE
**Input**: Updated preferences data
**Process**:
- Validates Firebase user authentication
- Obtains Firestore access tokens
- Checks user permissions for data access
**Output**: Authentication token
**Authentication Flow**:
- Firebase Auth token validation
- Firestore security rules check
- Permission scope verification

### Process 5.4.2: PREPARE DOCUMENT
**Input**: Authentication token and preferences data
**Process**:
- Formats data for Firestore document structure
- Creates document ID and path
- Serializes complex data types
**Output**: Document data ready for storage
**Document Structure**:
```json
{
  "userId": "user_firebase_uid",
  "preferences": {
    "categories": ["technology", "business"],
    "sources": ["bbc", "cnn"],
    "ratings": {
      "article_url_1": 5,
      "article_url_2": 3
    }
  },
  "updatedAt": "2025-09-03T10:30:00Z",
  "version": 1
}
```

### Process 5.4.3: CHECK CONFLICTS
**Input**: Document data
**Process**:
- Checks for concurrent updates
- Compares document versions
- Determines merge strategy
**Output**: Conflict resolution strategy
**Conflict Resolution**:
- Last-write-wins for simple fields
- Array merge for preferences
- Timestamp comparison for conflicts

### Process 5.4.4: EXECUTE FIRESTORE OPERATION
**Input**: Document data and conflict resolution
**Process**:
- Executes Firestore write operation
- Handles batch operations for large data
- Manages network retries and timeouts
**Output**: Operation response from Firestore
**Operations**:
- `setDoc()` for new documents
- `updateDoc()` for partial updates
- `mergeDoc()` for conflict resolution

### Process 5.4.5: HANDLE RESPONSE
**Input**: Operation response
**Process**:
- Parses Firestore response data
- Handles success and error cases
- Extracts updated document metadata
**Output**: Sync result status
**Response Handling**:
- Success: Extract document version
- Permission denied: Handle auth errors
- Network error: Trigger retry logic

### Process 5.4.6: LOG & NOTIFY RESULT
**Input**: Sync result
**Process**:
- Logs synchronization events
- Prepares user notifications
- Updates local sync status
**Output**: Result status to Process 5.5
**Logging Information**:
- Operation timestamp
- Data size synchronized
- Success/failure status
- Error details if applicable

## Data Transformations in Level 3

### Data Format Transformations

#### Process 2.2 - API Request Construction
```
Input: {category: "technology", country: "us", pageSize: 20}
↓
Transformation: URL encoding and parameter formatting
↓
Output: "https://newsapi.org/v2/top-headlines?category=technology&country=us&pageSize=20&apiKey=xxx"
```

#### Process 4.4 - Database Operation
```
Input: Article{title: "Tech News", url: "https://example.com/news/1", ...}
↓
Transformation: Object to SQL parameters
↓
Output: SQL execution with bound parameters
```

#### Process 5.4 - Firestore Sync
```
Input: UserPreferences{categories: ["tech", "business"], ratings: Map<String, int>}
↓
Transformation: Object serialization to JSON document
↓
Output: Firestore document with nested structure
```

### Error Handling Patterns

Each Level 3 process includes comprehensive error handling:
- **Input validation** at process entry
- **Operation-specific error handling** during execution
- **Cleanup operations** in finally blocks
- **Error propagation** to parent processes
- **User notification** of critical errors

### Performance Considerations

- **Database connections**: Connection pooling and reuse
- **API requests**: Rate limiting and caching
- **Firestore operations**: Batch operations for efficiency
- **Memory management**: Proper resource cleanup
- **Network operations**: Timeout and retry mechanisms
