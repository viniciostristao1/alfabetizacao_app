import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';
import '../../util/versao.dart';
import '../config/config_screen.dart';
import '../contas/contas_menu_screen.dart';
import '../colecao/colecao_alimentos_screen.dart';
import '../colecao/colecao_nomes_screen.dart';
import '../colecao/colecao_objetos_screen.dart';
import '../colecao/colecao_screen.dart';
import '../escrever/escrever_screen.dart';
import '../alimentos/alimentos_menu_screen.dart';
import '../habitat/habitat_map_screen.dart';
import '../nomes/nomes_menu_screen.dart';
import '../objetos/objetos_menu_screen.dart';

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
          Categoria.animais => const HabitatMapScreen(),
          Categoria.objetos => const ObjetosMenuScreen(),
          Categoria.alimentos => const AlimentosMenuScreen(),
          Categoria.nomes => const NomesMenuScreen(),
          Categoria.escrever => const EscreverScreen(),
          Categoria.contas => const ContasMenuScreen(),
        },
      ),
    );
    // Ao voltar, a pontuação pode ter mudado (acertos/erros nas palavras).
    if (mounted) _carregarPontuacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/icon/logo.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Flexible(
              child: Text('JOGO DO DAVI', overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                'v$kVersao',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Pontuação SEMPRE visível, ao lado da engrenagem (configurações).
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '🪙 $_moedas · Nv ${ProgressoRepository.nivelDe(_xp)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Coleção de animais',
            icon: const Icon(Icons.pets_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ColecaoScreen()),
              );
              if (mounted) _carregarPontuacao();
            },
          ),
          IconButton(
            tooltip: 'Coleção de alimentos',
            icon: const Text('🍎', style: TextStyle(fontSize: 20)),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ColecaoAlimentosScreen()),
              );
              if (mounted) _carregarPontuacao();
            },
          ),
          IconButton(
            tooltip: 'Coleção de objetos',
            icon: const Text('🧸', style: TextStyle(fontSize: 20)),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ColecaoObjetosScreen()),
              );
              if (mounted) _carregarPontuacao();
            },
          ),
          IconButton(
            tooltip: 'Coleção de nomes',
            icon: const Text('🔤', style: TextStyle(fontSize: 20)),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ColecaoNomesScreen()),
              );
              if (mounted) _carregarPontuacao();
            },
          ),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/home/home_fundo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.22)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Escolha um tema',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.6,
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
        ],
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
              Text(categoria.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 4),
              Text(
                categoria.rotulo,
                style: const TextStyle(
                  fontSize: 14,
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
