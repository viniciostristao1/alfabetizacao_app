import 'package:flutter/material.dart';

import '../../models/conta.dart';
import '../../models/estudo_opcoes.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';
import '../estudo/desenho.dart';
import '../estudo/feedback_pontos.dart';

/// Tela de estudo das CONTAS (PAISAGEM): mostra uma conta grande (ex.: "12 + 7 ="),
/// a criança digita o resultado num teclado numérico e o app diz se acertou. Cada
/// acerto vale **+1** (conta de 1 dígito) ou **+2** (2 dígitos) moedas.
class ContaEstudoScreen extends StatefulWidget {
  const ContaEstudoScreen({
    super.key,
    required this.titulo,
    required this.contas,
  });

  final String titulo;
  final List<Conta> contas;

  @override
  State<ContaEstudoScreen> createState() => _ContaEstudoScreenState();
}

class _ContaEstudoScreenState extends State<ContaEstudoScreen> {
  int _i = 0;
  String _resposta = '';
  bool _travado = false; // trava enquanto mostra o acerto e avança
  bool? _certo; // null = neutro, true = verde, false = vermelho
  int _acertos = 0;

  int _moedas = 0;
  int _xp = 0;
  String? _feedback; // "+1" / "+2" flutuando sobre a conta (acerto)
  int _feedbackSeq = 0; // key nova a cada feedback (reinicia a animação)

  // ── cor de fundo + escrever/rabiscar (igual à tela de palavras) ──
  FundoTela _fundo = FundoTela.preto;
  CorCaneta _caneta = CorCaneta.azul;
  final List<Traco> _tracos = [];

  void _inicioTraco(PointerDownEvent e) {
    setState(() => _tracos.add(Traco(_caneta.cor)..pontos.add(e.localPosition)));
  }

  void _moveTraco(PointerMoveEvent e) {
    if (_tracos.isEmpty) return;
    setState(() => _tracos.last.pontos.add(e.localPosition));
  }

  void _limparDesenho() => setState(_tracos.clear);

  void _desfazer() {
    if (_tracos.isEmpty) return;
    setState(() => _tracos.removeLast());
  }

