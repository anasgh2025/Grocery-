import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/grocery_list.dart';

/// Service for handling API calls related to grocery lists
class ApiService {
  // ── Production backend on DigitalOcean App Platform ──
  // Override at build-time with: --dart-define=API_BASE_URL=https://your-url.com/api
  static const String _prodBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://coral-app-qjq4a.ondigitalocean.app/api',
  );

  // Secure storage for auth token
  static const _tokenKey = 'auth_token';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static String get baseUrl => _prodBaseUrl;

  // Timeout duration for API calls
  static const Duration timeout = Duration(seconds: 30);

  /// Whether a user is currently authenticated.
  ///
  /// Checks secure storage for a saved JWT token.
  Future<bool> get isLoggedIn async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

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

  // Log response for debugging
  debugPrint('[ApiService] GET $baseUrl/lists status: ${response.statusCode}');
  debugPrint('[ApiService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => GroceryList.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        debugPrint('[ApiService] Unauthorized: Please login again');
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        debugPrint('[ApiService] Lists not found');
        throw Exception('Lists not found');
      } else {
        debugPrint('[ApiService] Failed to load lists: ${response.statusCode}');
        throw Exception('Failed to load lists: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ApiService] Error fetching lists: $e');
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
      } else if (response.statusCode == 409) {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'A list with this name already exists');
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

  // ─── Categories ────────────────────────────────────────────────────────

  /// Fetch all categories (summary: id, label, icon, order, itemCount).
  /// Pass [full] = true to include the items array for each category.
  Future<List<Map<String, dynamic>>> fetchCategories({bool full = false, String? lang}) async {
    try {
      final params = <String>[];
      if (full) params.add('full=true');
      if (lang != null) params.add('lang=$lang');
      final query = params.isNotEmpty ? '?${params.join('&')}' : '';
      final uri = Uri.parse('$baseUrl/categories$query');
      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.cast<Map<String, dynamic>>();
      }
      throw Exception('Failed to load categories: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Fetch a single category by label (includes items).
  Future<Map<String, dynamic>> fetchCategoryByLabel(String label) async {
    try {
      debugPrint('[DEBUG] fetchCategoryByLabel: label sent = "$label"');
      final encoded = Uri.encodeComponent(label);
      final url = '$baseUrl/categories/label/$encoded';
      debugPrint('[DEBUG] fetchCategoryByLabel: url = $url');
      final response = await http
          .get(Uri.parse(url))
          .timeout(timeout);
      debugPrint('[DEBUG] fetchCategoryByLabel: status = ${response.statusCode}');
      debugPrint('[DEBUG] fetchCategoryByLabel: body = ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to load category: ${response.statusCode}');
    } catch (e) {
      debugPrint('[DEBUG] fetchCategoryByLabel: error = $e');
      throw Exception('Error fetching category "$label": $e');
    }
  }
}
