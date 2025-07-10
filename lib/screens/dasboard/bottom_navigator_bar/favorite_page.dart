import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../utils/colors.dart';
import '../../../../services/firestore_service.dart';
import 'auctions/auctions_pages/widgets/simple_auction_card.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<String>> _favoritesFuture;
  final List<String> tabs = ['Telefon', 'Bilgisayar', 'Aksesuar', 'Anakart', 'Teknik parça'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: tabs.length, vsync: this);
    _favoritesFuture = _fetchFavorites();

    _tabController.addListener(() {
      _scrollToSelected();
      setState(() {});
    });
  }

  Future<List<String>> _fetchFavorites() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      return await _firestoreService.getFavoriteAuctions(userId);
    }
    return [];
  }

  void _scrollToSelected() {
    double offset = 0.0;
    for (int i = 0; i < _tabController.index; i++) {
      offset += _getTabWidth(i);
    }
    double selectedWidth = _getTabWidth(_tabController.index);
    final screenWidth = MediaQuery.of(context).size.width;
    _scrollController.animateTo(
      offset - (screenWidth / 2) + (selectedWidth / 2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  double _getTabWidth(int index) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: tabs[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.size.width + 28;
  }

  Widget _buildTabBar() {
    return Container(
      height: 55,
      color: AppColors.primaryColor,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 0),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final bool isSelected = _tabController.index == index;
            return GestureDetector(
              onTap: () => _tabController.animateTo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                      : [],
                  border: Border.all(
                    color: isSelected ? AppColors.secondaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryColor : AppColors.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 18 : 14,
                    ),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Bir hata oluştu.'));
        } else {
          final favoriteAuctionIds = snapshot.data ?? [];
          return DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              backgroundColor: AppColors.secondaryColor,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(55),
                child: _buildTabBar(),
              ),
              body: TabBarView(
                controller: _tabController,
                children: tabs.map((category) {
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: _firestoreService.getAuctionsByCategory(category),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Bir hata oluştu.'));
                      } else {
                        final auctions = snapshot.data?.where((auction) => favoriteAuctionIds.contains(auction['id'])).toList() ?? [];
                        return auctions.isEmpty
                            ? const Center(child: Text('Bu kategoride favori ihale yok.'))
                            : ListView.builder(
                          padding: const EdgeInsets.all(16),

                          itemCount: auctions.length,
                          itemBuilder: (context, index) {
                            final auction = auctions[index];
                            return SimpleAuctionCard(auction: auction);
                          },
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }
}