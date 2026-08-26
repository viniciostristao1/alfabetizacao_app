import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/habitat.dart';
import '../../models/palavra.dart';
import '../../services/banco_palavras.dart';
import '../../services/progresso_repository.dart';
import '../estudo/estudo_screen.dart';
import '../mapa_mundi/mapa_mundi_screen.dart';
import '../selecao/selecao_animais_screen.dart';

/// Mapa de HABITATS dos animais (PAISAGEM, tela cheia). A imagem
/// `assets/habitats/mapa_animais.jpg` (grade 3×2) aparece **inteira** (nada é
/// cortado), na proporção certa, e o resto da tela é preenchido com **água**
/// (kAgua) — fica "infinita" sem perder nada. Sobre a imagem, 6 células: 5 são
/// os habitats (abrem as palavras) e a 6ª abre o **mapa-múndi de fases**.
/// Um botão "SELECIONAR ANIMAIS" (inferior esquerdo) abre a busca de animais.
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

  // Pontuação (moedas/nível) — sempre visível no canto superior direito.
  int _moedas = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(_paisagem);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // App todo em PAISAGEM — garante ao sair (redundante, mas seguro).
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _reaplicarTela() {
    SystemChrome.setPreferredOrientations(_paisagem);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Habitat? _habitatEm(int col, int row) {
    for (final h in Habitat.values) {
      if (h.col == col && h.row == row) return h;
    }
    return null; // mapa-múndi
  }

  Future<void> _abrirHabitat(Habitat h) async {
    // A célula das Aves abre Aves + Fazenda juntos (a Fazenda não tem célula
    // própria na grade — vive só como fase no mapa-múndi).
    final ehAvesFazenda = h == Habitat.aves;
    final palavras = ehAvesFazenda
        ? palavrasDosHabitats(['aves', 'fazenda'])
        : palavrasDoHabitat(h.chave);
    final titulo = ehAvesFazenda
        ? '🦅🐮  Aves e Fazenda'
        : '${h.emoji}  Animais · ${h.rotulo}';
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: titulo,
          palavras: palavras,
          manterPaisagemAoSair: true,
        ),
      ),
    );
    if (mounted) {
      _reaplicarTela();
      _carregarPontuacao(); // moedas mudaram com acertos/erros
    }
  }

  Future<void> _abrirMapaMundi() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapaMundiScreen()),
    );
    if (mounted) {
      _reaplicarTela();
      _carregarPontuacao();
    }
  }

  Future<void> _selecionarAnimais() async {
    final escolhidos = await Navigator.of(context).push<List<Palavra>>(
      MaterialPageRoute(builder: (_) => const SelecaoAnimaisScreen()),
    );
    if (!mounted) return;
    _reaplicarTela();
    if (escolhidos == null || escolhidos.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '🐾  Meus animais',
          palavras: escolhidos,
          manterPaisagemAoSair: true,
        ),
      ),
    );
    if (mounted) {
      _reaplicarTela();
      _carregarPontuacao();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAgua,
      body: Stack(
        children: [
          // imagem enche a LARGURA (encosta nas laterais, sem ficar quadrada) e
          // é esticada de leve (BoxFit.fill = nada cortado); água (kAgua)
          // preenche o que sobra em cima/embaixo. Grade 3×2 divide a MESMA box,
          // então segue alinhada à imagem em qualquer tela.
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final boxH = (w / kMapaDisplayAspect).clamp(0.0, c.maxHeight);
                return Center(
                  child: SizedBox(
                    width: w,
                    height: boxH,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/habitats/mapa_animais.jpg',
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (_, _, _) =>
                              const ColoredBox(color: kAgua),
                        ),
                        Column(
                          children: [
                            for (int row = 0; row < kHabitatLinhas; row++)
                              Expanded(
                                child: Row(
                                  children: [
                                    for (int col = 0;
                                        col < kHabitatColunas;
                                        col++)
                                      Expanded(
                                        child: _Celula(
                                          habitat: _habitatEm(col, row),
                                          onHabitat: _abrirHabitat,
                                          onMapaMundi: _abrirMapaMundi,
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
                );
              },
            ),
          ),
          // pontuação (moedas · nível) — canto superior direito, ao lado da
          // célula "Selva" (o usuário pediu).
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // voltar (canto superior esquerdo)
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
                    icon: const Icon(Icons.arrow_back_rounded, size: 28),
                    color: Colors.white,
                    tooltip: 'Voltar',
                  ),
                ),
              ),
            ),
          ),
          // SELECIONAR ANIMAIS (canto inferior esquerdo)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _BotaoTransparente(
                  icon: Icons.search,
                  texto: 'SELECIONAR ANIMAIS',
                  onTap: _selecionarAnimais,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Célula sobre a imagem. Com [habitat] = botão do habitat (com o nome). Sem
/// habitat = mapa-múndi (abre a tela de fases).
class _Celula extends StatelessWidget {
  const _Celula({
    required this.habitat,
    required this.onHabitat,
    required this.onMapaMundi,
  });

  final Habitat? habitat;
  final ValueChanged<Habitat> onHabitat;
  final VoidCallback onMapaMundi;

  @override
  Widget build(BuildContext context) {
    final h = habitat;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: h == null ? onMapaMundi : () => onHabitat(h),
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            // "Selva" (célula sup. direita) sai para a esquerda: senão fica por
            // baixo da caixinha de moedas (canto sup. direito).
            child: Transform.translate(
              offset: h == Habitat.selva ? const Offset(-38, 0) : Offset.zero,
              child: _Nome(
                emoji: h?.emoji ?? '🗺️',
                rotulo: h == null
                    ? 'Mapa-múndi'
                    : (h == Habitat.aves ? 'Aves e Fazenda' : h.rotulo),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Etiqueta com o nome (legível sobre qualquer parte da imagem).
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

/// Botão translúcido (mesmo estilo dos nomes) — o "SELECIONAR ANIMAIS".
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
