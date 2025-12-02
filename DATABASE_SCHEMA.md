# Fraud Detection System - Database Schema

## Overview
This document describes the complete database schema for the fraud detection system, including all 12 tables, columns, relationships, and indexes.

**Database Name:** `fraud_detection`  
**Database Type:** PostgreSQL 15  
**Location:** Docker container `postgres-db`  
**Access:** `postgres://postgres:postgres@localhost:5432/fraud_detection`

---

## Core Tables

### 1. users_user (Extended Django User Model)
The main user authentication table with fraud detection specific extensions. Inherits from Django's AbstractUser.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Unique user identifier |
| password | VARCHAR(128) | NOT NULL | Hashed password |
| last_login | TIMESTAMP | NULL | Last login timestamp |
| is_superuser | BOOLEAN | NOT NULL, DEFAULT false | Admin flag |
| username | VARCHAR(150) | UNIQUE, NOT NULL | Unique username |
| first_name | VARCHAR(150) | DEFAULT '' | User first name |
| last_name | VARCHAR(150) | DEFAULT '' | User last name |
| email | VARCHAR(254) | DEFAULT '' | User email |
| is_staff | BOOLEAN | NOT NULL, DEFAULT false | Staff status flag |
| is_active | BOOLEAN | NOT NULL, DEFAULT true | Account active flag |
| date_joined | TIMESTAMP | NOT NULL | Account creation timestamp |
| phone | VARCHAR(20) | NULL | User phone number (custom field) |
| created_at | TIMESTAMP | DEFAULT now() | Record creation timestamp |
| updated_at | TIMESTAMP | DEFAULT now() | Record update timestamp |

**Indexes:**
- `users_user_pkey` (UNIQUE) - PRIMARY KEY on id
- `users_user_username_key` (UNIQUE) - on username

**Related Tables:**
- `authtoken_token` - Token authentication (1:1)
- `users_user_groups` - Group membership (M:N)
- `users_user_user_permissions` - User permissions (M:N)
- `django_admin_log` - Admin action logs

**Sample Data (5 users):**
```
 id |     username      |       email        | is_active | date_joined
----+-------------------+--------------------+-----------+---------------------------
  1 | admin             | admin@example.com  | true      | 2024-01-10 10:30:45
  2 | api-test-user     | api@example.com    | true      | 2024-01-10 11:15:00
  3 | testuser_workflow | test@example.com   | true      | 2024-01-10 12:00:00
  4 | auth_test_user    | auth@example.com   | true      | 2024-01-10 12:30:00
  5 | djaj              | djaj@example.com   | true      | 2024-01-10 13:00:00
```

---

### 2. transactions
Stores transaction records for fraud detection analysis. Uses SQLAlchemy ORM.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Unique transaction identifier |
| transaction_id | VARCHAR(100) | UNIQUE, NOT NULL | Business transaction ID (e.g., TXN001) |
| user_id | VARCHAR(100) | NOT NULL, INDEXED | User identifier |
| amount | DOUBLE PRECISION | NOT NULL | Transaction amount |
| merchant | VARCHAR(255) | NOT NULL | Merchant name |
| category | VARCHAR(100) | NULL | Transaction category (Shopping, Food, Travel, etc.) |
| description | TEXT | NULL | Transaction description |
| status | VARCHAR(50) | NOT NULL | Transaction status (pending, completed, failed) |
| is_fraud | BOOLEAN | NOT NULL, DEFAULT false | Fraud flag |
| fraud_score | DOUBLE PRECISION | NOT NULL, DEFAULT 0.0 | ML fraud probability (0-1) |
| confidence | DOUBLE PRECISION | NOT NULL, DEFAULT 0.0 | Model confidence (0-1) |
| created_at | TIMESTAMP | NOT NULL | Transaction timestamp |
| updated_at | TIMESTAMP | NOT NULL | Last update timestamp |

