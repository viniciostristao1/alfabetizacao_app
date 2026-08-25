import 'package:flutter/material.dart';

import '../../models/alimentos_tema.dart';
import '../../services/progresso_alimentos_fases.dart';
import '../../theme/app_colors.dart';
import '../alimentos/alimentos_temas_screen.dart';

class ColecaoAlimentosScreen extends StatefulWidget {
  const ColecaoAlimentosScreen({super.key});

  @override
  State<ColecaoAlimentosScreen> createState() => _ColecaoAlimentosScreenState();
}

class _ColecaoAlimentosScreenState extends State<ColecaoAlimentosScreen> {
  List<String> _concluidas = const [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final c = await ProgressoAlimentosFases.carregar();
    if (mounted) setState(() => _concluidas = c);
  }

  Future<void> _abrirFazenda() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AlimentosTemasScreen()),
    );
    if (mounted) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final temas = AlimentosTema.values;
    final ganhas = temas.where((t) => _concluidas.contains(t.chave)).length;
    final todosGanhos = ganhas == temas.length;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Coleção de alimentos 🍎  ($ganhas/${temas.length})'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: _abrirFazenda,
                icon: const Icon(Icons.agriculture_rounded),
                label: const Text('FAZENDA', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete as fases dos Temas para ganhar comidas saborosas!',
                style: TextStyle(fontSize: 14, color: AppColors.dim),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    for (final t in temas)
                      _PremioCard(
                        emoji: t.premioEmoji,
                        nome: t.premioNome,
                        tema: t.rotulo,
                        ganho: _concluidas.contains(t.chave),
                        cor: t.cor,
                      ),
                    _PremioCard(
                      emoji: '🍫',
                      nome: 'Chocolate',
                      tema: 'Bônus final',
                      ganho: todosGanhos,
                      cor: const Color(0xFF8B4513),
                      destaque: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremioCard extends StatelessWidget {
  const _PremioCard({
    required this.emoji,
    required this.nome,
    required this.tema,
    required this.ganho,
    required this.cor,
    this.destaque = false,
  });

  final String emoji;
  final String nome;
  final String tema;
  final bool ganho;
  final Color cor;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: ganho ? AppColors.surface2 : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ganho
              ? (destaque ? const Color(0xFFFFD700).withValues(alpha: 0.8) : cor.withValues(alpha: 0.6))
              : AppColors.line,
          width: destaque && ganho ? 2.2 : 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ganho ? emoji : '❓', style: const TextStyle(fontSize: 42)),
          const SizedBox(height: 4),
          Text(
            ganho ? nome : '???',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: ganho ? AppColors.text : AppColors.dim2,
            ),
          ),
          Text(
            tema,
            style: TextStyle(fontSize: 11, color: ganho ? AppColors.dim : AppColors.dim2),
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
