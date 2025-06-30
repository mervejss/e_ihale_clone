import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'dasboard/dashboard_screen.dart';

class DiscoverBrandsScreen extends StatelessWidget {
  const DiscoverBrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<BrandItem> brandItems = [
      BrandItem(
        title: 'Teklifin Gelsin',
        description: 'Elektronik ürünler için hızlı, şeffaf ve güvenli ihale deneyimi.',
        imagePath: 'assets/images/logo_teklifingelsin.jpg',
        isAvailable: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        ),
      ),
      BrandItem(
        title: 'Yakında!',
        description: 'Yeni markalar çok yakında burada olacak.',
        imagePath: 'assets/images/logo_placeholder.jpg',
        isAvailable: false,
      ),
      BrandItem(
        title: 'Yakında!',
        description: 'Yeni markalar çok yakında burada olacak.',
        imagePath: 'assets/images/logo_placeholder.jpg',
        isAvailable: false,
      ),
      BrandItem(
        title: 'Yakında!',
        description: 'Yeni markalar çok yakında burada olacak.',
        imagePath: 'assets/images/logo_placeholder.jpg',
        isAvailable: false,
      ),
      BrandItem(
        title: 'Yakında!',
        description: 'Yeni markalar çok yakında burada olacak.',
        imagePath: 'assets/images/logo_placeholder.jpg',
        isAvailable: false,
      ),
      BrandItem(
        title: 'Yakında!',
        description: 'Yeni markalar çok yakında burada olacak.',
        imagePath: 'assets/images/logo_placeholder.jpg',
        isAvailable: false,
      ),
      BrandItem(
        title: 'Yakında!',
        description: 'Yeni markalar çok yakında burada olacak.',
        imagePath: 'assets/images/logo_placeholder.jpg',
        isAvailable: false,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MARKALARI KEŞFET',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      text: '',
                      children: <TextSpan>[
                        TextSpan(text: 'Elektronik ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'ürünlerde en '),
                        TextSpan(text: 'iyi ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'teklifleri almak için\n'),
                        TextSpan(text: '"Teklifin Gelsin" ', style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.primaryColor)),
                        TextSpan(text: 'ile ihale fırsatları yakalayın. Aynı zamanda '),
                        TextSpan(text: 'favori markaları ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'keşfedin ve en '),
                        TextSpan(text: 'iyi ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'ürünlere '),
                        TextSpan(text: 'hızlıca ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'ulaşın!'),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 75),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  itemCount: brandItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final item = brandItems[index];

                    return GestureDetector(
                      onTap: () {
                        if (item.isAvailable) {
                          item.onTap?.call();
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Yakında!'),
                                content: const Text('Bu marka çok yakında eklenecek.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Tamam'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                          border: Border.all(
                            color: item.title == 'Teklifin Gelsin'
                                ? Colors.blue
                                : Colors.grey.shade300,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Image.asset(
                                item.imagePath,
                                height: 50,
                                width: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandItem {
  final String title;
  final String description;
  final String imagePath;
  final bool isAvailable;
  final VoidCallback? onTap;

  BrandItem({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isAvailable = false,
    this.onTap,
  });
}