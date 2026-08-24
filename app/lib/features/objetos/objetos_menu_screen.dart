import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/banco_palavras.dart';
import '../estudo/estudo_screen.dart';
import 'temas_screen.dart';

/// Menu de OBJETOS (paisagem): uma foto com 4 cenas viram 4 botões.
/// As **3 de cima** rodam os níveis de sempre — Fácil / Médio / Difícil
/// (`palavrasDe(objetos, nível)` → EstudoScreen). A **de baixo** ("Temas")
/// é o ponto de entrada de um modo por tema (comportamento a definir).
class ObjetosMenuScreen extends StatelessWidget {
  const ObjetosMenuScreen({super.key});

  void _abrirNivel(BuildContext context, Nivel nivel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${Categoria.objetos.emoji}  '
              '${Categoria.objetos.rotulo} · ${nivel.rotulo}',
          palavras: palavrasDe(Categoria.objetos, nivel),
        ),
      ),
    );
  }

  void _abrirTemas(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TemasScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${Categoria.objetos.emoji}  ${Categoria.objetos.rotulo}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // 3 cenas de cima = os níveis de sempre
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    Expanded(
                      child: _CenaBotao(
                        asset: 'assets/objetos/objetos_facil.png',
                        legenda: 'Fácil',
                        cor: Nivel.facil.cor,
                        onTap: () => _abrirNivel(context, Nivel.facil),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CenaBotao(
                        asset: 'assets/objetos/objetos_medio.png',
                        legenda: 'Médio',
                        cor: Nivel.media.cor,
                        onTap: () => _abrirNivel(context, Nivel.media),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CenaBotao(
                        asset: 'assets/objetos/objetos_dificil.png',
                        legenda: 'Difícil',
                        cor: Nivel.dificil.cor,
                        onTap: () => _abrirNivel(context, Nivel.dificil),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // cena larga de baixo = Temas
              Expanded(
                flex: 4,
                child: _CenaBotao(
                  asset: 'assets/objetos/objetos_temas.png',
                  legenda: 'Temas',
                  cor: Categoria.objetos.cor,
                  onTap: () => _abrirTemas(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Uma cena da foto virada em botão: imagem (cantos arredondados, borda na cor
/// do nível) + a legenda LOGO ABAIXO.
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
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cor.withValues(alpha: 0.75),
                    width: 2.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    asset,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              legenda,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
