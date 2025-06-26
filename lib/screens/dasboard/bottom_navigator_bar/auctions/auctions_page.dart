import 'package:flutter/material.dart';

class AuctionsPage extends StatefulWidget {
  const AuctionsPage({super.key});

  @override
  State<AuctionsPage> createState() => _AuctionsPageState();
}

class _AuctionsPageState extends State<AuctionsPage> with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color(0xFF1e529b);
  late TabController _tabController;
  late ScrollController _scrollController;

  final List<String> tabs = [
    'Telefon',
    'Bilgisayar',
    'Aksesuar',
    'Anakart',
    'Teknik parça',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      _scrollToSelected();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      color: primaryColor,
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
                  color: isSelected ? Colors.white : Colors.transparent,
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
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isSelected ? primaryColor : Colors.white,
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: _buildTabBar(),
        ),
        body: TabBarView(
          controller: _tabController,
          children: tabs.map((label) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: Center(
                key: ValueKey(label),
                child: Text(
                  '$label İhaleleri',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}