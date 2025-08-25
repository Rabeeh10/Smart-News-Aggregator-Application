import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../helpers/database_helper.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  bool _isSpeaking = false;
  bool _isPaused = false;
  bool _isSaved = false;
  bool _isLoading = false;
  bool _isTtsAvailable = false;
  String _speechText = '';

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _checkIfArticleIsSaved();
    _prepareSpeechText();
  }

  @override
  void dispose() {
    // Safely stop TTS if it's running
    try {
      _flutterTts.stop();
    } catch (e) {
      print('Error stopping TTS during dispose: $e');
    }
    super.dispose();
  }

  Future<void> _initializeTts() async {
    try {
      // Check if TTS is available on the platform
      bool isAvailable = await _flutterTts.isLanguageAvailable("en-US");
      if (!isAvailable) {
        print('TTS: English language not available');
        setState(() {
          _isTtsAvailable = false;
        });
        return;
      }

      // Set language
      await _flutterTts.setLanguage("en-US");
      
      // Set speech rate (0.0 to 1.0)
      await _flutterTts.setSpeechRate(0.5);
      
      // Set volume (0.0 to 1.0)
      await _flutterTts.setVolume(0.8);
      
      // Set pitch (0.5 to 2.0)
      await _flutterTts.setPitch(1.0);

      // Set up event listeners
      _flutterTts.setStartHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = true;
            _isPaused = false;
          });
        }
      });

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _isPaused = false;
          });
        }
      });

      _flutterTts.setCancelHandler(() {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _isPaused = false;
          });
        }
      });

      _flutterTts.setPauseHandler(() {
        if (mounted) {
          setState(() {
            _isPaused = true;
          });
        }
      });

      _flutterTts.setContinueHandler(() {
        if (mounted) {
          setState(() {
            _isPaused = false;
          });
        }
      });

      setState(() {
        _isTtsAvailable = true;
      });
      
      print('TTS initialized successfully');
    } catch (e) {
      print('TTS initialization error: $e');
      setState(() {
        _isTtsAvailable = false;
      });
      // Show user-friendly message if TTS is not available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text-to-speech is not available on this device'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _prepareSpeechText() {
    // Combine title, description, and content for TTS
    String text = '';
    
    text += widget.article.title;
    
    if (widget.article.author != null && widget.article.author!.isNotEmpty) {
      text += '. By ${widget.article.author}.';
    }
    
    if (widget.article.description != null && widget.article.description!.isNotEmpty) {
      text += ' ${widget.article.description}';
    }
    
    if (widget.article.content != null && widget.article.content!.isNotEmpty) {
      // Remove common patterns that interfere with TTS
      String content = widget.article.content!
          .replaceAll(RegExp(r'\[.*?\]'), '') // Remove [+123 chars] type text
          .replaceAll(RegExp(r'http[s]?://[^\s]+'), '') // Remove URLs
          .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
          .replaceAll('...', '. ') // Replace ellipsis with period for better speech
          .trim();
      
      if (content.isNotEmpty && content != widget.article.description) {
        text += ' $content';
      }
    }
    
    // Clean up the text for better TTS experience
    text = text
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'["""]'), '"') // Normalize quotes
        .replaceAll(RegExp(r"[''']"), "'") // Normalize apostrophes
        .trim();
    
    // If text is too short, provide feedback
    if (text.isEmpty) {
      text = 'No content available to read for this article.';
    }
    
    _speechText = text;
  }

  Future<void> _speak() async {
    try {
      if (_speechText.isNotEmpty) {
        await _flutterTts.speak(_speechText);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No content available to read')),
          );
        }
      }
    } catch (e) {
      print('Speech error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text-to-speech is not available on this device'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _pauseResume() async {
    try {
      if (_isPaused) {
        await _flutterTts.speak(_speechText);
      } else {
        await _flutterTts.pause();
      }
    } catch (e) {
      print('Pause/Resume error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pause/Resume not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Stop error: $e');
      // Silently handle stop errors, but reset state
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
        });
      }
    }
  }

  Future<void> _checkIfArticleIsSaved() async {
    try {
      final isSaved = await _databaseHelper.isArticleSaved(widget.article.url);
      setState(() {
        _isSaved = isSaved;
      });
    } catch (e) {
      print('Error checking if article is saved: $e');
    }
  }

  Future<void> _toggleSaveArticle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSaved) {
        final result = await _databaseHelper.removeSavedArticle(widget.article.url);
        if (result > 0) {
          setState(() {
            _isSaved = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article removed from saved articles')),
          );
        }
      } else {
        final result = await _databaseHelper.saveArticle(widget.article);
        if (result > 0) {
          setState(() {
            _isSaved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article saved successfully!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(widget.article.url);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch ${widget.article.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _toggleSaveArticle,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? Colors.yellow : Colors.white,
                  ),
          ),
          IconButton(
            onPressed: _launchUrl,
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in browser',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image
            if (widget.article.hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.article.urlToImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Icon(
                  Icons.article,
                  size: 80,
                  color: Colors.blue.shade400,
                ),
              ),

            const SizedBox(height: 16),

            // Article Title
            Text(
              widget.article.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // Article Metadata
            Row(
              children: [
                if (widget.article.source != null) ...[
                  Icon(Icons.source, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Text(
                    widget.article.source!,
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  widget.article.formattedDate,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            if (widget.article.author != null && widget.article.author!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'By ${widget.article.author}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Audio Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.headphones, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Listen to Article',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isTtsAvailable && !_isSpeaking ? _speak : null,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(_isTtsAvailable ? 'Listen' : 'TTS Unavailable'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTtsAvailable ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isTtsAvailable && _isSpeaking ? _pauseResume : null,
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(_isPaused ? 'Resume' : 'Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTtsAvailable ? Colors.orange : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isTtsAvailable && (_isSpeaking || _isPaused) ? _stop : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTtsAvailable ? Colors.red : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_isSpeaking || _isPaused) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      backgroundColor: Colors.blue.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isPaused ? 'Paused' : 'Playing...',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Article Description
            if (widget.article.description != null && widget.article.description!.isNotEmpty) ...[
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.article.description!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Article Content
            if (widget.article.content != null && widget.article.content!.isNotEmpty) ...[
              Text(
                'Full Article',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.article.content!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey[600],
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Full article content not available',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the browser icon above to read the full article online',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
