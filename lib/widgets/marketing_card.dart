import 'dart:async';
import 'package:flutter/material.dart';
import '../services/marketing_api_service.dart';
import 'box_styles.dart';
import '../models/marketing_card_model.dart' as model;

/// Marketing / hero card widget with carousel (auto-rotates every 5 seconds)
class MarketingCard extends StatefulWidget {
  const MarketingCard({super.key, required this.accent, required this.heroBg, this.height});

  final Color accent;
  final Color heroBg;
  final double? height;

  @override
  State<MarketingCard> createState() => _MarketingCardState();
}

class _MarketingCardState extends State<MarketingCard> {
  final PageController _pageController = PageController();
  final MarketingApiService _apiService = MarketingApiService();
  Timer? _timer;
  int _currentPage = 0;
  List<model.MarketingCard> _marketingCards = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMarketingCards();
  }

  Future<void> _fetchMarketingCards() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final cards = await _apiService.fetchMarketingCards();
      
      setState(() {
        _marketingCards = cards;
        _isLoading = false;
      });

      // Start auto-play after data is loaded
      if (_marketingCards.isNotEmpty) {
        _startAutoPlay();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _marketingCards.isNotEmpty) {
        _currentPage = (_currentPage + 1) % _marketingCards.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: Container(
            decoration: appBoxDecoration(
              context,
              color: widget.heroBg,
              radius: 16,
            ),
          child: Center(
            child: CircularProgressIndicator(
              color: widget.accent,
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null || _marketingCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _marketingCards.length,
        itemBuilder: (context, index) {
          final card = _marketingCards[index];
          return _buildMarketingCard(
            context,
            card: card,
          );
        },
      ),
    );
  }

  Widget _buildMarketingCard(
    BuildContext context, {
    required model.MarketingCard card,
  }) {
    final theme = Theme.of(context);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.heroBg,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bk.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient overlay for better text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.heroBg.withAlpha(179),
                    widget.heroBg.withAlpha(128),
                  ],
                ),
              ),
            ),
          ),
          
          // Text content
          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  card.subtitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: widget.accent,
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Color.fromRGBO(0, 0, 0, 0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}