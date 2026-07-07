import 'package:flutter/material.dart';
import '../models/perso.dart';

class PersoCard extends StatelessWidget {
  final Perso perso;
  final VoidCallback? onTap;
  final bool isUnlocked;

  const PersoCard({
    super.key,
    required this.perso,
    required this.isUnlocked,
    this.onTap,
  });

  String get _backgroundAsset {
    const totalFonds = 8;
    final index = (perso.name.hashCode.abs() % totalFonds) + 1;
    return 'assets/fond$index.jpeg';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              clipBehavior: Clip.none,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipPath(
                    clipper: _CornerCutClipper(cutSize: 20),
                    child: isUnlocked
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                _backgroundAsset,
                                fit: BoxFit.cover,
                              ),
                              Image.network(
                                perso.image,
                                fit: BoxFit.contain,
                                alignment: Alignment.topCenter,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image,
                                        size: 40),
                                  );
                                },
                              ),
                            ],
                          )
                        : Container(
                            color: Colors.grey[400],
                            child: const Center(
                              child: Text(
                                '?',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                  ),
                  if (isUnlocked)
                    Positioned(
                      bottom: -8,
                      left: -8,
                      child: Image.asset(
                        'assets/lr_logo.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              isUnlocked ? perso.name : '??????',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerCutClipper extends CustomClipper<Path> {
  final double cutSize;

  _CornerCutClipper({this.cutSize = 20});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(cutSize, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, cutSize);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _CornerCutClipper oldClipper) {
    return oldClipper.cutSize != cutSize;
  }
}