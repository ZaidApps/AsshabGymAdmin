# Firestore Indexes for Check-ins Collection

## Composite Index for Check-ins Collection

**Collection**: `checkins`

**Index Name**: `checkins_query_index`

**Fields**:
- `checkin_date` (ascending)
- `timestamp` (descending) 
- `device_id` (ascending)
- `memberDocId` (ascending)

**Query Mode**: `ASCENDING`

**Purpose**: 
- Optimize date range queries using `checkin_date`
- Optimize ordering by most recent using `timestamp`
- Optimize member lookup by `device_id` and `memberDocId`
- Support filtering by date ranges and sorting by timestamp

**Usage**:
This index supports the following query patterns:
1. Date range filtering: `where('checkin_date', >=: startDate).where('checkin_date', <=: endDate)`
2. Recent ordering: `orderBy('timestamp', descending: true)`
3. Device-based queries: `where('device_id', isEqualTo: deviceId)`
4. Member-based queries: `where('memberDocId', isEqualTo: memberDocId)`

**Firebase Console Creation**:
1. Go to: https://console.firebase.google.com/v1/r/project/ashhabgymweb/firestore/indexes?create_composite=Ck1wcm9ZWN0cy9hc2hoYWJneW1tZW5zZG9vY3VzdWl0c3Rpb24Kb2xrZWdodXBsZXN0aWxlbnQ6MDAyNDU4NTI=
2. Select Collection: `checkins`
3. Add fields in order: `checkin_date`, `timestamp`, `device_id`, `memberDocId`
4. Set Query Mode: `ASCENDING`
5. Create Index

**Benefits**:
- Faster date range queries
- Improved performance for recent check-ins display
- Better member status lookup
- Reduced Firestore read operations
