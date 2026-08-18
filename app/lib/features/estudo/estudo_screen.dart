import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/categoria.dart';
import '../../models/palavra.dart';
import '../../theme/app_colors.dart';

/// Tela de estudo (PAISAGEM): mostra uma palavra grande de cada vez, com os
/// botões embaixo. Só texto — sem áudio nem figura (MVP). A palavra aparece em
/// CAIXA ALTA por ser mais legível para quem está começando a ler.
///
/// A tela FORÇA paisagem ao abrir e RESTAURA o retrato ao sair (tanto pelo botão
/// "Voltar" quanto pelo "voltar" do sistema — via [dispose]).
class EstudoScreen extends StatefulWidget {
  const EstudoScreen({
    super.key,
    required this.categoria,
    required this.nivel,
    required this.palavras,
  });

  final Categoria categoria;
  final Nivel nivel;
  final List<Palavra> palavras;

  @override
  State<EstudoScreen> createState() => _EstudoScreenState();
}

class _EstudoScreenState extends State<EstudoScreen> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Volta o app para retrato ao sair desta tela.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  bool get _temAnterior => _i > 0;
  bool get _temProximo => _i < widget.palavras.length - 1;

  void _anterior() {
    if (_temAnterior) setState(() => _i--);
  }

  void _proximo() {
    if (_temProximo) setState(() => _i++);
  }

  void _recomecar() => setState(() => _i = 0);

  void _sair() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final palavra = widget.palavras[_i];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho leve: categoria/nível + progresso "3 / 12".
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Text(
                    '${widget.categoria.emoji}  ${widget.categoria.rotulo} · ${widget.nivel.rotulo}',
                    style: const TextStyle(color: AppColors.dim, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '${_i + 1} / ${widget.palavras.length}',
                    style: const TextStyle(
                      color: AppColors.dim,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // A PALAVRA (ocupa o centro; escala para caber, mesmo as longas).
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      palavra.texto.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 180,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Botões embaixo.
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
              child: Row(
                children: [
                  _Botao(
                    icon: Icons.home_rounded,
                    label: 'Voltar',
                    onTap: _sair,
                  ),
                  _Botao(
                    icon: Icons.chevron_left_rounded,
                    label: 'Anterior',
                    onTap: _temAnterior ? _anterior : null,
                  ),
                  _Botao(
                    icon: Icons.restart_alt_rounded,
                    label: 'Recomeçar',
                    onTap: _i == 0 ? null : _recomecar,
                  ),
                  _Botao(
                    icon: Icons.chevron_right_rounded,
                    label: 'Próximo',
                    onTap: _temProximo ? _proximo : null,
                    destaque: true,
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

/// Botão da barra inferior. `destaque` = preenchido com o accent (o "Próximo").
class _Botao extends StatelessWidget {
  const _Botao({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destaque = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    final fg = destaque
        ? AppColors.onAccent
        : (habilitado ? AppColors.text : AppColors.dim2);
    final bg = !habilitado
        ? AppColors.surface
        : (destaque ? AppColors.accent : AppColors.surface2);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: fg, size: 28),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
