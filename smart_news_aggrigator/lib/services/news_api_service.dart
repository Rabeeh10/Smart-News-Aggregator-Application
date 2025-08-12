import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsApiService {
  // You need to replace this with your actual NewsAPI key
  // Get your free API key from: https://newsapi.org/register
  static const String _apiKey = 'dc0a19f677f0435aabac792a39fe7c54';
  static const String _baseUrl = 'https://newsapi.org/v2';

  // Fetch top headlines from NewsAPI
  Future<List<Article>> fetchTopHeadlines({
    String country = 'us',
    String? category,
    String? sources,
    String? q,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
      };

      // Add optional parameters
      if (country.isNotEmpty && sources == null) {
        queryParams['country'] = country;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (sources != null && sources.isNotEmpty) {
        queryParams['sources'] = sources;
        queryParams.remove('country'); // Can't use both country and sources
      }
      if (q != null && q.isNotEmpty) {
        queryParams['q'] = q;
      }

      // Build the URL
      final uri = Uri.parse('$_baseUrl/top-headlines').replace(
        queryParameters: queryParams,
      );

      print('Fetching news from: $uri');

      // Make the HTTP GET request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Check if the request was successful
        if (jsonData['status'] == 'ok') {
          final List<dynamic> articlesJson = jsonData['articles'] ?? [];
          
          // Convert JSON articles to Article objects
          final List<Article> articles = articlesJson
              .map((articleJson) => Article.fromJson(articleJson))
              .where((article) => article.title != '[Removed]') // Filter out removed articles
              .toList();

          print('Successfully fetched ${articles.length} articles');
          return articles;
        } else {
          throw Exception('API Error: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your NewsAPI key.');
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to fetch news: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching top headlines: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again.');
      } else {
        rethrow;
      }
    }
  }

  // Fetch everything (all articles) from NewsAPI
  Future<List<Article>> fetchEverything({
    String? q,
    String? sources,
    String? domains,
    String? from,
    String? to,
    String language = 'en',
    String sortBy = 'publishedAt',
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'language': language,
        'sortBy': sortBy,
        'pageSize': pageSize.toString(),
        'page': page.toString(),
      };

      // Add optional parameters
      if (q != null && q.isNotEmpty) {
        queryParams['q'] = q;
      }
      if (sources != null && sources.isNotEmpty) {
        queryParams['sources'] = sources;
      }
      if (domains != null && domains.isNotEmpty) {
        queryParams['domains'] = domains;
      }
      if (from != null && from.isNotEmpty) {
        queryParams['from'] = from;
      }
      if (to != null && to.isNotEmpty) {
        queryParams['to'] = to;
      }

      // Build the URL
      final uri = Uri.parse('$_baseUrl/everything').replace(
        queryParameters: queryParams,
      );

      print('Fetching everything from: $uri');

      // Make the HTTP GET request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Check if the request was successful
        if (jsonData['status'] == 'ok') {
          final List<dynamic> articlesJson = jsonData['articles'] ?? [];
          
          // Convert JSON articles to Article objects
          final List<Article> articles = articlesJson
              .map((articleJson) => Article.fromJson(articleJson))
              .where((article) => article.title != '[Removed]') // Filter out removed articles
              .toList();

          print('Successfully fetched ${articles.length} articles');
          return articles;
        } else {
          throw Exception('API Error: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch news: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching everything: $e');
      rethrow;
    }
  }

  // Get available news sources
  Future<List<Map<String, dynamic>>> fetchSources({
    String? category,
    String? language,
    String? country,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'apiKey': _apiKey,
      };

      // Add optional parameters
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (language != null && language.isNotEmpty) {
        queryParams['language'] = language;
      }
      if (country != null && country.isNotEmpty) {
        queryParams['country'] = country;
      }

      // Build the URL
      final uri = Uri.parse('$_baseUrl/sources').replace(
        queryParameters: queryParams,
      );

      // Make the HTTP GET request
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'ok') {
          final List<dynamic> sourcesJson = jsonData['sources'] ?? [];
          return sourcesJson.cast<Map<String, dynamic>>();
        } else {
          throw Exception('API Error: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to fetch sources: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching sources: $e');
      rethrow;
    }
  }

  // Helper method to validate API key
  bool isApiKeyValid() {
    return _apiKey != 'dc0a19f677f0435aabac792a39fe7c54' && _apiKey.isNotEmpty;
  }

  // Available categories for news
  static const List<String> availableCategories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // Available countries for news
  static const Map<String, String> availableCountries = {
    'us': 'United States',
    'gb': 'United Kingdom',
    'ca': 'Canada',
    'au': 'Australia',
    'in': 'India',
    'de': 'Germany',
    'fr': 'France',
    'jp': 'Japan',
    'cn': 'China',
    'br': 'Brazil',
  };
}
