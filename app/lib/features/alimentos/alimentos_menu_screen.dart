import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/banco_palavras.dart';
import '../estudo/estudo_screen.dart';
import 'alimentos_temas_screen.dart';

class AlimentosMenuScreen extends StatelessWidget {
  const AlimentosMenuScreen({super.key});

  void _abrirNivel(BuildContext context, Nivel nivel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${Categoria.alimentos.emoji}  '
              '${Categoria.alimentos.rotulo} · ${nivel.rotulo}',
          palavras: palavrasDe(Categoria.alimentos, nivel),
        ),
      ),
    );
  }

  void _abrirTemas(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AlimentosTemasScreen()),
    );
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
                        asset: 'assets/alimentos/alimentos_facil.png',
                        legenda: 'Fácil',
                        cor: Nivel.facil.cor,
                        onTap: () => _abrirNivel(context, Nivel.facil),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _CenaBotao(
                        asset: 'assets/alimentos/alimentos_medio.png',
                        legenda: 'Médio',
                        cor: Nivel.media.cor,
                        onTap: () => _abrirNivel(context, Nivel.media),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _CenaBotao(
                        asset: 'assets/alimentos/alimentos_dificil.png',
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
                  asset: 'assets/alimentos/alimentos_temas.png',
                  legenda: 'Temas',
                  cor: Categoria.alimentos.cor,
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
