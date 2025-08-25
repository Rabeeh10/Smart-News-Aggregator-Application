import 'package:flutter/material.dart';
import 'models/article.dart';
import 'helpers/database_helper.dart';
import 'screens/article_detail_screen.dart';

class EnhancedNewsArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback? onSaveStateChanged;

  const EnhancedNewsArticleCard({
    super.key,
    required this.article,
    this.onSaveStateChanged,
  });

  @override
  State<EnhancedNewsArticleCard> createState() => _EnhancedNewsArticleCardState();
}

class _EnhancedNewsArticleCardState extends State<EnhancedNewsArticleCard> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfArticleIsSaved();
  }

  Future<void> _checkIfArticleIsSaved() async {
    try {
      final isSaved = await _databaseHelper.isArticleSaved(widget.article.url);
      if (mounted) {
        setState(() {
          _isSaved = isSaved;
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _launchUrl() async {
    // Navigate to article detail screen instead of external browser
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: widget.article),
      ),
    );
  }

  Future<void> _toggleSaveArticle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSaved) {
        // Remove from saved
        print('Removing article from saved: ${widget.article.title}');
        final result = await _databaseHelper.removeSavedArticle(widget.article.url);
        print('Remove result: $result');
        if (result > 0) {
          setState(() {
            _isSaved = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Article removed from saved articles'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add to saved
        print('Saving article: ${widget.article.title}');
        final result = await _databaseHelper.saveArticle(widget.article);
        print('Save result: $result');
        if (result > 0) {
          setState(() {
            _isSaved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Article saved successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // Notify parent widget about save state change
      widget.onSaveStateChanged?.call();
    } catch (e) {
      print('Error in _toggleSaveArticle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: InkWell(
        onTap: _launchUrl,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Image
              if (widget.article.hasImage)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.article.urlToImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Save button overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildSaveButton(),
                    ),
                  ],
                )
              else
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Icon(
                        Icons.article,
                        size: 60,
                        color: Colors.blue.shade400,
                      ),
                    ),
                    // Save button overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildSaveButton(),
                    ),
                  ],
                ),
              
              const SizedBox(height: 12),
              
              // Article Title with save button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Save button for articles without image
                  if (!widget.article.hasImage)
                    _buildSaveButton(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Article Description
              if (widget.article.description != null && widget.article.description!.isNotEmpty)
                Text(
                  widget.article.getTruncatedDescription(150),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 12),
              
              // Article Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Source
                  Expanded(
                    child: Text(
                      widget.article.source ?? 'Unknown Source',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Published Date
                  Text(
                    widget.article.formattedDate,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              // Author (if available)
              if (widget.article.author != null && widget.article.author!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'By ${widget.article.author}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleSaveArticle,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: _isSaved ? Colors.green : Colors.grey[600],
                  size: 20,
                ),
        ),
      ),
    );
  }
}
