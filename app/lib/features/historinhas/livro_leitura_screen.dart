import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/livro.dart';
import '../../services/config_historinha_fonte.dart';
import '../../services/fala.dart';
import '../../theme/app_colors.dart';

class LivroLeituraScreen extends StatefulWidget {
  const LivroLeituraScreen({super.key, required this.livro});

  final Livro livro;

  @override
  State<LivroLeituraScreen> createState() => _LivroLeituraScreenState();
}

class _LivroLeituraScreenState extends State<LivroLeituraScreen> {
  int _pagina = 0;
  FonteHistorinha _fonte = FonteHistorinha.maiuscula;
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    _carregarFonte();
  }

  Future<void> _carregarFonte() async {
    final f = await ConfigHistorinhaFonte.carregar();
    if (mounted) setState(() => _fonte = f);
    _falarPagina();
  }

  void _mudarFonte(FonteHistorinha f) {
    setState(() => _fonte = f);
    ConfigHistorinhaFonte.salvar(f);
  }

  void _falarPagina() {
    unawaited(Fala.instance.falar(widget.livro.paginas[_pagina]));
  }

  void _irPara(int idx) {
    if (idx < 0 || idx >= widget.livro.totalPaginas) return;
    _controller.animateToPage(
      idx,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final livro = widget.livro;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D24),
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${livro.emoji}  ${livro.titulo}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_pagina + 1} / ${livro.totalPaginas}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                const Text('Fonte:',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                SegmentedButton<FonteHistorinha>(
                  segments: [
                    for (final f in FonteHistorinha.values)
                      ButtonSegment(value: f, label: Text(f.rotulo, style: const TextStyle(fontSize: 12))),
                  ],
                  selected: {_fonte},
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onSelectionChanged: (s) => _mudarFonte(s.first),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Ouvir a página',
                  onPressed: _falarPagina,
                  icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.white12),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) {
                setState(() => _pagina = i);
                HapticFeedback.selectionClick();
                _falarPagina();
              },
              itemCount: livro.totalPaginas,
              itemBuilder: (context, i) {
                final texto = _fonte.aplicar(livro.paginas[i]);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: livro.cor.withValues(alpha: 0.35), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          livro.imagemDaPagina(i),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(color: const Color(0xFFFFF8E7)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.20),
                                Colors.white.withValues(alpha: 0.20),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 14,
                          child: Text(
                            livro.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(28, 44, 28, 24),
                            child: Text(
                              texto,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                height: 1.45,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1D24),
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(color: Colors.white, blurRadius: 8),
                                  Shadow(color: Colors.white, blurRadius: 16),
                                  Shadow(color: Colors.white, blurRadius: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'p. ${i + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  _NavBotao(
                    icon: Icons.arrow_back_rounded,
                    label: 'Voltar',
                    enabled: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  _NavBotao(
                    icon: Icons.chevron_left_rounded,
                    label: 'Anterior',
                    enabled: _pagina > 0,
                    onTap: () => _irPara(_pagina - 1),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < livro.totalPaginas; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _pagina ? livro.cor : Colors.white24,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  _NavBotao(
                    icon: Icons.chevron_right_rounded,
                    label: _pagina == livro.totalPaginas - 1 ? 'Fim' : 'Próxima',
                    enabled: _pagina < livro.totalPaginas - 1,
                    destaque: true,
                    onTap: () => _irPara(_pagina + 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBotao extends StatelessWidget {
  const _NavBotao({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.destaque = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: destaque ? AppColors.accent : Colors.white12,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: destaque ? AppColors.onAccent : Colors.white),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: destaque ? AppColors.onAccent : Colors.white,
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
