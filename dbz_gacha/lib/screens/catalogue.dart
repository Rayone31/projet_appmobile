import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/perso.dart';
import '../services/dbz_api.dart';
import '../services/collection_service.dart';
import '../widgets/perso_card.dart';
import '../widgets/app_background.dart';

class Catalogue extends StatefulWidget {
  const Catalogue({super.key});

  @override
  State<Catalogue> createState() => _CatalogueState();
}

class _CatalogueState extends State<Catalogue> {
  final DbzApi api = DbzApi();
  final CollectionService collectionService = CollectionService();

  List<Perso> persos = [];
  Set<int> unlockedIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await api.getAllCharacters();
      final unlocked = await collectionService.loadUnlockedIds();

      setState(() {
        persos = data;
        unlockedIds = unlocked;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Catalogue DBZ"),
        backgroundColor: Colors.transparent,
      ),
      body: AppBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: persos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final perso = persos[index];
                  final unlocked = unlockedIds.contains(perso.id);

                  return PersoCard(
                    perso: perso,
                    isUnlocked: unlocked,
                    onTap: () =>
                        context.push('/info_personnage', extra: perso),
                  );
                },
              ),
      ),
    );
  }
}