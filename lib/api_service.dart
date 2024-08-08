import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchInfo() async {
    final url = Uri.parse('$baseUrl/info');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Ensure the response is UTF-8 encoded
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load info: ${response.statusCode}');
      }
    } catch (e) {
      // Print more detailed exception information
      print('Error fetching info: $e');
      throw Exception('Failed to load info: $e');
    }
  }

  Future<Map<String, dynamic>> fetchData() async {
    final url = Uri.parse('$baseUrl/data');
    print(url);
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print(response.statusCode);
      if (response.statusCode == 200) {
        // Ensure the response is UTF-8 encoded
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Print more detailed exception information
      print('Error fetching data: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCategories({
    String? category,
    String? month,
    String? name,
  }) async {
    // Build query parameters
    final queryParameters = <String, String>{};
    if (category != null && category.isNotEmpty) queryParameters['category'] = category;
    if (month != null && month.isNotEmpty) queryParameters['month'] = month;
    if (name != null && name.isNotEmpty) queryParameters['name'] = name;

    final uri = Uri.parse('$baseUrl/filter').replace(queryParameters: queryParameters);
    
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Ensure the response is UTF-8 encoded
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      // Print more detailed exception information
      print('Error fetching categories: $e');
      throw Exception('Failed to load categories: $e');
    }
  }
}
