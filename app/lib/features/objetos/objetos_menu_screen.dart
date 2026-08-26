import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../models/palavra.dart';
import '../../services/banco_palavras.dart';
import '../../services/progresso_repository.dart';
import '../estudo/estudo_screen.dart';
import '../selecao/selecao_objetos_screen.dart';
import 'temas_screen.dart';

class ObjetosMenuScreen extends StatefulWidget {
  const ObjetosMenuScreen({super.key});

  @override
  State<ObjetosMenuScreen> createState() => _ObjetosMenuScreenState();
}

class _ObjetosMenuScreenState extends State<ObjetosMenuScreen> {
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
          titulo: '${Categoria.objetos.emoji}  '
              '${Categoria.objetos.rotulo} · ${nivel.rotulo}',
          palavras: palavrasDe(Categoria.objetos, nivel),
        ),
      ),
    );
    if (mounted) _carregar();
  }

  void _abrirTemas(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TemasScreen()),
    );
    if (mounted) _carregar();
  }

  Future<void> _selecionarObjetos() async {
    final escolhidos = await Navigator.of(context).push<List<Palavra>>(
      MaterialPageRoute(builder: (_) => const SelecaoObjetosScreen()),
    );
    if (escolhidos == null || escolhidos.isEmpty) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '🧸  Meus objetos',
          palavras: escolhidos,
          manterPaisagemAoSair: true,
        ),
      ),
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
                        asset: 'assets/objetos/objetos_facil.png',
                        legenda: 'Fácil',
                        cor: Nivel.facil.cor,
                        onTap: () => _abrirNivel(context, Nivel.facil),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _CenaBotao(
                        asset: 'assets/objetos/objetos_medio.png',
                        legenda: 'Médio',
                        cor: Nivel.media.cor,
                        onTap: () => _abrirNivel(context, Nivel.media),
                      ),
                    ),
                    const SizedBox(width: 4),
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
              const SizedBox(height: 4),
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
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 28,
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
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _BotaoTransparente(
                  icon: Icons.search,
                  texto: 'SELECIONAR OBJETOS',
                  onTap: _selecionarObjetos,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoTransparente extends StatelessWidget {
  const _BotaoTransparente({
    required this.icon,
    required this.texto,
    required this.onTap,
  });

  final IconData icon;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                texto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
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
