import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../models/palavra.dart';
import '../../services/banco_palavras.dart';
import '../../services/escrever_palavras.dart';
import '../../theme/app_colors.dart';
import '../estudo/estudo_screen.dart';

/// Tela "Escrever" (RETRATO): a pessoa digita qualquer palavra, toca no **+**
/// e monta a própria lista (mesmo clima da tela "Selecionar animais" — campo,
/// lista com botão e "Confirmar"). Ao confirmar, as palavras rodam na
/// EstudoScreen como as demais. A lista fica salva entre sessões.
class EscreverScreen extends StatefulWidget {
  const EscreverScreen({super.key});

  @override
  State<EscreverScreen> createState() => _EscreverScreenState();
}

class _EscreverScreenState extends State<EscreverScreen> {
  final _campo = TextEditingController();
  List<String> _palavras = [];

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
    final salvas = await EscreverPalavras.carregar();
    if (mounted) setState(() => _palavras = salvas);
  }

  Future<void> _salvar() => EscreverPalavras.salvar(_palavras);

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  void _adicionar() {
    final nova = _campo.text.trim();
    if (nova.isEmpty) {
      _avisar('Digite uma palavra primeiro');
      return;
    }
    if (_palavras.any((p) => semAcento(p) == semAcento(nova))) {
      _avisar('Essa palavra já está na lista');
      return;
    }
    setState(() => _palavras = [..._palavras, nova]);
    _campo.clear();
    _salvar();
  }

  void _remover(String texto) {
    setState(() => _palavras = _palavras.where((p) => p != texto).toList());
    _salvar();
  }

  void _confirmar() {
    // Uma palavra por "sílaba" — a EstudoScreen só usa o texto; a ordem fica a
    // da lista (quem montou escolheu).
    final palavras = [
      for (final w in _palavras) Palavra([w], Categoria.escrever),
    ];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${Categoria.escrever.emoji}  Minhas palavras',
          palavras: palavras,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = _palavras.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(n == 0 ? 'Escrever' : 'Escrever ($n)'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: n == 0 ? null : _confirmar,
        backgroundColor: n == 0 ? AppColors.surface2 : AppColors.accent,
        foregroundColor: n == 0 ? AppColors.dim2 : AppColors.onAccent,
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(n == 0 ? 'Confirmar' : 'Confirmar ($n)'),
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
                        hintText: 'Escreva uma palavra…',
                        prefixIcon: const Icon(Icons.edit_rounded),
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
              child: _palavras.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma palavra ainda.\n'
                        'Escreva uma acima e toque no +',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.dim),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                      itemCount: _palavras.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColors.line),
                      itemBuilder: (_, i) {
                        final texto = _palavras[i];
                        return ListTile(
                          title: Text(
                            texto[0].toUpperCase() + texto.substring(1),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
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