  @override
  void initState() {
    super.initState();
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

  Conta get _conta => widget.contas[_i];

  void _digitar(String d) {
    if (_travado) return;
    if (_resposta.length >= 3) return;
    setState(() {
      _resposta += d;
      _certo = null;
    });
  }

  void _apagar() {
    if (_travado || _resposta.isEmpty) return;
    setState(() {
      _resposta = _resposta.substring(0, _resposta.length - 1);
      _certo = null;
    });
  }

  Future<void> _conferir() async {
    if (_travado || _resposta.isEmpty) return;
    final val = int.tryParse(_resposta);
    if (val == _conta.resultado) {
      setState(() {
        _certo = true;
        _travado = true;
        _feedback = '+${_conta.pontos}';
        _feedbackSeq++;
      });
      await ProgressoRepository.registrarAcerto(_conta.pontos);
      _acertos++;
      await _carregarPontuacao();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      if (_i >= widget.contas.length - 1) {
        await _fim();
      } else {
        setState(() {
          _i++;
          _resposta = '';
          _certo = null;
          _travado = false;
          _feedback = null;
          _tracos.clear();
        });
      }
    } else {
      setState(() => _certo = false);
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() {
          _resposta = '';
          _certo = null;
        });
      }
    }
  }

  /// Navega entre contas SEM responder (passar/voltar). Limpa a resposta.
  void _irPara(int novo) {
    if (novo < 0 || novo >= widget.contas.length) return;
    setState(() {
      _i = novo;
      _resposta = '';
      _certo = null;
      _travado = false;
      _feedback = null;
      _tracos.clear();
    });
  }

  Future<void> _fim() async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Muito bem! 🎉'),
        content: Text(
          'Você acertou $_acertos de ${widget.contas.length} contas.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ui = _fundo.corLetra; // cor do texto sobre o fundo atual
    final corResposta = switch (_certo) {
      true => AppColors.acerto,
      false => AppColors.danger,
      _ => ui,
    };
    return Scaffold(
      backgroundColor: _fundo.cor,
      body: SafeArea(
        child: Column(
          children: [
            _TopoContas(
              titulo: widget.titulo,
              progresso: '${_i + 1} / ${widget.contas.length}',
              moedas: _moedas,
              nivel: ProgressoRepository.nivelDe(_xp),
              ui: ui,
              fundo: _fundo,
              onFundo: (f) => setState(() => _fundo = f),
              onVoltar: () => Navigator.of(context).pop(),
              onInicio: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _colunaCaneta(ui),
                  // conta + navegação, com camada de desenho por cima (caderno)
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Listener(
                            behavior: HitTestBehavior.opaque,
                            onPointerDown: _inicioTraco,
                            onPointerMove: _moveTraco,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline:
                                              TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              '${_conta.enunciado} =',
                                              style: TextStyle(
                                                fontSize: 84,
                                                fontWeight: FontWeight.w800,
                                                color: ui,
                                              ),
                                            ),
                                            const SizedBox(width: 18),
                                            SizedBox(
                                              width: 150,
                                              child: Text(
                                                _resposta.isEmpty
                                                    ? '?'
                                                    : _resposta,
                                                style: TextStyle(
                                                  fontSize: 84,
                                                  fontWeight: FontWeight.w900,
                                                  color: corResposta,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: DesenhoPainter(_tracos),
                                    ),
                                  ),
                                ),
                                // feedback "+1" / "+2" (acerto) — no topo,
                                // CENTRALIZADO (não fica sobre a conta).
                                if (_feedback != null)
                                  Positioned(
                                    top: 4,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: PontosFeedback(
                                        key: ValueKey(_feedbackSeq),
                                        texto: _feedback!,
                                        onFim: () =>
                                            setState(() => _feedback = null),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _NavBtn(
                                icon: Icons.chevron_left_rounded,
                                label: 'Anterior',
                                onTap: _i > 0 ? () => _irPara(_i - 1) : null,
                              ),
                              const SizedBox(width: 12),
                              _NavBtn(
                                icon: Icons.chevron_right_rounded,
                                label: 'Próximo',
                                onTap: _i < widget.contas.length - 1
                                    ? () => _irPara(_i + 1)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // teclado numérico à direita
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 12, 10),
                    child: _Teclado(
                      onDigito: _digitar,
                      onApagar: _apagar,
                      onConferir: _conferir,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Coluna de canetas à esquerda (cores + vassoura + desfazer).
  Widget _colunaCaneta(Color ui) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in CorCaneta.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: BolinhaCor(
                cor: c.cor,
                selecionada: c == _caneta,
                contraste: ui,
                onTap: () => setState(() => _caneta = c),
              ),
            ),
          const SizedBox(height: 3),
          BotaoIconeDesenho(
            icon: Icons.cleaning_services_rounded,
            cor: ui,
            onTap: _tracos.isEmpty ? null : _limparDesenho,
            tooltip: 'Limpar tudo',
          ),
          const SizedBox(height: 8),
          BotaoIconeDesenho(
            icon: Icons.undo_rounded,
            cor: ui,
            onTap: _tracos.isEmpty ? null : _desfazer,
            tooltip: 'Apagar o último rabisco',
          ),
        ],
      ),
    );
  }
}

/// Botão de navegação (Anterior/Próximo) — passar/voltar conta sem responder.
class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    final cor = on ? AppColors.text : AppColors.dim2;
    return Material(
      color: on ? AppColors.surface2 : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: cor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                    color: cor, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopoContas extends StatelessWidget {
  const _TopoContas({
    required this.titulo,
    required this.progresso,
    required this.moedas,
    required this.nivel,
    required this.ui,
    required this.fundo,
    required this.onFundo,
    required this.onVoltar,
    required this.onInicio,
  });

  final String titulo;
  final String progresso;
  final int moedas;
  final int nivel;
  final Color ui;
  final FundoTela fundo;
  final ValueChanged<FundoTela> onFundo;
  final VoidCallback onVoltar;
  final VoidCallback onInicio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onVoltar,
            icon: const Icon(Icons.arrow_back_rounded),
            color: ui,
            tooltip: 'Voltar',
          ),
          // título + bolinhas de COR DE FUNDO (trocar o fundo, como nas palavras)
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    titulo,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ui.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                for (final f in FundoTela.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: BolinhaCor(
                      cor: f.cor,
                      selecionada: f == fundo,
                      contraste: ui,
                      onTap: () => onFundo(f),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            progresso,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ui.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '🪙 $moedas · Nv $nivel',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            onPressed: onInicio,
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text('Início'),
            style: TextButton.styleFrom(foregroundColor: ui),
          ),
        ],
      ),
    );
  }
}

/// Teclado numérico (1-9, ⌫, 0, ✓). Layout compacto para a lateral em paisagem.
class _Teclado extends StatelessWidget {
  const _Teclado({
    required this.onDigito,
    required this.onApagar,
    required this.onConferir,
  });

  final ValueChanged<String> onDigito;
  final VoidCallback onApagar;
  final VoidCallback onConferir;

  @override
  Widget build(BuildContext context) {
    Widget tecla(String d) => _Tecla(label: d, onTap: () => onDigito(d));
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [tecla('1'), tecla('2'), tecla('3')]),
          Row(children: [tecla('4'), tecla('5'), tecla('6')]),
          Row(children: [tecla('7'), tecla('8'), tecla('9')]),
          Row(
            children: [
              _Tecla(
                icon: Icons.backspace_rounded,
                onTap: onApagar,
                cor: AppColors.surface,
              ),
              tecla('0'),
              _Tecla(
                icon: Icons.check_rounded,
                onTap: onConferir,
                cor: AppColors.accent,
                corIcone: AppColors.onAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tecla extends StatelessWidget {
  const _Tecla({
    this.label,
    this.icon,
    required this.onTap,
    this.cor,
    this.corIcone,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? cor;
  final Color? corIcone;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: cor ?? AppColors.surface2,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: SizedBox(
              height: 56,
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 26, color: corIcone ?? AppColors.text)
                    : Text(
                        label!,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
