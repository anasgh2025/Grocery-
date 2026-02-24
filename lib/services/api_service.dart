import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/grocery_list.dart';

/// Service for handling API calls related to grocery lists
class ApiService {
  // API host selection strategy
  // Priority (highest → lowest):
  // 1. Dart-define override: --dart-define=API_HOST=host:port
  // 2. Platform-specific defaults:
  //    - Android emulator: 10.0.2.2:3000
  //    - iOS: prefer mDNS hostname (e.g. my-mac.local:3000) if available, otherwise localhost:3000
  //    - Web / fallback: localhost:3000
  // This avoids hard-coded LAN IPs in source and supports physical devices via mDNS or explicit override.
  static const String _envHost = String.fromEnvironment('API_HOST', defaultValue: '');
  static const int _port = 3000;

  // Secure storage for auth token
  static const _tokenKey = 'auth_token';
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static String get _hostPort {
    // Explicit override via --dart-define takes precedence.
    if (_envHost.isNotEmpty) return _envHost;

    // Web apps run on the browser; backend is expected to be localhost in dev.
    if (kIsWeb) return 'localhost:$_port';

    try {
      if (Platform.isAndroid) {
        // Android emulator maps host localhost to 10.0.2.2
        return '10.0.2.2:$_port';
      }

      if (Platform.isIOS || Platform.isMacOS) {
        // Prefer an mDNS-style hostname (LocalHostName.local) so physical devices
        // on the same network can resolve the dev machine without editing source.
        final hostname = Platform.localHostname;
        if (hostname.isNotEmpty) {
          final mdns = hostname.endsWith('.local') ? hostname : '$hostname.local';
          return '$mdns:$_port';
        }
        // Fallback to localhost (works for the iOS simulator)
        return 'localhost:$_port';
      }
    } catch (_) {
      // Platform may be unavailable in some environments; fall back below.
    }

    // Default fallback
    return 'localhost:$_port';
  }

  static String get baseUrl => 'http://$_hostPort/api';

  // Timeout duration for API calls
  static const Duration timeout = Duration(seconds: 30);

  /// Whether a user is currently authenticated.
  ///
  /// This app currently doesn't have an auth flow; return false by default.
  /// When an authentication system is added, update this implementation.
  bool get isLoggedIn => false;

  /// Save auth token to secure storage
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Clear auth token from secure storage
  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Read auth token from secure storage
  Future<String?> readToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Fetch all grocery lists from the backend
  Future<List<GroceryList>> fetchGroceryLists() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/lists'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => GroceryList.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Lists not found');
      } else {
        throw Exception('Failed to load lists: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout: Please check your internet connection');
      }
      throw Exception('Error fetching lists: $e');
    }
  }

  /// Fetch a single grocery list by ID
  Future<GroceryList> fetchGroceryListById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/lists/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return GroceryList.fromJson(jsonData);
      } else {
        throw Exception('Failed to load list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching list: $e');
    }
  }

  /// Fetch items for a list
  Future<List<dynamic>> fetchListItems(String listId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/lists/$listId/items'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData;
      }
      throw Exception('Failed to load list items: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching list items: $e');
    }
  }

  /// Add an item to a list
  Future<Map<String, dynamic>> addListItem(String listId, Map<String, dynamic> item) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/lists/$listId/items'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(item),
          )
          .timeout(timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to create item: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating item: $e');
    }
  }

  /// Update an item
  Future<Map<String, dynamic>> updateListItem(String listId, String itemId, Map<String, dynamic> item) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/lists/$listId/items/$itemId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(item),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to update item: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error updating item: $e');
    }
  }

  /// Delete an item
  Future<void> deleteListItem(String listId, String itemId) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/lists/$listId/items/$itemId'))
          .timeout(timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting item: $e');
    }
  }

  /// Create a new grocery list
  Future<GroceryList> createGroceryList(GroceryList list) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/lists'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(list.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return GroceryList.fromJson(jsonData);
      } else {
        throw Exception('Failed to create list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating list: $e');
    }
  }

  /// Create a new user/profile on the backend
  Future<Map<String, dynamic>> createUser({required String name, required String email, required String password}) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/users'), headers: {'Content-Type': 'application/json'}, body: json.encode({'name': name, 'email': email, 'password': password}))
          .timeout(timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 409) {
        throw Exception('A user with this email already exists');
      }
      throw Exception('Failed to create user: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  /// Log in a user. Returns a map containing `token` and `user` on success.
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/users/login'), headers: {'Content-Type': 'application/json'}, body: json.encode({'email': email, 'password': password}))
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      }
      throw Exception('Failed to login: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  /// Update an existing grocery list
  Future<GroceryList> updateGroceryList(String id, GroceryList list) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/lists/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(list.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return GroceryList.fromJson(jsonData);
      } else {
        throw Exception('Failed to update list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating list: $e');
    }
  }

  /// Delete a grocery list
  Future<void> deleteGroceryList(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/lists/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting list: $e');
    }
  }
}
