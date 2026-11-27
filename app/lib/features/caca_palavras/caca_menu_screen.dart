import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/grade_caca.dart';
import '../../services/progresso_repository.dart';
import 'caca_classica_screen.dart';

/// Menu do Caça-palavras (PAISAGEM, molde ContasMenuScreen): a criança
/// escolhe o TEMA das palavras (6 categorias, com o pool que já existe) e o
/// NÍVEL (fácil/médio/difícil) e toca em JOGAR. Grade com rolagem — cabe no
/// celular deitado (800x360, 864x411) e no tablet com os mesmos widgets.
class CacaMenuScreen extends StatefulWidget {
  const CacaMenuScreen({super.key});

  @override
  State<CacaMenuScreen> createState() => _CacaMenuScreenState();
}

class _CacaMenuScreenState extends State<CacaMenuScreen> {
  static const _temas = [
    Categoria.animais,
    Categoria.objetos,
    Categoria.alimentos,
    Categoria.nomes,
    Categoria.espaco,
    Categoria.futebol,
  ];

  Categoria _tema = Categoria.animais;
  Nivel _nivel = Nivel.facil;
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
    if (mounted) setState(() {
      _moedas = moedas;
      _xp = xp;
    });
  }

  void _jogar() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => CacaClassicaScreen(
          titulo: 'Caça-palavras · ${_tema.rotulo} · ${_nivel.rotulo}',
          tema: _tema,
          nivel: _nivel,
        ),
      ),
    )
        .then((_) {
      if (mounted) _carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'CAÇA-PALAVRAS',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '🪙 $_moedas · Nv ${ProgressoRepository.nivelDe(_xp)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'TEMA DAS PALAVRAS',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Expanded(
                flex: 5,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3.4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final t in _temas)
                      _TemaCard(
                        key: Key('caca-tema-${t.name}'),
                        categoria: t,
                        selecionado: t == _tema,
                        onTap: () => setState(() => _tema = t),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'NÍVEL',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              Expanded(
                flex: 2,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3.4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final n in Nivel.values)
                      _NivelCard(
                        key: Key('caca-nivel-${n.name}'),
                        nivel: n,
                        selecionado: n == _nivel,
                        onTap: () => setState(() => _nivel = n),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('caca-jogar'),
                  onPressed: _jogar,
                  icon: const Icon(Icons.play_arrow_rounded, size: 26),
                  label: const Text(
                    'JOGAR',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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

class _TemaCard extends StatelessWidget {
  const _TemaCard(
      {super.key,
      required this.categoria,
      required this.selecionado,
      required this.onTap});

  final Categoria categoria;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionado
          ? categoria.cor.withValues(alpha: 0.35)
          : Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selecionado ? categoria.cor : Colors.white24,
              width: selecionado ? 3 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(categoria.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  categoria.rotulo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NivelCard extends StatelessWidget {
  const _NivelCard(
      {super.key,
      required this.nivel,
      required this.selecionado,
      required this.onTap});

  final Nivel nivel;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionado
          ? nivel.cor.withValues(alpha: 0.45)
          : Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selecionado ? nivel.cor : Colors.white24,
              width: selecionado ? 3 : 1,
            ),
          ),
          child: Center(
            child: Text(
              nivel.rotulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