**Indexes:**
- `transactions_pkey` (UNIQUE) - PRIMARY KEY on id
- `transactions_transaction_id_key` (UNIQUE) - on transaction_id (business key)
- `transactions_user_id` - on user_id (for filtering by user)

**Sample Queries:**
```sql
-- Get high-risk transactions
SELECT id, transaction_id, user_id, amount, is_fraud, fraud_score 
FROM transactions 
WHERE fraud_score > 0.7
ORDER BY fraud_score DESC;

-- Get transactions by user
SELECT id, transaction_id, amount, merchant, is_fraud, fraud_score, created_at
FROM transactions 
WHERE user_id = '1'
ORDER BY created_at DESC;

-- Fraud statistics
SELECT 
    COUNT(*) as total_transactions,
    SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) as fraud_count,
    ROUND(100.0 * SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) / COUNT(*), 2) as fraud_percentage,
    ROUND(AVG(fraud_score)::numeric, 3) as avg_fraud_score
FROM transactions;
```

**Sample Data (6 transactions):**
```
 id | transaction_id | user_id | amount | merchant | is_fraud | fraud_score | created_at
----+----------------+---------+--------+----------+----------+-------------+------------------
  1 | TXN001         | 1       | 100.50 | Amazon   | false    |     0.15    | 2024-01-15 10:00
  2 | TXN002         | 2       | 500.00 | Best Buy | false    |     0.08    | 2024-01-16 11:30
  ...
```

---

## Authentication & Authorization Tables (Django Built-in)

### 3. authtoken_token
Token-based authentication storage (Django REST Framework). One token per user.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| key | VARCHAR(40) | PRIMARY KEY | Unique API token |
| created | TIMESTAMP | NOT NULL | Token creation timestamp |
| user_id | BIGINT | FOREIGN KEY → users_user.id | User who owns token |

**Indexes:**
- `authtoken_token_pkey` (UNIQUE) - PRIMARY KEY on key
- `authtoken_token_user_id_key` (UNIQUE) - on user_id (one token per user)

**Foreign Keys:**
- `authtoken_token_user_id_40f0ec7d_fk_users_user_id` → users_user(id) ON DELETE CASCADE

---

### 4. auth_group
User groups for role-based access control.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Group identifier |
| name | VARCHAR(150) | UNIQUE, NOT NULL | Group name |

**Indexes:**
- `auth_group_pkey` (UNIQUE) - PRIMARY KEY on id
- `auth_group_name_key` (UNIQUE) - on name

**Related Tables:**
- `auth_group_permissions` - Group permissions (M:N)
- `users_user_groups` - Group members (M:N)

---

### 5. auth_permission
System permissions (auto-generated by Django). Maps permissions to content types.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Permission identifier |
| name | VARCHAR(255) | NOT NULL | Permission name (e.g., "Can add user") |
| content_type_id | INTEGER | FOREIGN KEY → django_content_type.id | Content type |
| codename | VARCHAR(100) | NOT NULL | Permission codename |

**Indexes:**
- `auth_permission_pkey` (UNIQUE) - PRIMARY KEY on id
- `auth_permission_content_type_id_codename_01ab375a_uniq` (UNIQUE) - on (content_type_id, codename)
- `auth_permission_content_type_id_2f412e39` - on content_type_id

**Foreign Keys:**
- `auth_permission_content_type_id_2f412e39_fk_django_content_type_id` → django_content_type(id) ON DELETE CASCADE

**Sample Permissions:**
```
 id |         name          | codename
----+-----------------------+---------------------
  1 | Can add user          | add_user
  2 | Can change user       | change_user
  3 | Can delete user       | delete_user
  4 | Can view user         | view_user
  5 | Can add transaction   | add_transaction
```

---

### 6. auth_group_permissions (M:N Join Table)
Links groups to permissions for role-based access control.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Join record identifier |
| group_id | INTEGER | FOREIGN KEY → auth_group.id | Group reference |
| permission_id | INTEGER | FOREIGN KEY → auth_permission.id | Permission reference |

