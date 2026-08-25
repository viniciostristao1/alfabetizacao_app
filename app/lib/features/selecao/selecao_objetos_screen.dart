import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/palavra.dart';
import '../../services/banco_palavras.dart';
import '../../theme/app_colors.dart';

class SelecaoObjetosScreen extends StatefulWidget {
  const SelecaoObjetosScreen({super.key});

  @override
  State<SelecaoObjetosScreen> createState() => _SelecaoObjetosScreenState();
}

class _SelecaoObjetosScreenState extends State<SelecaoObjetosScreen> {
  final _todos = todosOsObjetos();
  final _selecionados = <String>{};
  String _busca = '';

  @override
  void initState() {
    super.initState();
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
        title: Text(n == 0 ? 'Selecionar objetos' : 'Selecionados: $n'),
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
                  hintText: 'Buscar objeto…',
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
                      child: Text('Nenhum objeto encontrado',
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
                        return _LinhaObjeto(
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

class _LinhaObjeto extends StatelessWidget {
  const _LinhaObjeto({
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
