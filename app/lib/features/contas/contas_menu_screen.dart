import 'package:flutter/material.dart';

import '../../models/conta.dart';
import '../../services/gerador_contas.dart';
import '../../theme/app_colors.dart';
import 'conta_estudo_screen.dart';
import 'escrever_contas_screen.dart';

/// Menu do tema **Contas** (PAISAGEM): escolher soma/subtração/mistas × 1 ou 2
/// dígitos, ou **escrever contas** próprias. Cada opção abre o estudo das contas.
class ContasMenuScreen extends StatelessWidget {
  const ContasMenuScreen({super.key});

  static const _presets = <(OperacaoConta, int, String, String)>[
    (OperacaoConta.soma, 1, '➕ Soma', '1 dígito'),
    (OperacaoConta.soma, 2, '➕ Soma', '2 dígitos'),
    (OperacaoConta.subtracao, 1, '➖ Subtração', '1 dígito'),
    (OperacaoConta.subtracao, 2, '➖ Subtração', '2 dígitos'),
    (OperacaoConta.mistas, 1, '➕➖ Mistas', '1 dígito'),
    (OperacaoConta.mistas, 2, '➕➖ Mistas', '2 dígitos'),
  ];

  void _abrir(BuildContext context, OperacaoConta op, int digitos, String rotulo,
      String sub) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContaEstudoScreen(
          titulo: '🧮  $rotulo · $sub',
          contas: gerarContas(operacao: op, digitos: digitos),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contas 🧮')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Escolha o tipo de conta (você seleciona 1 ou 2 dígitos)',
                style: TextStyle(fontSize: 15, color: AppColors.dim),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.3,
                  children: [
                    for (final (op, dig, rotulo, sub) in _presets)
                      _ContaCard(
                        titulo: rotulo,
                        sub: sub,
                        cor: op == OperacaoConta.soma
                            ? const Color(0xFF54C08A)
                            : op == OperacaoConta.subtracao
                                ? const Color(0xFFFF8A5B)
                                : const Color(0xFF5B9CFF),
                        onTap: () => _abrir(context, op, dig, rotulo, sub),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Escrever contas (o pai/mãe sugere contas próprias).
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EscreverContasScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFF472B6).withValues(alpha: 0.55),
                          width: 1.5,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('✏️', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 10),
                          Text(
                            'Escrever contas (sugerir as suas)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
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
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cor.withValues(alpha: 0.55), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(fontSize: 13, color: AppColors.dim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
