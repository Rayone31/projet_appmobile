import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_background.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("HOME"),
              ElevatedButton(
                onPressed: () => context.go('/catalogue'),
                child: const Text("Catalogue"),
              ),
              ElevatedButton(
                onPressed: () => context.go('/invocation'),
                child: const Text("Invocation"),
              ),
              ElevatedButton(
                onPressed: () => context.go('/info_personnage'),
                child: const Text("Info personnage"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}