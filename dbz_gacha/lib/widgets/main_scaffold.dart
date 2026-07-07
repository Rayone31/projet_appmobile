import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../services/dbz_api.dart';

class MainScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final DbzApi api = DbzApi();
  String? randomPersoImage;

  @override
  void initState() {
    super.initState();
    _loadRandomPerso();
  }

  Future<void> _loadRandomPerso() async {
    try {
      final data = await api.getAllCharacters();
      if (data.isNotEmpty && mounted) {
        final random = Random();
        setState(() {
          randomPersoImage = data[random.nextInt(data.length)].image;
        });
      }
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: _CustomNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        randomPersoImage: randomPersoImage,
        onTap: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final String? randomPersoImage;
  final ValueChanged<int> onTap;

  const _CustomNavBar({
    required this.currentIndex,
    required this.randomPersoImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavCircleItem(
            label: 'Accueil',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
            child: Image.asset(
              'assets/icon.png',
              fit: BoxFit.contain,
            ),
          ),
          _NavCircleItem(
            label: 'Catalogue',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
            child: randomPersoImage != null
                ? Image.network(
                    randomPersoImage!,
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, color: Colors.white),
                  )
                : const Icon(Icons.person, color: Colors.white),
          ),
          _NavCircleItem(
            label: 'Invocation',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
            child: Image.asset(
              'assets/shenron.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavCircleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _NavCircleItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.orangeAccent : Colors.white38,
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
            child: ClipOval(child: child),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.orangeAccent : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}