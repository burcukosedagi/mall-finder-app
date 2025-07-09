import 'package:flutter/material.dart';
import '../models/mall.dart';
import '../pages/mall_detail_page.dart';

class MallCard extends StatelessWidget {
  final Mall mall;

  const MallCard({super.key, required this.mall});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => MallDetailPage(mall: mall),
              transitionsBuilder: (_, animation, __, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mall.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${mall.city ?? '-'} / ${mall.district ?? '-'}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (i) {
                            if (i < mall.rating.floor()) {
                              return const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.orange,
                              );
                            } else if (i < mall.rating) {
                              return const Icon(
                                Icons.star_half,
                                size: 16,
                                color: Colors.orange,
                              );
                            } else {
                              return const Icon(
                                Icons.star_border,
                                size: 16,
                                color: Colors.orange,
                              );
                            }
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mall.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '|',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${mall.commentCount} yorum)',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder: (_, __, ___) => MallDetailPage(mall: mall),
                      transitionsBuilder: (_, animation, __, child) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  backgroundColor: const Color.fromARGB(255, 248, 248, 248),
                ),
                child: const Text(
                  "İncele",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 104, 104, 104),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