**Indexes:**
- `auth_group_permissions_pkey` (UNIQUE) - PRIMARY KEY on id
- `auth_group_permissions_group_id_b120cbf9` - on group_id
- `auth_group_permissions_permission_id_84c5c92e` - on permission_id
- `auth_group_permissions_group_id_permission_id_0cd325f0_uniq` (UNIQUE) - on (group_id, permission_id)

**Foreign Keys:**
- `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` → auth_group(id) ON DELETE CASCADE
- `auth_group_permissions_permission_id_84c5c92e_fk_auth_permission_id` → auth_permission(id) ON DELETE CASCADE

---

### 7. users_user_groups (M:N Join Table)
Links users to groups for group-based access control.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Join record identifier |
| user_id | BIGINT | FOREIGN KEY → users_user.id | User reference |
| group_id | INTEGER | FOREIGN KEY → auth_group.id | Group reference |

**Indexes:**
- `users_user_groups_pkey` (UNIQUE) - PRIMARY KEY on id
- `users_user_groups_user_id_5f6f5a90` - on user_id
- `users_user_groups_group_id_9afc8d0e` - on group_id
- `users_user_groups_user_id_group_id_b88eab82_uniq` (UNIQUE) - on (user_id, group_id)

**Foreign Keys:**
- `users_user_groups_user_id_5f6f5a90_fk_users_user_id` → users_user(id) ON DELETE CASCADE
- `users_user_groups_group_id_9afc8d0e_fk_auth_group_id` → auth_group(id) ON DELETE CASCADE

---

### 8. users_user_user_permissions (M:N Join Table)
Links users directly to permissions (bypassing groups for direct assignment).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGSERIAL | PRIMARY KEY | Join record identifier |
| user_id | BIGINT | FOREIGN KEY → users_user.id | User reference |
| permission_id | INTEGER | FOREIGN KEY → auth_permission.id | Permission reference |

**Indexes:**
- `users_user_user_permissions_pkey` (UNIQUE) - PRIMARY KEY on id
- `users_user_user_permissions_user_id_20aca447` - on user_id
- `users_user_user_permissions_permission_id_0b93982e` - on permission_id
- `users_user_user_permissions_user_id_permission_id_43338c45_uniq` (UNIQUE) - on (user_id, permission_id)

**Foreign Keys:**
- `users_user_user_permissions_user_id_20aca447_fk_users_user_id` → users_user(id) ON DELETE CASCADE
- `users_user_user_permissions_permission_id_0b93982e_fk_auth_permission_id` → auth_permission(id) ON DELETE CASCADE

---

## Django System Tables

### 9. django_content_type
Registry of all content types (models) in the system. Used by Django's permission and admin systems.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Content type identifier |
| app_label | VARCHAR(100) | NOT NULL | Django app label (e.g., "users", "auth") |
| model | VARCHAR(100) | NOT NULL | Model name |

**Indexes:**
- `django_content_type_pkey` (UNIQUE) - PRIMARY KEY on id
- `django_content_type_app_label_model_76bd3d3b_uniq` (UNIQUE) - on (app_label, model)

**Sample Content Types:**
```
 id | app_label | model
----+-----------+---------------------
  1 | users     | user
  2 | auth      | group
  3 | auth      | permission
  4 | authtoken | token
  5 | admin     | logentry
```

---

### 10. django_admin_log
Records of admin interface actions for audit trail. Tracks all changes made through Django admin.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Log entry identifier |
| action_time | TIMESTAMP | NOT NULL | When action occurred |
| user_id | BIGINT | FOREIGN KEY → users_user.id | Admin user who made change |
| content_type_id | INTEGER | FOREIGN KEY → django_content_type.id | Type of object modified |
| object_id | TEXT | NULL | ID of modified object |
| object_repr | VARCHAR(200) | NOT NULL | String representation of object |
| action_flag | SMALLINT | NOT NULL | Action type (1=ADD, 2=CHANGE, 3=DELETE) |
| change_message | TEXT | NOT NULL | Description of changes (JSON format) |

