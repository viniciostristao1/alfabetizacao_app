import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';
import '../../util/versao.dart';
import '../config/config_screen.dart';
import '../escrever/escrever_screen.dart';
import '../habitat/habitat_map_screen.dart';
import '../nivel/nivel_screen.dart';

/// Tela principal (PAISAGEM): as modalidades de palavras.
/// O emoji/cor de cada card é só apoio visual — a criança que ainda não lê
/// reconhece a categoria pelo ícone. No topo, a pontuação (🪙 moedas · Nv)
/// fica SEMPRE visível e recarrega ao voltar de qualquer tela.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _moedas = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _carregarPontuacao();
  }

  Future<void> _carregarPontuacao() async {
    final moedas = await ProgressoRepository.moedas();
    final xp = await ProgressoRepository.xp();
    if (mounted) {
      setState(() {
        _moedas = moedas;
        _xp = xp;
      });
    }
  }

  Future<void> _abrirCategoria(Categoria categoria) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => switch (categoria) {
          // Animais viram um JOGO: mapa de habitats (paisagem), sem escolher
          // nível — cada habitat roda do mais fácil ao mais difícil.
          Categoria.animais => const HabitatMapScreen(),
          // Escrever = palavras do próprio usuário (digitadas na tela).
          Categoria.escrever => const EscreverScreen(),
          _ => NivelScreen(categoria: categoria),
        },
      ),
    );
    // Ao voltar, a pontuação pode ter mudado (acertos/erros nas palavras).
    if (mounted) _carregarPontuacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text('Primeiras Palavras', overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                'v$kVersao',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dim,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ConfigScreen()),
              );
              if (mounted) _carregarPontuacao();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pontuação SEMPRE visível, ao lado de "Escolha um tema".
              Row(
                children: [
                  const Text(
                    'Escolha um tema',
                    style: TextStyle(fontSize: 16, color: AppColors.dim),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      '🪙 $_moedas · Nv ${ProgressoRepository.nivelDe(_xp)}',
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dim,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Grade COMPACTA em paisagem (4 colunas, cartões menores):
              // cabe tudo na tela sem rolar.
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.9,
                  children: [
                    for (final c in Categoria.values)
                      _CategoriaCard(
                        categoria: c,
                        onTap: () => _abrirCategoria(c),
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

class _CategoriaCard extends StatelessWidget {
  const _CategoriaCard({required this.categoria, required this.onTap});

  final Categoria categoria;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: categoria.cor.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(categoria.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 6),
              Text(
                categoria.rotulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
