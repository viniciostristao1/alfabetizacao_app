import 'package:flutter/material.dart';

import '../../models/conta.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';

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
    final corResposta = switch (_certo) {
      true => AppColors.acerto,
      false => AppColors.danger,
      _ => AppColors.text,
    };
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopoContas(
              titulo: widget.titulo,
              progresso: '${_i + 1} / ${widget.contas.length}',
              moedas: _moedas,
              nivel: ProgressoRepository.nivelDe(_xp),
              onVoltar: () => Navigator.of(context).pop(),
              onInicio: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            Expanded(
              child: Row(
                children: [
                  // conta grande à esquerda
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${_conta.enunciado} =',
                                style: const TextStyle(
                                  fontSize: 84,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(width: 18),
                              SizedBox(
                                width: 150,
                                child: Text(
                                  _resposta.isEmpty ? '?' : _resposta,
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
}

class _TopoContas extends StatelessWidget {
  const _TopoContas({
    required this.titulo,
    required this.progresso,
    required this.moedas,
    required this.nivel,
    required this.onVoltar,
    required this.onInicio,
  });

  final String titulo;
  final String progresso;
  final int moedas;
  final int nivel;
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
            tooltip: 'Voltar',
          ),
          Expanded(
            child: Text(
              titulo,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.dim,
              ),
            ),
          ),
          Text(
            progresso,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.dim,
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
