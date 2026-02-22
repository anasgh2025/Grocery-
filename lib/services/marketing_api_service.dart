import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/marketing_card_model.dart';
import 'api_service.dart';

/// Service for handling API calls related to marketing cards
class MarketingApiService {
  // Use the shared ApiService.baseUrl so marketing calls follow the
  // same host selection strategy (dart-define, emulator mapping, mDNS, localhost).
  static String get baseUrl => ApiService.baseUrl;

  // Timeout duration for API calls
  static const Duration timeout = Duration(seconds: 30);

  /// Fetch all marketing cards from the backend
  Future<List<MarketingCard>> fetchMarketingCards() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/marketing'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => MarketingCard.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Marketing cards not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to load marketing cards: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please check your connection.');
      }
      rethrow;
    }
  }

  /// Fetch a single marketing card by ID
  Future<MarketingCard> fetchMarketingCardById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/marketing/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return MarketingCard.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Marketing card not found');
      } else {
        throw Exception('Failed to load marketing card: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new marketing card
  Future<MarketingCard> createMarketingCard(MarketingCard card) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/marketing'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(card.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        return MarketingCard.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create marketing card: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing marketing card
  Future<MarketingCard> updateMarketingCard(String id, MarketingCard card) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/marketing/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(card.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return MarketingCard.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Marketing card not found');
      } else {
        throw Exception('Failed to update marketing card: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a marketing card
  Future<void> deleteMarketingCard(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/marketing/$id'),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(timeout);

      if (response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Marketing card not found');
      } else {
        throw Exception('Failed to delete marketing card: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
