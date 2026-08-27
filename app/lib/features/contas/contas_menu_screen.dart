import 'package:flutter/material.dart';

import '../../models/conta.dart';
import '../../services/gerador_contas.dart';
import 'conta_estudo_screen.dart';
import 'escrever_contas_screen.dart';

/// Menu do tema **Contas** (PAISAGEM, tela cheia): soma/subtração/mistas × 1 ou 2
/// dígitos, **até 20**, ou **escrever contas**. Tudo cabe numa grade 4×2 (sem
/// rolar — aproveita a tela deitada).
class ContasMenuScreen extends StatelessWidget {
  const ContasMenuScreen({super.key});

  static const _verde = Color(0xFF4CAF50);
  static const _laranja = Color(0xFFF44336);
  static const _azul = Color(0xFF2196F3);
  static const _teal = Color(0xFF9C27B0);
  static const _rosa = Color(0xFFFF9800);

  void _estudo(BuildContext context, String titulo, List<Conta> contas) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContaEstudoScreen(titulo: titulo, contas: contas),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cada item: (rótulo, sub, cor, ação).
    final itens = <(String, String, Color, VoidCallback)>[
      ('+ Soma', '1 dígito', _verde, () => _estudo(context, '🧮  Soma · 1 dígito',
          gerarContas(operacao: OperacaoConta.soma, digitos: 1))),
      ('+ Soma', '2 dígitos', _verde, () => _estudo(context, '🧮  Soma · 2 dígitos',
          gerarContas(operacao: OperacaoConta.soma, digitos: 2))),
      ('− Subtração', '1 dígito', _laranja, () => _estudo(
          context, '🧮  Subtração · 1 dígito',
          gerarContas(operacao: OperacaoConta.subtracao, digitos: 1))),
      ('− Subtração', '2 dígitos', _laranja, () => _estudo(
          context, '🧮  Subtração · 2 dígitos',
          gerarContas(operacao: OperacaoConta.subtracao, digitos: 2))),
      ('+− Mistas', '1 dígito', _azul, () => _estudo(context, '🧮  Mistas · 1 dígito',
          gerarContas(operacao: OperacaoConta.mistas, digitos: 1))),
      ('+− Mistas', '2 dígitos', _azul, () => _estudo(context, '🧮  Mistas · 2 dígitos',
          gerarContas(operacao: OperacaoConta.mistas, digitos: 2))),
      ('🔟 Até 20', 'soma até 20', _teal,
          () => _estudo(context, '🧮  Até 20', gerarContasAte(20))),
      ('✏️ Escrever', 'as suas contas', _rosa, () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EscreverContasScreen()))),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/contas/contas_fundo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.22)),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: SafeArea(
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 80, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      children: [
                        for (final (rotulo, sub, cor, onTap) in itens)
                          _ContaCard(
                              titulo: rotulo, sub: sub, cor: cor, onTap: onTap),
                      ],
                    ),
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

class _ContaCard extends StatelessWidget {
  const _ContaCard({
    required this.titulo,
    required this.sub,
    required this.cor,
    required this.onTap,
  });

  final String titulo;
  final String sub;
  final Color cor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: _TituloComSimbolo(titulo: titulo),
              ),
              const SizedBox(height: 1),
              Text(
                sub,
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TituloComSimbolo extends StatelessWidget {
  const _TituloComSimbolo({required this.titulo});
  final String titulo;
  @override
  Widget build(BuildContext context) {
    if (titulo.startsWith('+−') || titulo.startsWith('+-')) {
      return RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          children: [
            TextSpan(text: '+− ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            TextSpan(text: 'Mistas', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      );
    }
    if (titulo.startsWith('+ ')) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(text: '+ ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            TextSpan(text: titulo.substring(2), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      );
    }
    if (titulo.startsWith('− ')) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(text: '− ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            TextSpan(text: titulo.substring(2), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      );
    }
    return Text(
      titulo,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
    );
  }
}