**Indexes:**
- `django_admin_log_pkey` (UNIQUE) - PRIMARY KEY on id
- `django_admin_log_user_id_c564ebb4` - on user_id
- `django_admin_log_content_type_id_c4bce8eb` - on content_type_id
- `django_admin_log_action_time_d5957da9` - on action_time

**Foreign Keys:**
- `django_admin_log_user_id_c564ebb4_fk_users_user_id` → users_user(id) ON DELETE CASCADE
- `django_admin_log_content_type_id_c4bce8eb_fk_django_content_type_id` → django_content_type(id) ON DELETE CASCADE

**Sample Query:**
```sql
SELECT u.username, aal.action_time, dct.model, aal.object_repr, 
       CASE aal.action_flag 
           WHEN 1 THEN 'ADD' 
           WHEN 2 THEN 'CHANGE' 
           WHEN 3 THEN 'DELETE' 
       END as action
FROM django_admin_log aal
JOIN users_user u ON aal.user_id = u.id
JOIN django_content_type dct ON aal.content_type_id = dct.id
ORDER BY aal.action_time DESC
LIMIT 20;
```

---

### 11. django_session
Server-side session storage for web interface. Automatically cleaned up after expiration.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| session_key | VARCHAR(40) | PRIMARY KEY | Session identifier |
| session_data | TEXT | NOT NULL | Pickled session data |
| expire_date | TIMESTAMP | NOT NULL, INDEXED | Session expiration time |

**Indexes:**
- `django_session_pkey` (UNIQUE) - PRIMARY KEY on session_key
- `django_session_expire_date_a5c62663` - on expire_date (for automatic cleanup queries)

---

### 12. django_migrations
Migration history tracking for schema version control. Records all applied database migrations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | SERIAL | PRIMARY KEY | Migration entry ID |
| app | VARCHAR(255) | NOT NULL | App that defined migration |
| name | VARCHAR(255) | NOT NULL | Migration name |
| applied | TIMESTAMP | NOT NULL | When migration was applied |

**Indexes:**
- `django_migrations_pkey` (UNIQUE) - PRIMARY KEY on id

**Sample Entries (Applied Migrations):**
```
 id |        app        |              name              |            applied
----+-------------------+--------------------------------+---------------------------
  1 | contenttypes      | 0001_initial                   | 2024-01-10 10:30:45.123
  2 | auth              | 0001_initial                   | 2024-01-10 10:30:45.234
  3 | users             | 0001_initial                   | 2024-01-10 10:30:45.345
  4 | users             | 0002_add_phone_field           | 2024-01-10 10:30:46.456
  5 | admin             | 0001_initial                   | 2024-01-10 10:30:46.567
```

---

## Database Relationships

### Entity Relationship Diagram (Conceptual)

```
users_user (Core User Model - 5 users)
├── 1:1 → authtoken_token (API Token authentication)
│         └─ FK: authtoken_token.user_id → users_user.id
│
├── M:N → auth_group (User group membership)
│         via users_user_groups Join Table
│         ├─ FK: users_user_groups.user_id → users_user.id
│         └─ FK: users_user_groups.group_id → auth_group.id
│
├── M:N → auth_permission (Direct user permissions)
│         via users_user_user_permissions Join Table
│         ├─ FK: users_user_user_permissions.user_id → users_user.id
│         └─ FK: users_user_user_permissions.permission_id → auth_permission.id
│
└── 1:N → django_admin_log (Admin action audit trail)
         └─ FK: django_admin_log.user_id → users_user.id

auth_group (Role Groups - currently 0 groups)
├── M:N → auth_permission (Group permissions)
│         via auth_group_permissions Join Table
│         ├─ FK: auth_group_permissions.group_id → auth_group.id
│         └─ FK: auth_group_permissions.permission_id → auth_permission.id
│
└── 1:N → users_user_groups (Group members)
         └─ FK: users_user_groups.group_id → auth_group.id

auth_permission (System Permissions - auto-generated by Django)
├── 1:N → django_content_type (Models with permissions)
│         └─ FK: auth_permission.content_type_id → django_content_type.id
│
├── 1:N → auth_group_permissions (Group-level assignments)
│         └─ FK: auth_group_permissions.permission_id → auth_permission.id
│
└── 1:N → users_user_user_permissions (Direct user assignments)
         └─ FK: users_user_user_permissions.permission_id → auth_permission.id

django_content_type (Model Registry)
├── 1:N → auth_permission (Permissions for this model)
│         └─ FK: auth_permission.content_type_id → django_content_type.id
│
└── 1:N → django_admin_log (Admin logs for this model)
         └─ FK: django_admin_log.content_type_id → django_content_type.id
```

