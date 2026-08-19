import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/palavra.dart';
import '../../services/banco_palavras.dart';
import '../../theme/app_colors.dart';

/// Tela "Selecionar animais" (RETRATO): busca com lupa + "+" em cada animal +
/// Confirmar. Devolve (via `Navigator.pop`) a lista escolhida, ordenada do menos
/// ao mais sílabas — a criança começa pelos mais fáceis.
class SelecaoAnimaisScreen extends StatefulWidget {
  const SelecaoAnimaisScreen({super.key});

  @override
  State<SelecaoAnimaisScreen> createState() => _SelecaoAnimaisScreenState();
}

class _SelecaoAnimaisScreenState extends State<SelecaoAnimaisScreen> {
  final _todos = todosOsAnimais();
  final _selecionados = <String>{}; // por texto
  String _busca = '';

  @override
  void initState() {
    super.initState();
    // App todo em PAISAGEM — esta tela também fica deitada, só com as barras
    // do sistema visíveis (é tela de digitação).
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  List<Palavra> get _filtrados {
    if (_busca.trim().isEmpty) return _todos;
    final q = semAcento(_busca.trim());
    return _todos.where((p) => semAcento(p.texto).contains(q)).toList();
  }

  void _alternar(String texto) => setState(() {
        if (!_selecionados.remove(texto)) _selecionados.add(texto);
      });

  void _confirmar() {
    final escolhidos = _todos
        .where((p) => _selecionados.contains(p.texto))
        .toList()
      ..sort((a, b) => a.nivelSilabas.compareTo(b.nivelSilabas));
    Navigator.of(context).pop(escolhidos);
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;
    final n = _selecionados.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(n == 0 ? 'Selecionar animais' : 'Selecionados: $n'),
        actions: [
          if (n > 0)
            TextButton(
              onPressed: () => setState(_selecionados.clear),
              child: const Text('Limpar'),
            ),
        ],
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
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _busca = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar animal…',
                  prefixIcon: const Icon(Icons.search),
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
            Expanded(
              child: filtrados.isEmpty
                  ? const Center(
                      child: Text('Nenhum animal encontrado',
                          style: TextStyle(color: AppColors.dim)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                      itemCount: filtrados.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: AppColors.line),
                      itemBuilder: (_, i) {
                        final p = filtrados[i];
                        final sel = _selecionados.contains(p.texto);
                        return _LinhaAnimal(
                          texto: p.texto,
                          selecionado: sel,
                          onTap: () => _alternar(p.texto),
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

class _LinhaAnimal extends StatelessWidget {
  const _LinhaAnimal({
    required this.texto,
    required this.selecionado,
    required this.onTap,
  });

  final String texto;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        texto[0].toUpperCase() + texto.substring(1),
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        selecionado ? Icons.check_circle_rounded : Icons.add_circle_outline,
        color: selecionado ? AppColors.accent : AppColors.dim,
        size: 28,
      ),
    );
  }
}
