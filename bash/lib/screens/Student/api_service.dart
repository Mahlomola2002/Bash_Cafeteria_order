import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Fetch all dishes
  static Future<List<Map<String, dynamic>>> getDishes() async {
    final response = await http.get(Uri.parse('$baseUrl/dishes/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load dishes');
  }

  // Rate a dish
  static Future<Map<String, dynamic>> rateDish(
    int dishId,
    String userId,
    int rating,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dishes/$dishId/rate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'rating': rating,
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['average_rating'] == null) {
          throw Exception('Server response missing new average rating');
        }
        return decodedResponse;
      } else if (response.statusCode == 404) {
        throw Exception('Dish not found');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['detail'] ?? 'Failed to rate dish');
      }
    } catch (e) {
      rethrow;
    }
  }

// Optional: Helper method to validate the dish exists before rating
  static Future<bool> checkDishExists(int dishId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dishes/$dishId'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Create an order
  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String customer_name,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    // Generate a timestamp in ISO format
    final timestamp = DateTime.now().toUtc().toIso8601String();

    // Generate a UUID on client side
    final orderId = const Uuid().v4(); // Make sure to import 'uuid' package
    print(customer_name);

    final response = await http.post(
      Uri.parse('$baseUrl/Createorders/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': orderId,
        'userId': userId,
        'status': 'pending',
        'customer_name': customer_name,
        'total': total,
        'timestamp': timestamp,
        'items': items
            .map((item) => {
                  'name': item['name'],
                  'quantity': item['quantity'],
                })
            .toList(),
      }),
    );

    if (response.statusCode == 201) {
      // Changed from 200 to 201 for resource creation
      return json.decode(response.body);
    }
    throw Exception('Failed to create order: ${response.body}');
  }
}
