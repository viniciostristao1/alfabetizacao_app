import 'package:flutter/material.dart';

import '../../models/regiao.dart';
import '../../services/progresso_fases.dart';
import '../../theme/app_colors.dart';
import 'colecao_alimentos_screen.dart';
import 'colecao_nomes_screen.dart';
import 'colecao_objetos_screen.dart';

/// Coleção de animais 🐾: cada região do mapa-múndi vira um animalzinho
/// colecionável. Concluiu a fase no mapa → o animal dela entra na coleção
/// (o baú avisa: "Novo animal da coleção!"). As 8 regiões = os 8 bichos.
class ColecaoScreen extends StatefulWidget {
  const ColecaoScreen({super.key});

  @override
  State<ColecaoScreen> createState() => _ColecaoScreenState();
}

class _ColecaoScreenState extends State<ColecaoScreen> {
  List<String> _concluidas = const [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final concluidas = await ProgressoFases.carregar();
    if (mounted) setState(() => _concluidas = concluidas);
  }

  Future<void> _abrirAlimentos() async {
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ColecaoAlimentosScreen()),
    );
  }

  Future<void> _abrirObjetos() async {
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ColecaoObjetosScreen()),
    );
  }

  Future<void> _abrirNomes() async {
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ColecaoNomesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regioes = Regiao.regioes;
    final ganhas =
        regioes.where((r) => _concluidas.contains(r.chave)).length;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Coleção de animais 🐾  ($ganhas/${regioes.length})'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: TextButton.icon(
                onPressed: _abrirAlimentos,
                icon: const Text('🍎', style: TextStyle(fontSize: 16)),
                label: const Text('ALIMENTOS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: TextButton.icon(
                onPressed: _abrirObjetos,
                icon: const Text('🧸', style: TextStyle(fontSize: 16)),
                label: const Text('OBJETOS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: _abrirNomes,
                icon: const Text('🔤', style: TextStyle(fontSize: 16)),
                label: const Text('NOMES', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/colecao/colecao_fundo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.22))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      'Complete as fases do mapa-múndi para ganhar todos!',
                      style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
              const SizedBox(height: 12),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.25,
                      children: [
                        for (final r in regioes)
                          _AnimalCard(
                            regiao: r,
                            ganho: _concluidas.contains(r.chave),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão de um animal da coleção: ganho = bicho + nome + "Ganho! 🎉";
/// ainda não ganho = ❓ + "???" + "🔒 Fase pendente".
class _AnimalCard extends StatelessWidget {
  const _AnimalCard({required this.regiao, required this.ganho});

  final Regiao regiao;
  final bool ganho;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: ganho ? AppColors.surface2 : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ganho
              ? AppColors.accent.withValues(alpha: 0.6)
              : AppColors.line,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ganho ? regiao.emoji : '❓', style: const TextStyle(fontSize: 46)),
          const SizedBox(height: 6),
          Text(
            ganho ? regiao.rotulo : '???',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: ganho ? AppColors.text : AppColors.dim2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ganho ? 'Ganho! 🎉' : '🔒 Fase pendente',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ganho ? AppColors.acerto : AppColors.dim2,
            ),
          ),
        ],
      ),
    );
  }
}
