import 'package:flutter/material.dart';
import '../../../../../../utils/colors.dart';

class PhotoViewPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const PhotoViewPage({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPage = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousImage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextImage() {
    if (_currentPage < widget.images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        title: const Text('Fotoğraf Görüntüleyici'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.all(10), // Dış boşluk
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor, // App ana rengi
                      width: 5,
                    ),
                    borderRadius: BorderRadius.circular(10), // Hafif oval köşe
                    color: Colors.black, // Arka plan (gerekirse)
                  ),
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8), // Foto köşeleri de yuvarlak
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),


          // Geri butonu sadece ilk foto değilse görünür
          if (widget.images.length > 1 && _currentPage > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 32, color: Colors.white70),
                onPressed: _previousImage,
              ),
            ),

          // İleri butonu sadece son foto değilse görünür
          if (widget.images.length > 1 && _currentPage < widget.images.length - 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 32, color: Colors.white70),
                onPressed: _nextImage,
              ),
            ),

          // Alt Slider noktaları
          if (widget.images.length > 1)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 14 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

          // Alt bilgi metni
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '[${_currentPage + 1} / ${widget.images.length}]',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
