import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/perso.dart';
import '../services/dbz_api.dart';
import '../services/collection.dart';
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.75),
                Colors.black.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: const Text(
          "Catalogue DBZ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black87,
                blurRadius: 6,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        centerTitle: true,
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