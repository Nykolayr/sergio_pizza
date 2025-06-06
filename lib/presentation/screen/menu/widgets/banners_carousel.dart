import 'package:flutter/material.dart';

class BannersCarousel extends StatelessWidget {
  const BannersCarousel({super.key});

  // Список баннеров
  static const List<String> banners = [
    'assets/images/baner1.png',
    'assets/images/baner2.png',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerWidth = screenWidth * 0.9; // 90% от ширины экрана

    return SizedBox(
      height: 120, // Высота баннеров
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < banners.length - 1 ? 12 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                // Пока ничего не делаем при нажатии
                print('Нажат баннер ${index + 1}');
              },
              child: Container(
                width: bannerWidth, // 90% от ширины экрана
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    banners[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Заглушка если изображение не найдено
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Баннер ${index + 1}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
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
            ),
          );
        },
      ),
    );
  }
}
