import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/categoria.dart';
import '../../models/palavra.dart';
import '../../services/fala.dart';
import '../../services/grade_caca.dart';
import '../../services/progresso_repository.dart';

/// Caça-palavras CLÁSSICO (PAISAGEM): grade de quadrados com uma letra cada.
/// A criança arrasta o dedo sobre os quadrados (como células de planilha);
/// o trecho gruda em linha reta (horizontal, vertical, diagonal). Se cobre
/// exatamente uma palavra escondida, é acerto (trecho verde + palavra
/// riscada na lista + fala + moedas); se não, o preview some sem punir.
///
/// Grade de um lado, lista do outro. Fundo sólido (sem cena) para a letra
/// pequena manter contraste. Fácil 6x6 (3 palavras, só E/S), médio 7x7
/// (4 palavras, +diagonais para frente), difícil 8x8 (5 palavras, 8 direções).
class CacaClassicaScreen extends StatefulWidget {
  const CacaClassicaScreen({
    super.key,
    required this.titulo,
    required this.tema,
    required this.nivel,
    this.candidatas,
    this.seed,
  });

  final String titulo;
  final Categoria tema;
  final Nivel nivel;

  /// Pool explícito (só testes usam; o menu passa null e vale o banco).
  final List<Palavra>? candidatas;

  /// Semente da primeira rodada (só testes usam; "Nova caçada" é aleatória).
  final int? seed;

  @override
  State<CacaClassicaScreen> createState() => _CacaClassicaScreenState();
}

class _CacaClassicaScreenState extends State<CacaClassicaScreen> {
  static const _paisagem = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  late int _tamanho;
  late Set<Direcao> _direcoes;
  late int _nPalavras;
  late List<Palavra> _pool;
  late GradeCaca _grade;
  final _achadas = <String>{};
  List<Pos> _preview = [];
  Pos? _ancora;
  int _moedas = 0;
  int _xp = 0;
  int _moedasRodada = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(_paisagem);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _tamanho = tamanhoParaNivel(widget.nivel);
    _direcoes = direcoesParaNivel(widget.nivel);
    _nPalavras = nPalavrasParaNivel(widget.nivel);
    _pool = widget.candidatas ?? palavrasParaCaca(widget.tema, widget.nivel);
    _grade = gerarGrade(_pool,
        tamanho: _tamanho,
        direcoes: _direcoes,
        nPalavras: _nPalavras,
        rng: widget.seed == null ? Random() : Random(widget.seed));
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

  /// Pontos da palavra: mesma conta da tela antiga (2 por sílaba além da 1ª).
  int _pontosDe(String texto) {
    for (final p in _pool) {
      if (p.texto == texto) return (2 * (p.nivelSilabas - 1)).clamp(1, 999);
    }
    return 1;
  }

  void _falarPrimeira() {
    for (final e in _grade.escondidas) {
      if (!_achadas.contains(e.texto)) {
        unawaited(Fala.instance.falar(e.texto));
        return;
      }
    }
  }

  Set<Pos> get _celulasAchadas => {
        for (final e in _grade.escondidas)
          if (_achadas.contains(e.texto)) ...e.celulas,
      };

  Pos _posDe(Offset local, double lado) {
    final cel = lado / _tamanho;
    return Pos((local.dy / cel).floor().clamp(0, _tamanho - 1),
        (local.dx / cel).floor().clamp(0, _tamanho - 1));
  }

  void _inicioArrasto(Offset local, double lado) {
    final p = _posDe(local, lado);
    setState(() {
      _ancora = p;
      _preview = [p];
    });
  }

  void _atualizaArrasto(Offset local, double lado) {
    final ancora = _ancora;
    if (ancora == null) return;
    final cel = lado / _tamanho;
    final dr = local.dy / cel - (ancora.r + 0.5);
    final dc = local.dx / cel - (ancora.c + 0.5);
    final trecho = normalizarArrasto(ancora, dr, dc, _direcoes)
        .where((p) =>
            p.r >= 0 && p.r < _tamanho && p.c >= 0 && p.c < _tamanho)
        .toList();
    setState(() => _preview = trecho);
  }

  Future<void> _fimArrasto() async {
    final trecho = _preview;
    _ancora = null;
    if (trecho.isEmpty) {
      setState(() => _preview = []);
      return;
    }
    final achou = conferirSelecao(trecho, _grade.escondidas);
    if (achou == null || _achadas.contains(achou.texto)) {
      // Errou ou já achada: o preview some, sem punir.
      setState(() => _preview = []);
      return;
    }
    final pontos = _pontosDe(achou.texto);
    await ProgressoRepository.registrarAcerto(pontos);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    unawaited(Fala.instance.falar(achou.texto));
    setState(() {
      _achadas.add(achou.texto);
      _preview = [];
      _moedas += pontos;
      _xp += pontos;
      _moedasRodada += pontos;
    });
    if (_achadas.length >= _grade.escondidas.length) {
      await _fimDeRodada();
    }
  }

