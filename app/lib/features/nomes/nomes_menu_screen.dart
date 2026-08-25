import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/banco_palavras.dart';
import '../../services/progresso_repository.dart';
import '../estudo/estudo_screen.dart';
import 'nomes_temas_screen.dart';

class NomesMenuScreen extends StatefulWidget {
  const NomesMenuScreen({super.key});

  @override
  State<NomesMenuScreen> createState() => _NomesMenuScreenState();
}

class _NomesMenuScreenState extends State<NomesMenuScreen> {
  int _moedas = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final moedas = await ProgressoRepository.moedas();
    final xp = await ProgressoRepository.xp();
    if (mounted) setState(() { _moedas = moedas; _xp = xp; });
  }

  void _abrirNivel(BuildContext context, Nivel nivel) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${Categoria.nomes.emoji}  '
              '${Categoria.nomes.rotulo} · ${nivel.rotulo}',
          palavras: palavrasDe(Categoria.nomes, nivel),
        ),
      ),
    );
    if (mounted) _carregar();
  }

  void _abrirTemas(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NomesTemasScreen()),
    );
    if (mounted) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    Expanded(
                      child: _CenaBotao(
                        asset: 'assets/nomes/nomes_facil.png',
                        legenda: 'Fácil',
                        cor: Nivel.facil.cor,
                        onTap: () => _abrirNivel(context, Nivel.facil),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _CenaBotao(
                        asset: 'assets/nomes/nomes_medio.png',
                        legenda: 'Médio',
                        cor: Nivel.media.cor,
                        onTap: () => _abrirNivel(context, Nivel.media),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _CenaBotao(
                        asset: 'assets/nomes/nomes_dificil.png',
                        legenda: 'Difícil',
                        cor: Nivel.dificil.cor,
                        onTap: () => _abrirNivel(context, Nivel.dificil),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                flex: 4,
                child: _CenaBotao(
                  asset: 'assets/nomes/nomes_temas.png',
                  legenda: 'Temas',
                  cor: Categoria.nomes.cor,
                  onTap: () => _abrirTemas(context),
                ),
              ),
            ],
          ),
          Positioned(
            top: 6,
            left: 6,
            child: SafeArea(
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    '🪙 $_moedas · Nv ${ProgressoRepository.nivelDe(_xp)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenaBotao extends StatelessWidget {
  const _CenaBotao({
    required this.asset,
    required this.legenda,
    required this.cor,
    required this.onTap,
  });

  final String asset;
  final String legenda;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                asset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                    ),
                  ),
                  child: Text(
                    legenda,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
