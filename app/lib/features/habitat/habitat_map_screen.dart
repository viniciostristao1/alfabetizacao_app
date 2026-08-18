import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/habitat.dart';
import '../../services/banco_palavras.dart';
import '../estudo/estudo_screen.dart';

/// Mapa de HABITATS dos animais (PAISAGEM, tela cheia, clima de jogo). Mostra a
/// imagem `assets/habitats/mapa_animais.jpg` (grade 3×2) ocupando a tela inteira
/// e sobrepõe **6 células**: as 5 dos habitats são botões (abrem as palavras do
/// habitat, do mais fácil ao mais difícil); a 6ª (mapa-múndi) fica reservada.
///
/// Força paisagem + modo imersivo (sem barras) ao abrir e restaura ao sair. Ao
/// voltar da tela de estudo, esta continua deitada (a EstudoScreen mantém a
/// paisagem quando vem daqui — ver `manterPaisagemAoSair`).
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
    // Tela cheia de verdade (esconde status/navegação) para o mapa.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Habitat? _habitatEm(int col, int row) {
    for (final h in Habitat.values) {
      if (h.col == col && h.row == row) return h;
    }
    return null; // mapa-múndi (reservado)
  }

  Future<void> _abrirHabitat(Habitat h) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${h.emoji}  Animais · ${h.rotulo}',
          palavras: palavrasDoHabitat(h.chave),
          manterPaisagemAoSair: true,
        ),
      ),
    );
    // Reforça paisagem/imersivo ao voltar (o Estudo já mantém a paisagem).
    if (!mounted) return;
    SystemChrome.setPreferredOrientations(_paisagem);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // imagem ocupando a TELA INTEIRA (recorta um pouco das bordas)
          Image.asset(
            'assets/habitats/mapa_animais.jpg',
            fit: BoxFit.cover,
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
          // 6 células alinhadas à grade 3×2 (mesma proporção da tela)
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
          // botão voltar flutuante (sobre a imagem)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.white24),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Colors.white,
                    tooltip: 'Voltar',
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
                  padding: const EdgeInsets.only(top: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
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
