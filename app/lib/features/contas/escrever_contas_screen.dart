import 'package:flutter/material.dart';

import '../../services/contas_escritas.dart';
import '../../services/gerador_contas.dart';
import '../../theme/app_colors.dart';
import 'conta_estudo_screen.dart';

/// "Escrever contas" (RETRATO): o pai/mãe digita contas próprias (ex.: "12 + 7"),
/// toca no **+** e monta a lista. Ao confirmar, as contas rodam no estudo. A
/// lista fica salva entre sessões (ContasEscritas).
class EscreverContasScreen extends StatefulWidget {
  const EscreverContasScreen({super.key});

  @override
  State<EscreverContasScreen> createState() => _EscreverContasScreenState();
}

class _EscreverContasScreenState extends State<EscreverContasScreen> {
  final _campo = TextEditingController();
  List<String> _contas = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    final salvas = await ContasEscritas.carregar();
    if (mounted) setState(() => _contas = salvas);
  }

  Future<void> _salvar() => ContasEscritas.salvar(_contas);

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _adicionar() {
    final texto = _campo.text.trim();
    if (texto.isEmpty) {
      _avisar('Escreva uma conta primeiro (ex.: 12 + 7)');
      return;
    }
    final conta = parseConta(texto);
    if (conta == null) {
      _avisar('Conta inválida. Use "+" ou "−" e sem resultado negativo.');
      return;
    }
    // guarda já normalizada (ex.: "12 + 7")
    final normal = conta.enunciado;
    if (_contas.contains(normal)) {
      _avisar('Essa conta já está na lista');
      return;
    }
    setState(() => _contas = [..._contas, normal]);
    _campo.clear();
    _salvar();
  }

  void _remover(String texto) {
    setState(() => _contas = _contas.where((c) => c != texto).toList());
    _salvar();
  }

  void _confirmar() {
    final contas = [
      for (final t in _contas) ?parseConta(t),
    ];
    if (contas.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContaEstudoScreen(
          titulo: '🧮  Minhas contas',
          contas: contas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = _contas.length;
    return Scaffold(
      appBar: AppBar(title: Text(n == 0 ? 'Escrever contas' : 'Escrever contas ($n)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: n == 0 ? null : _confirmar,
        backgroundColor: n == 0 ? AppColors.surface2 : AppColors.accent,
        foregroundColor: n == 0 ? AppColors.dim2 : AppColors.onAccent,
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(n == 0 ? 'Começar' : 'Começar ($n)'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _campo,
                      onSubmitted: (_) => _adicionar(),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Escreva uma conta (ex.: 12 + 7)',
                        prefixIcon: const Icon(Icons.calculate_rounded),
                        filled: true,
                        fillColor: AppColors.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _adicionar,
                    tooltip: 'Adicionar',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      minimumSize: const Size(52, 52),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 30),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _contas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma conta ainda.\n'
                        'Escreva uma acima (ex.: 12 + 7) e toque no +',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.dim),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                      itemCount: _contas.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColors.line),
                      itemBuilder: (_, i) {
                        final texto = _contas[i];
                        return ListTile(
                          title: Text(
                            texto,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => _remover(texto),
                            tooltip: 'Remover',
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.danger,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
