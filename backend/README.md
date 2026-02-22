# Grocery App Backend

Node.js/Express REST API backend for the Grocery App.

## Features

- RESTful API for grocery list management
- In-memory data storage (can be upgraded to database)
- CORS enabled for Flutter app integration
- Request logging
- Error handling
- Sample data included

## Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

## Running the Server

### Development Mode (with auto-reload):
```bash
npm run dev
```

### Production Mode:
```bash
npm start
```

The server will start on `http://localhost:3000` (or the PORT specified in `.env`)

## API Endpoints

### Base URL
```
http://localhost:3000/api
```

### Health Check
```http
GET /api/health
```
Returns server status and timestamp.

### Lists

#### Get All Lists
```http
GET /api/lists
```
Returns array of all grocery lists.

**Response:**
```json
[
  {
    "id": "1",
    "name": "Weekly Groceries",
    "items": "12/20",
    "progress": 0.6,
    "time": "Due Tomorrow",
    "icon": "shopping_cart"
  },
  ...
]
```

#### Get Single List
```http
GET /api/lists/:id
```
Returns a single list by ID.

**Response:**
```json
{
  "id": "1",
  "name": "Weekly Groceries",
  "items": "12/20",
  "progress": 0.6,
  "time": "Due Tomorrow",
  "icon": "shopping_cart"
}
```

#### Create New List
```http
POST /api/lists
Content-Type: application/json

{
  "name": "New List",
  "items": "0/10",
  "progress": 0.0,
  "time": "Due in 1 week",
  "icon": "shopping_cart"
}
```

**Response:** (201 Created)
```json
{
  "id": "generated-uuid",
  "name": "New List",
  "items": "0/10",
  "progress": 0.0,
  "time": "Due in 1 week",
  "icon": "shopping_cart"
}
```

#### Update List
```http
PUT /api/lists/:id
Content-Type: application/json

{
  "name": "Updated List Name",
  "items": "5/10",
  "progress": 0.5,
  "time": "Due Tomorrow",
  "icon": "celebration"
}
```

**Response:**
```json
{
  "id": "1",
  "name": "Updated List Name",
  "items": "5/10",
  "progress": 0.5,
  "time": "Due Tomorrow",
  "icon": "celebration"
}
```

#### Delete List
```http
DELETE /api/lists/:id
```

**Response:** 204 No Content

## Icon Names

Available icon names for the `icon` field:
- `shopping_cart`
- `celebration`
- `breakfast`
- `cleaning`
- `apple`
- `inventory`
- `child_care`
- `pets`
- `list` (default)

## Data Format

### List Object
```json
{
  "id": "string (UUID)",
  "name": "string",
  "items": "string (format: completed/total)",
  "progress": "number (0.0 to 1.0)",
  "time": "string",
  "icon": "string (icon name)"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "error": "Bad Request",
  "message": "Missing required fields: name, items, progress, time, icon"
}
```

### 404 Not Found
```json
{
  "error": "Not Found",
  "message": "List with ID abc123 not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal Server Error",
  "message": "Error details"
}
```

## Testing the API

### Using curl

Get all lists:
```bash
curl http://localhost:3000/api/lists
```

Get single list:
```bash
curl http://localhost:3000/api/lists/1
```

Create new list:
```bash
curl -X POST http://localhost:3000/api/lists \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test List",
    "items": "0/5",
    "progress": 0.0,
    "time": "Due Today",
    "icon": "shopping_cart"
  }'
```

Update list:
```bash
curl -X PUT http://localhost:3000/api/lists/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated List",
    "progress": 0.8
  }'
```

Delete list:
```bash
curl -X DELETE http://localhost:3000/api/lists/1
```

## Connecting to Flutter App

Update the `baseUrl` in your Flutter app's `api_service.dart`:

```dart
class ApiService {
  // For iOS Simulator
  static const String baseUrl = 'http://localhost:3000/api';
  
  // For Android Emulator (use this instead)
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // For Physical Device (use your computer's IP address)
  // static const String baseUrl = 'http://192.168.1.XXX:3000/api';
  
  // ...
}
```

## Project Structure

```
backend/
├── server.js              # Main Express app
├── package.json           # Dependencies
├── .env                   # Environment variables
├── routes/
│   └── lists.js          # API routes
├── controllers/
│   └── listsController.js # Business logic
└── data/
    └── store.js          # In-memory data storage
```

## Future Enhancements

- [ ] Database integration (MongoDB/PostgreSQL)
- [ ] Authentication/Authorization
- [ ] Input validation middleware
- [ ] Rate limiting
- [ ] API documentation with Swagger
- [ ] Unit tests
- [ ] Deployment configuration

## Environment Variables

Create a `.env` file with:

```env
PORT=3000
NODE_ENV=development
```

## License

MIT
