# Firebase Composite Index Setup

## Required Index for Habit Logs

The app requires a composite index for the `habit_logs` collection to enable date-based queries.

### Manual Setup (Recommended)

1. Click the index creation URL from the error log:
   ```
   https://console.firebase.google.com/v1/r/project/pazartesi-basliyorum/firestore/indexes?create_composite=...
   ```

2. Or manually create in Firebase Console:
   - Go to: https://console.firebase.google.com/project/pazartesi-basliyorum/firestore/indexes
   - Click "Create Index"
   - Collection: `habit_logs`
   - Fields:
     - `userId` → Ascending
     - `date` → Ascending
   - Query scope: Collection
   - Click "Create"

3. Wait 2-5 minutes for index to build

### Alternative: Deploy via JSON

If you have the full index definition, add it to `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "habit_logs",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "date",
          "order": "ASCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

Then deploy:
```bash
firebase deploy --only firestore:indexes
```

## Index Status

Check index build progress:
https://console.firebase.google.com/project/pazartesi-basliyorum/firestore/indexes

When status shows "Enabled", the index is ready.