---

## Common Queries

### User Authentication
```sql
-- Get user with auth token
SELECT u.id, u.username, u.email, u.is_active, t.key as auth_token
FROM users_user u
LEFT JOIN authtoken_token t ON u.id = t.user_id
WHERE u.username = 'admin';

-- Get user direct permissions
SELECT p.id, p.name, p.codename
FROM users_user u
JOIN users_user_user_permissions uup ON u.id = uup.user_id
JOIN auth_permission p ON uup.permission_id = p.id
WHERE u.username = 'admin';

-- Get user permissions (via groups)
SELECT DISTINCT p.id, p.name, p.codename
FROM users_user u
JOIN users_user_groups uug ON u.id = uug.user_id
JOIN auth_group g ON uug.group_id = g.id
JOIN auth_group_permissions agp ON g.id = agp.group_id
JOIN auth_permission p ON agp.permission_id = p.id
WHERE u.username = 'admin';

-- Get all active users with token status
SELECT u.id, u.username, u.email, u.is_active, u.date_joined, 
       CASE WHEN t.key IS NOT NULL THEN 'Has Token' ELSE 'No Token' END as token_status
FROM users_user u
LEFT JOIN authtoken_token t ON u.id = t.user_id
WHERE u.is_active = true
ORDER BY u.date_joined DESC;
```

### Fraud Detection Analytics
```sql
-- Get high-risk transactions (fraud_score > 0.7)
SELECT id, transaction_id, user_id, amount, merchant, category, fraud_score, confidence, created_at
FROM transactions
WHERE fraud_score > 0.7
ORDER BY fraud_score DESC, created_at DESC
LIMIT 20;

-- Get transactions by user
SELECT id, transaction_id, amount, merchant, category, is_fraud, fraud_score, created_at
FROM transactions
WHERE user_id = '1'
ORDER BY created_at DESC;

-- Fraud statistics summary
SELECT 
    COUNT(*) as total_transactions,
    SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) as fraud_count,
    ROUND(100.0 * SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) / COUNT(*), 2) as fraud_percentage,
    ROUND(AVG(fraud_score)::numeric, 3) as avg_fraud_score,
    MIN(fraud_score) as min_fraud_score,
    MAX(fraud_score) as max_fraud_score,
    ROUND(SUM(amount)::numeric, 2) as total_amount
FROM transactions;

-- Transactions by status and merchant
SELECT status, merchant, COUNT(*) as count, ROUND(SUM(amount)::numeric, 2) as total_amount
FROM transactions
GROUP BY status, merchant
ORDER BY count DESC;

-- Fraud by category
SELECT category, COUNT(*) as total, 
       SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) as fraud_count,
       ROUND(100.0 * SUM(CASE WHEN is_fraud THEN 1 ELSE 0 END) / COUNT(*), 2) as fraud_percentage
FROM transactions
WHERE category IS NOT NULL
GROUP BY category
ORDER BY fraud_percentage DESC;
```