  Future<void> _fimDeRodada() async {
    unawaited(Fala.instance.falar('Você achou todas! Parabéns!'));
    final deNovo = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        scrollable: true,
        title: const Text('Você achou todas!'),
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
            child: const Text('Nova caçada'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (deNovo == true) {
      _novaCacada();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _novaCacada() {
    setState(() {
      _grade = gerarGrade(_pool,
          tamanho: _tamanho,
          direcoes: _direcoes,
          nPalavras: _nPalavras,
          rng: Random());
      _achadas.clear();
      _preview = [];
      _ancora = null;
      _moedasRodada = 0;
    });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Topo fino: voltar + título + ouvir + moedas.
              Row(
                children: [
                  _BotaoCaca(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    tooltip: 'Voltar',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _BotaoCaca(
                    icon: Icons.volume_up_rounded,
                    onTap: _falarPrimeira,
                    tooltip: 'Ouvir palavra',
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
              const SizedBox(height: 8),
              // Corpo: grade quadrada + lista de palavras.
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final lado = c.maxWidth < c.maxHeight
                              ? c.maxWidth
                              : c.maxHeight;
                          return Center(
                            child: SizedBox(
                              width: lado,
                              height: lado,
                              child: _Grade(
                                grade: _grade,
                                achadas: _celulasAchadas,
                                preview: _preview,
                                onInicio: (local) =>
                                    _inicioArrasto(local, lado),
                                onMover: (local) =>
                                    _atualizaArrasto(local, lado),
                                onFim: _fimArrasto,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'ACHE AS PALAVRAS '
                            '(${_achadas.length}/${_grade.escondidas.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: ListView(
                              children: [
                                for (final e in _grade.escondidas)
                                  _ItemLista(
                                    texto: e.texto,
                                    achada:
                                        _achadas.contains(e.texto),
                                    onTap: () => unawaited(
                                        Fala.instance.falar(e.texto)),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: _BotaoCacaTexto(
                                  icon: Icons.home_rounded,
                                  texto: 'SAIR',
                                  onTap: () =>
                                      Navigator.of(context).pop(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _BotaoCacaTexto(
                                  icon: Icons.refresh_rounded,
                                  texto: 'NOVA CAÇADA',
                                  onTap: _novaCacada,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A grade: quadrados com uma letra cada; o arrasto pinta o preview e o
/// acerto fica verde. A letra é filha do quadrado (fica sempre por cima da
/// cor de fundo — o traço do dedo nunca cobre a letra).
class _Grade extends StatelessWidget {
  const _Grade({
    required this.grade,
    required this.achadas,
    required this.preview,
    required this.onInicio,
    required this.onMover,
    required this.onFim,
  });

  final GradeCaca grade;
  final Set<Pos> achadas;
  final List<Pos> preview;
  final ValueChanged<Offset> onInicio;
  final ValueChanged<Offset> onMover;
  final VoidCallback onFim;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cel = c.maxWidth / grade.tamanho;
        // Letra proporcional à célula (37px -> ~19px): legível sem vazar.
        final fonte = (cel * 0.52).clamp(15.0, 30.0);
        final previewSet = preview.toSet();
        return GestureDetector(
          key: const Key('caca-grade'),
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => onInicio(d.localPosition),
          onPanUpdate: (d) => onMover(d.localPosition),
          onPanEnd: (_) => onFim(),
          onPanCancel: onFim,
          child: Column(
            children: [
              for (var r = 0; r < grade.tamanho; r++)
                Expanded(
                  child: Row(
                    children: [
                      for (var cc = 0; cc < grade.tamanho; cc++)
                        Expanded(
                          child: Container(
                            key: Key('caca-cel-$r-$cc'),
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: achadas.contains(Pos(r, cc))
                                  ? const Color(0xFF2E9D44)
                                  : previewSet.contains(Pos(r, cc))
                                      ? Colors.lightBlue
                                          .withValues(alpha: 0.45)
                                      : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: achadas.contains(Pos(r, cc))
                                    ? Colors.white
                                    : previewSet.contains(Pos(r, cc))
                                        ? Colors.lightBlueAccent
                                        : Colors.white24,
                                width:
                                    previewSet.contains(Pos(r, cc)) ||
                                            achadas.contains(Pos(r, cc))
                                        ? 2.5
                                        : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                grade.celulas[r][cc],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fonte,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Uma palavra da lista: toque fala a palavra; achada fica riscada e verde.
class _ItemLista extends StatelessWidget {
  const _ItemLista(
      {required this.texto, required this.achada, required this.onTap});

  final String texto;
  final bool achada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: achada
            ? const Color(0xFF2E9D44)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: Key('caca-lista-$texto'),
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Text(
                  achada ? '[X]' : '[ ]',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    texto.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      decoration:
                          achada ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
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
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

/// Botão retangular translúcido (sair / nova caçada).
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  texto,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
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
