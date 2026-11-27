import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/palavra.dart';
import '../../services/caca_palavras.dart';
import '../../services/fala.dart';
import '../../services/progresso_repository.dart';

/// Caça-palavras no cenário (PAISAGEM): a arte da categoria em tela cheia com
/// as palavras espalhadas como fichas. O app FALA e mostra qual achar
/// ("Ache: GATO"); a criança toca a ficha certa — ela acende verde e soma
/// pontos. Ficha errada só pisca vermelha (sem penalizar, sem frustrar).
/// A cada rodada: 3 alvos; no fim, parabéns + moedas + jogar de novo/sair.
///
/// As posições são relativas à imagem (fx/fy 0..1), como os marcadores do
/// mapa-múndi — funcionam em qualquer tamanho de tela.
class CacaPalavrasScreen extends StatefulWidget {
  const CacaPalavrasScreen({
    super.key,
    required this.titulo,
    required this.imagem,
    required this.palavras,
  });

  final String titulo;
  final String imagem;
  final List<Palavra> palavras;

  @override
  State<CacaPalavrasScreen> createState() => _CacaPalavrasScreenState();
}

class _CacaPalavrasScreenState extends State<CacaPalavrasScreen> {
  static const _paisagem = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  late RodadaCaca _rodada;
  final _achadas = <String>{};
  String? _erro;
  int _moedas = 0;
  int _xp = 0;
  int _moedasRodada = 0;
  final _rng = Random();

  /// Alvo atual (o próximo ainda não achado). Quando a rodada completa, o
  /// diálogo de parabéns cobre a tela — mantém o último para o build.
  Palavra get _alvoAtual => _achadas.length < _rodada.alvos.length
      ? _rodada.alvos[_achadas.length]
      : _rodada.alvos.last;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(_paisagem);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _rodada = montarRodada(widget.palavras, rng: _rng);
    _carregarPontuacao();
    _falarAlvo();
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

  void _falarAlvo() {
    if (_achadas.length < _rodada.alvos.length) {
      unawaited(Fala.instance.falar(_alvoAtual.texto));
    }
  }

  /// Pontos da palavra: mesma conta da EstudoScreen (2 por sílaba além da 1ª).
  int _pontosDe(Palavra p) => (2 * (p.nivelSilabas - 1)).clamp(1, 999);

  Future<void> _tocouFicha(FichaCaca ficha) async {
    if (_achadas.contains(ficha.palavra.texto)) return;
    if (ficha.palavra.texto != _alvoAtual.texto) {
      setState(() => _erro = ficha.palavra.texto);
      return;
    }
    final pontos = _pontosDe(ficha.palavra);
    await ProgressoRepository.registrarAcerto(pontos);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _achadas.add(ficha.palavra.texto);
      _erro = null;
      _moedas += pontos;
      _xp += pontos;
      _moedasRodada += pontos;
    });
    if (_achadas.length >= _rodada.alvos.length) {
      await _fimDeRodada();
    } else {
      _falarAlvo();
    }
  }

  /// Achou as 3: parabéns + moedas da rodada, com "Jogar de novo" / "Sair".
  Future<void> _fimDeRodada() async {
    unawaited(Fala.instance.falar('Você achou todas! Parabéns!'));
    final deNovo = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        scrollable: true,
        title: const Text('Você achou todas! 🎉'),
        content: Text(
          '+$_moedasRodada moedas nesta caçada! Quer procurar de novo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Sair'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('De novo'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (deNovo == true) {
      setState(() {
        _rodada = montarRodada(widget.palavras, rng: _rng);
        _achadas.clear();
        _erro = null;
        _moedasRodada = 0;
      });
      _falarAlvo();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _novaRodada() async {
    setState(() {
      _rodada = montarRodada(widget.palavras, rng: _rng);
      _achadas.clear();
      _erro = null;
      _moedasRodada = 0;
    });
    _falarAlvo();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(_paisagem);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          return Stack(
            fit: StackFit.expand,
            children: [
              // cenário (arte da categoria, tela cheia)
              Image.asset(
                widget.imagem,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: Colors.black),
              ),
              // fichas espalhadas (posições relativas à imagem)
              for (final ficha in _rodada.fichas)
                Positioned(
                  left: ficha.fx * w,
                  top: ficha.fy * h,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: _Ficha(
                      ficha: ficha,
                      achada: _achadas.contains(ficha.palavra.texto),
                      errada: _erro == ficha.palavra.texto,
                      onTap: () => _tocouFicha(ficha),
                    ),
                  ),
                ),
              // topo: voltar + "Ache: X (n/3)" + 🔊 + moedas, ancorado no
              // topo (T003): o Align expandia a Row na altura toda e a pílula
              // ficava centralizada no meio da cena, cobrindo fichas.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        _BotaoCaca(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                          tooltip: 'Voltar',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(22),
                                border:
                                    Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                '🔎 Ache: ${_alvoAtual.texto.toUpperCase()} '
                                '(${_achadas.length}/${_rodada.alvos.length})',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _BotaoCaca(
                          icon: Icons.volume_up_rounded,
                          onTap: _falarAlvo,
                          tooltip: 'Ouvir de novo',
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                      ],
                    ),
                  ),
                ),
              ),
              // base: sair + nova rodada
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BotaoCacaTexto(
                          icon: Icons.home_rounded,
                          texto: 'SAIR',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 10),
                        _BotaoCacaTexto(
                          icon: Icons.refresh_rounded,
                          texto: 'NOVA CAÇADA',
                          onTap: _novaRodada,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Ficha com a palavra sobre o cenário: pílula escura translúcida (legível
/// sobre qualquer arte). Achada = verde; errada = vermelha até tentar de novo.
class _Ficha extends StatelessWidget {
  const _Ficha({
    required this.ficha,
    required this.achada,
    required this.errada,
    required this.onTap,
  });

  final FichaCaca ficha;
  final bool achada;
  final bool errada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fundo;
    final Color borda;
    if (achada) {
      fundo = const Color(0xFF2E9D44);
      borda = Colors.white;
    } else if (errada) {
      fundo = const Color(0xFFE23B3B);
      borda = Colors.white;
    } else {
      fundo = Colors.black.withValues(alpha: 0.55);
      borda = Colors.white24;
    }
    return Material(
      color: fundo,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: achada ? null : onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borda, width: achada ? 2.5 : 1.5),
          ),
          child: Text(
            achada
                ? '★ ${ficha.palavra.texto.toUpperCase()}'
                : ficha.palavra.texto.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                    color: Color(0xB3000000),
                    blurRadius: 4,
                    offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão redondo translúcido (voltar / ouvir).
class _BotaoCaca extends StatelessWidget {
  const _BotaoCaca(
      {required this.icon, required this.onTap, required this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

/// Botão retangular translúcido da base (sair / nova caçada).
class _BotaoCacaTexto extends StatelessWidget {
  const _BotaoCacaTexto(
      {required this.icon, required this.texto, required this.onTap});

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
