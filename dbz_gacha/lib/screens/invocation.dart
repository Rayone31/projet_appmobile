import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';

import '../models/perso.dart';
import '../services/dbz_api.dart';
import '../services/collection.dart';
import '../services/cooldown.dart';
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
          "Invocation",
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
            : Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Center(
                          child: isInvoking
                              ? const CircularProgressIndicator()
                              : Image.asset(
                                  'assets/shenron.png',
                                  height: 380,
                                  fit: BoxFit.contain,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Image.asset(
                            'assets/ball7.png',
                            height: 110,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GestureDetector(
                      onTap: (isInvoking || onCooldown) ? null : invoke,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: (isInvoking || onCooldown)
                              ? LinearGradient(
                                  colors: [Colors.grey[600]!, Colors.grey[800]!],
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFFFFC107), Color(0xFFFF6F00)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: (isInvoking || onCooldown)
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFFFF6F00).withOpacity(0.5),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          onCooldown ? _formatDuration(remainingCooldown) : "INVOCATION",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}