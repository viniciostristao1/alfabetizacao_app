import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/habitat.dart';
import '../../services/banco_palavras.dart';
import '../estudo/estudo_screen.dart';

/// Mapa de HABITATS dos animais (PAISAGEM, clima de jogo). Mostra a imagem
/// `assets/habitats/mapa_animais.jpg` (grade 3×2) e sobrepõe **6 células**
/// perfeitamente alinhadas: as 5 dos habitats são botões (abrem as palavras do
/// habitat, do mais fácil ao mais difícil); a 6ª (mapa-múndi) fica reservada.
///
/// Força paisagem ao abrir e restaura o retrato ao sair. Ao voltar da tela de
/// estudo (que restaura retrato no dispose), re-força a paisagem.
class HabitatMapScreen extends StatefulWidget {
  const HabitatMapScreen({super.key});

  @override
  State<HabitatMapScreen> createState() => _HabitatMapScreenState();
}

class _HabitatMapScreenState extends State<HabitatMapScreen> {
  static const _paisagem = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(_paisagem);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  /// Habitat naquela posição da grade (ou null = mapa-múndi, reservado).
  Habitat? _habitatEm(int col, int row) {
    for (final h in Habitat.values) {
      if (h.col == col && h.row == row) return h;
    }
    return null;
  }

  Future<void> _abrirHabitat(Habitat h) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${h.emoji}  Animais · ${h.rotulo}',
          palavras: palavrasDoHabitat(h.chave),
        ),
      ),
    );
    // A tela de estudo restaura o retrato ao sair → aqui voltamos à paisagem.
    if (mounted) SystemChrome.setPreferredOrientations(_paisagem);
  }

  void _mapaMundi() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('O mapa-múndi vem em breve! 🗺️'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // topo: voltar + título
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Colors.white,
                    tooltip: 'Voltar',
                  ),
                  const Text(
                    'Animais — toque no habitat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // imagem + grade de 6 células alinhada
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: kMapaAnimaisAspect,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/habitats/mapa_animais.jpg',
                        fit: BoxFit.fill,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xFF13233B),
                          child: Center(
                            child: Text(
                              'mapa dos habitats',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          for (int row = 0; row < kHabitatLinhas; row++)
                            Expanded(
                              child: Row(
                                children: [
                                  for (int col = 0; col < kHabitatColunas; col++)
                                    Expanded(
                                      child: _Celula(
                                        habitat: _habitatEm(col, row),
                                        onHabitat: _abrirHabitat,
                                        onReservada: _mapaMundi,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
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

/// Uma célula da grade sobre a imagem. Com [habitat] = botão do habitat (com o
/// nome). Sem habitat = célula reservada (mapa-múndi): toque dá um aviso leve.
class _Celula extends StatelessWidget {
  const _Celula({
    required this.habitat,
    required this.onHabitat,
    required this.onReservada,
  });

  final Habitat? habitat;
  final ValueChanged<Habitat> onHabitat;
  final VoidCallback onReservada;

  @override
  Widget build(BuildContext context) {
    final h = habitat;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: h == null ? onReservada : () => onHabitat(h),
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: h == null
            ? const SizedBox.expand()
            : Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _Nome(emoji: h.emoji, rotulo: h.rotulo),
                ),
              ),
      ),
    );
  }
}

/// Etiqueta com o nome do habitat (fica legível sobre qualquer parte da imagem).
class _Nome extends StatelessWidget {
  const _Nome({required this.emoji, required this.rotulo});

  final String emoji;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$emoji  ${rotulo.toUpperCase()}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