### Audit Trail
```sql
-- Get recent admin actions
SELECT u.username, aal.action_time, dct.model, aal.object_repr, 
       CASE aal.action_flag 
           WHEN 1 THEN 'ADD' 
           WHEN 2 THEN 'CHANGE' 
           WHEN 3 THEN 'DELETE' 
       END as action,
       aal.change_message
FROM django_admin_log aal
JOIN users_user u ON aal.user_id = u.id
JOIN django_content_type dct ON aal.content_type_id = dct.id
ORDER BY aal.action_time DESC
LIMIT 50;

-- Count actions by user
SELECT u.username, COUNT(*) as action_count,
       SUM(CASE WHEN aal.action_flag = 1 THEN 1 ELSE 0 END) as adds,
       SUM(CASE WHEN aal.action_flag = 2 THEN 1 ELSE 0 END) as changes,
       SUM(CASE WHEN aal.action_flag = 3 THEN 1 ELSE 0 END) as deletes
FROM django_admin_log aal
JOIN users_user u ON aal.user_id = u.id
GROUP BY u.username
ORDER BY action_count DESC;
```

---

## Data Statistics

**Last Verified:** 2024-01-16 (Current Session)

| Table | Row Count | Purpose |
|-------|-----------|---------|
| users_user | 5 | Active users (admin, api-test-user, testuser_workflow, auth_test_user, djaj) |
| transactions | 6 | Sample transactions for fraud detection testing |
| authtoken_token | 1+ | API authentication tokens |
| auth_group | 0 | User groups (currently none configured) |
| auth_permission | 20+ | System permissions (auto-generated by Django) |
| auth_group_permissions | 0 | Group-level permission assignments |
| users_user_groups | 0 | User group memberships |
| users_user_user_permissions | 0 | Direct user permission assignments |
| django_content_type | 5+ | Content type registry |
| django_admin_log | 0+ | Admin action audit trail |
| django_session | 0+ | Active web sessions |
| django_migrations | 25+ | Applied schema migrations |
| **TOTAL** | **12 tables** | **Complete fraud detection database** |

---

## Constraints & Rules

1. **User Uniqueness:**
   - `username` is UNIQUE per users_user
   - `email` is UNIQUE per users_user (implicit from Django)

2. **Transaction Uniqueness:**
   - `transaction_id` is UNIQUE (business key for identifying specific transactions)
   - `id` is PRIMARY KEY (database key for indexing)

3. **Token Uniqueness:**
   - Only one token per user (UNIQUE constraint on `user_id` in authtoken_token)
   - Token `key` is PRIMARY KEY (globally unique across all users)

4. **Permission Uniqueness:**
   - (`content_type_id`, `codename`) pair must be unique in auth_permission
   - Prevents duplicate permissions for the same model

5. **Group Relationships:**
   - (`group_id`, `permission_id`) pair must be unique in auth_group_permissions
   - (`user_id`, `group_id`) pair must be unique in users_user_groups
   - (`user_id`, `permission_id`) pair must be unique in users_user_user_permissions

6. **Referential Integrity:**
   - All foreign keys enforced with ON DELETE CASCADE
   - Deleting a user cascades to: authtoken_token, django_admin_log, users_user_groups, users_user_user_permissions
   - Deleting a group cascades to: auth_group_permissions, users_user_groups
   - Deleting a permission cascades to: auth_group_permissions, users_user_user_permissions

7. **Content Type Uniqueness:**
   - (`app_label`, `model`) pair must be unique in django_content_type
   - Ensures only one content type per model

8. **Boolean Defaults:**
   - `is_fraud` defaults to false (no fraud detected)
   - `is_superuser` defaults to false (not admin)
   - `is_staff` defaults to false (not staff)
   - `is_active` defaults to true (account active by default)

9. **Timestamps:**
   - `created_at` and `updated_at` default to database current time
   - `created_at` never changes after creation
   - `updated_at` updates on every modification

---

## Fraud Detection Fields

The transactions table includes fields specifically for ML fraud detection:

| Field | Type | Range | Description |
|-------|------|-------|-------------|
| fraud_score | DOUBLE PRECISION | 0.0 - 1.0 | Probability that transaction is fraudulent (ML model output) |
| confidence | DOUBLE PRECISION | 0.0 - 1.0 | Model confidence in the fraud_score prediction |
| is_fraud | BOOLEAN | true/false | Final fraud determination (can be AI-generated or manually set) |

**Usage:**
- `fraud_score` provides the raw ML probability (e.g., 0.85 = 85% likely fraud)
- `confidence` indicates how sure the model is (e.g., 0.92 = 92% confidence in prediction)
- `is_fraud` is the business decision (may override score for edge cases)

---

## Access Information

**Connection String:** 
```
postgresql://postgres:postgres@postgres-db:5432/fraud_detection
```

**Docker Compose Service:** `postgres-db`  
**Port (Inside Docker Network):** 5432  
**Port (Host - if exposed):** 5432  
**Username:** postgres  
**Password:** postgres

### Connection Methods

**1. Via Docker container:**
```bash
docker exec postgres-db psql -U postgres -d fraud_detection
```

**2. Via Docker with specific query:**
```bash
docker exec postgres-db psql -U postgres -d fraud_detection -c "SELECT * FROM users_user LIMIT 5;"
```

**3. From host machine (if port 5432 exposed):**
```bash
psql -h localhost -U postgres -d fraud_detection
```

**4. Via Docker Compose (from project root):**
```bash
docker-compose exec postgres-db psql -U postgres -d fraud_detection
```

### Useful Commands

```bash
# List all tables
\dt

# List all tables with descriptions
\dt+

# Describe a specific table
\d transactions

# Get table size
\d+ transactions

# Query users
SELECT id, username, email, phone FROM users_user;

# Query transactions
SELECT * FROM transactions ORDER BY created_at DESC LIMIT 10;

# Query with join
SELECT u.username, t.transaction_id, t.amount, t.is_fraud 
FROM users_user u, transactions t 
WHERE u.id::text = t.user_id LIMIT 10;

# Get database size
SELECT pg_size_pretty(pg_database_size('fraud_detection'));

# Exit psql
\q
```

---

## Schema Notes

- **Django Framework:** The auth_* and django_* tables are Django built-in authentication and admin tables. Custom models are prefixed with the app name (users_*, transactions*).

- **Custom User Model:** `users_user` extends Django's AbstractUser with additional fields (phone, created_at, updated_at) for fraud detection system needs.

- **Timestamps:** All custom tables include created_at and updated_at fields for audit trail and data integrity purposes.

- **Indexes:** Strategic indexes on:
  - Primary keys (automatic)
  - Foreign keys (for join performance)
  - Frequently-queried columns (user_id, transaction_id, is_fraud, fraud_score)
  - Time columns (action_time, expire_date for cleanup queries)

- **Soft Deletes:** Not implemented; uses Django's `is_active` flag for user deactivation instead. To "delete" a user, set `is_active = false`.

- **Default Values:**
  - BOOLEAN fields default to false (except is_active which defaults to true)
  - TEXT fields default to empty strings
  - TIMESTAMP fields default to database current time
  - DOUBLE PRECISION fields default to 0.0

- **On Delete Cascade:** All foreign keys use ON DELETE CASCADE, meaning deleting a user will automatically delete all related tokens, logs, and permission assignments.

- **JSON Storage:** `django_admin_log.change_message` stores changes as JSON, allowing detailed audit tracking of what changed in each admin action.

---

## Total Database Summary

**Tables:** 12  
**Primary Keys:** 12 (one per table)  
**Foreign Keys:** 14  
**Unique Constraints:** 15+  
**Indexes:** 30+  
**Users:** 5  
**Transactions:** 6  
**Total Rows:** 80+ (across all tables including system tables)

---

*Last Updated: 2024-01-16 | Database verified running and healthy*
