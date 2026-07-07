import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';

import '../models/perso.dart';
import '../services/dbz_api.dart';
import '../services/collection_service.dart';
import '../services/cooldown_service.dart';
import '../widgets/perso_card.dart';
import '../widgets/app_background.dart';

class Invocation extends StatefulWidget {
  const Invocation({super.key});

  @override
  State<Invocation> createState() => _InvocationState();
}

class _InvocationState extends State<Invocation> {
  final DbzApi api = DbzApi();
  final CollectionService collectionService = CollectionService();
  final CooldownService cooldownService = CooldownService();
  final Random random = Random();

  List<Perso> allPersos = [];
  bool isLoading = true;
  bool isInvoking = false;

  Duration remainingCooldown = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    loadPersos();
    _startCooldownTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> loadPersos() async {
    try {
      final data = await api.getAllCharacters();
      setState(() {
        allPersos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _startCooldownTimer() {
    _updateCooldown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCooldown();
    });
  }

  Future<void> _updateCooldown() async {
    final remaining = await cooldownService.getRemainingCooldown();
    if (mounted) {
      setState(() {
        remainingCooldown = remaining;
      });
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> invoke() async {
    if (allPersos.isEmpty || remainingCooldown > Duration.zero) return;

    setState(() {
      isInvoking = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final tirage = allPersos[random.nextInt(allPersos.length)];
    await collectionService.unlockPerso(tirage.id);

    try {
      await cooldownService.saveInvocationTime();
    } catch (e) {
      debugPrint('Erreur notification/cooldown: $e');
    }

    await _updateCooldown();

    setState(() {
      isInvoking = false;
    });

    if (!mounted) return;
    _showResultDialog(tirage);
  }

  void _showResultDialog(Perso perso) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Nouvelle invocation !",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 160,
                  height: 220,
                  child: PersoCard(
                    perso: perso,
                    isUnlocked: true,
                    onTap: null,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text("Fermer"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.push('/info_personnage', extra: perso);
                      },
                      child: const Text("Voir le perso"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final onCooldown = remainingCooldown > Duration.zero;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Invocation"),
        backgroundColor: Colors.transparent,
      ),
      body: AppBackground(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        onCooldown
                            ? 'Prochaine invocation dans : ${_formatDuration(remainingCooldown)}'
                            : 'Invocation disponible !',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: onCooldown
                              ? Colors.grey[700]
                              : Colors.green[700],
                        ),
                      ),
                    ),
                    if (isInvoking)
                      const CircularProgressIndicator()
                    else
                      const Icon(
                        Icons.help_outline,
                        size: 100,
                        color: Colors.grey,
                      ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: (isInvoking || onCooldown) ? null : invoke,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text(
                        "Invocation",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}