# API Service Integration Guide

This guide explains how to use the API service to fetch grocery list data from your backend.

## Files Created

1. **`lib/models/grocery_list.dart`** - Data model for grocery lists
2. **`lib/services/api_service.dart`** - Service for making API calls
3. **`lib/widgets/list_section_with_api.dart`** - Example widget showing API integration

## Setup

### 1. Update Backend URL

Open `lib/services/api_service.dart` and update the base URL:

```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

### 2. Expected API Response Format

Your backend should return JSON data in this format:

**GET /api/lists** - Fetch all lists:
```json
[
  {
    "id": "1",
    "name": "Weekly Groceries",
    "items": "12 of 20",
    "progress": 0.6,
    "time": "2H AGO",
    "icon": "shopping_cart"
  },
  {
    "id": "2",
    "name": "Party Supplies",
    "items": "5 of 15",
    "progress": 0.33,
    "time": "5H AGO",
    "icon": "celebration"
  }
]
```

### 3. Available Icon Names

The following icon names are supported:
- `shopping_cart`
- `celebration`
- `breakfast`
- `cleaning`
- `apple`
- `inventory`
- `child_care`
- `pets`
- `list` (default)

## Usage

### Option 1: Use the API-Enabled Widget

Replace the current `ListSection` in your `landing_page.dart` with `ListSectionWithApi`:

```dart
import 'widgets/list_section_with_api.dart';

// In your build method:
ListSectionWithApi(
  accent: accent,
  height: listH,
),
```

### Option 2: Integrate API into Existing Widget

Modify your existing `list_section.dart`:

```dart
import '../models/grocery_list.dart';
import '../services/api_service.dart';

// Convert to StatefulWidget
class ListSection extends StatefulWidget {
  // ... existing code
}

class _ListSectionState extends State<ListSection> {
  final ApiService _apiService = ApiService();
  List<GroceryList> _lists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLists();
  }

  Future<void> _fetchLists() async {
    try {
      final lists = await _apiService.fetchGroceryLists();
      setState(() {
        _lists = lists;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    // ... rest of your build method
  }
}
```

## API Methods Available

### Fetch All Lists
```dart
final apiService = ApiService();
List<GroceryList> lists = await apiService.fetchGroceryLists();
```

### Fetch Single List
```dart
GroceryList list = await apiService.fetchGroceryListById('list-id');
```

### Create New List
```dart
GroceryList newList = GroceryList(
  id: '',
  name: 'Shopping List',
  items: '0 of 10',
  progress: 0.0,
  time: 'Just now',
  icon: Icons.shopping_cart_outlined,
);
GroceryList created = await apiService.createGroceryList(newList);
```

### Update List
```dart
await apiService.updateGroceryList('list-id', updatedList);
```

### Delete List
```dart
await apiService.deleteGroceryList('list-id');
```

## Error Handling

The API service includes built-in error handling:

- Network timeouts (30 seconds)
- HTTP error status codes
- Connection errors
- JSON parsing errors

Example:
```dart
try {
  final lists = await apiService.fetchGroceryLists();
  // Success
} catch (e) {
  // Handle error
  print('Error: $e');
  // Show error message to user
}
```

## Authentication (Optional)

If your backend requires authentication, update the headers in `api_service.dart`:

```dart
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer YOUR_TOKEN_HERE',
},
```

## Testing Without Backend

To test the UI without a backend, you can keep using the sample data in the original `ListSection` widget, or create mock data:

```dart
// Mock data for testing
final mockLists = [
  GroceryList(
    id: '1',
    name: 'Weekly Groceries',
    items: '12 of 20',
    progress: 0.6,
    time: '2H AGO',
    icon: Icons.shopping_cart_outlined,
  ),
  // ... more mock lists
];
```

## Next Steps

1. Set up your backend API endpoint
2. Update the `baseUrl` in `api_service.dart`
3. Test the API integration
4. Add authentication if needed
5. Implement create/update/delete functionality
6. Add pull-to-refresh functionality
7. Add offline caching if needed
