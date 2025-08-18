import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/article.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await initDB();
    return _database!;
  }

  /// Initialize the database
  Future<Database> initDB() async {
    // Get the application documents directory
    String path = join(await getDatabasesPath(), 'news.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create the database tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saved_articles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT,
        description TEXT,
        url TEXT NOT NULL UNIQUE,
        urlToImage TEXT,
        publishedAt TEXT,
        content TEXT,
        source TEXT,
        savedAt TEXT NOT NULL
      )
    ''');
  }

  /// Save an article to the database
  Future<int> saveArticle(Article article) async {
    final db = await database;
    
    try {
      final Map<String, dynamic> articleMap = {
        'title': article.title,
        'author': article.author,
        'description': article.description,
        'url': article.url,
        'urlToImage': article.urlToImage,
        'publishedAt': article.publishedAt?.toIso8601String(),
        'content': article.content,
        'source': article.source,
        'savedAt': DateTime.now().toIso8601String(),
      };
      
      return await db.insert(
        'saved_articles',
        articleMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving article: $e');
      return -1;
    }
  }

  /// Get all saved articles from the database
  Future<List<Article>> getSavedArticles() async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'saved_articles',
        orderBy: 'savedAt DESC', // Most recently saved first
      );

      return List.generate(maps.length, (i) {
        return Article(
          title: maps[i]['title'] ?? 'No Title',
          author: maps[i]['author'],
          description: maps[i]['description'],
          url: maps[i]['url'] ?? '',
          urlToImage: maps[i]['urlToImage'],
          publishedAt: maps[i]['publishedAt'] != null 
              ? DateTime.parse(maps[i]['publishedAt'])
              : null,
          content: maps[i]['content'],
          source: maps[i]['source'],
        );
      });
    } catch (e) {
      print('Error retrieving saved articles: $e');
      return [];
    }
  }

  /// Check if an article is already saved
  Future<bool> isArticleSaved(String url) async {
    final db = await database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'saved_articles',
        where: 'url = ?',
        whereArgs: [url],
        limit: 1,
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking if article is saved: $e');
      return false;
    }
  }

  /// Remove a saved article from the database
  Future<int> removeSavedArticle(String url) async {
    final db = await database;
    
    try {
      return await db.delete(
        'saved_articles',
        where: 'url = ?',
        whereArgs: [url],
      );
    } catch (e) {
      print('Error removing saved article: $e');
      return 0;
    }
  }

  /// Get the count of saved articles
  Future<int> getSavedArticlesCount() async {
    final db = await database;
    
    try {
      final result = await db.rawQuery('SELECT COUNT(*) FROM saved_articles');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting saved articles count: $e');
      return 0;
    }
  }

  /// Clear all saved articles
  Future<int> clearAllSavedArticles() async {
    final db = await database;
    
    try {
      return await db.delete('saved_articles');
    } catch (e) {
      print('Error clearing saved articles: $e');
      return 0;
    }
  }

  /// Close the database
  Future<void> closeDB() async {
    final db = await database;
    await db.close();
  }
}
