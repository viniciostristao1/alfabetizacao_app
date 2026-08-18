import 'package:flutter/material.dart';

import '../../models/habitat.dart';
import '../../services/config_ordem.dart';
import '../../theme/app_colors.dart';

/// Configurações (RETRATO). Por enquanto: **ordem das fases** do mapa-múndi —
/// a criança/pai arrasta pra decidir em que sequência as categorias de animais
/// rodam (Ártico, Fazenda, Aves…). Salvo local (ConfigOrdem).
class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  List<Habitat>? _fases;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final fases = await ConfigOrdem.fases();
    if (mounted) setState(() => _fases = fases);
  }

  void _reordenar(int velho, int novo) {
    // onReorderItem já entrega o newIndex ajustado (item removido no oldIndex).
    final fases = _fases!;
    setState(() {
      final item = fases.removeAt(velho);
      fases.insert(novo, item);
    });
    ConfigOrdem.salvar(fases.map((h) => h.chave).toList());
  }

  @override
  Widget build(BuildContext context) {
    final fases = _fases;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: fases == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Ordem das fases no mapa-múndi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Arraste pelas alças ⠿ para mudar a sequência em que as '
                    'categorias de animais aparecem na aventura.',
                    style: TextStyle(color: AppColors.dim),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    itemCount: fases.length,
                    onReorderItem: _reordenar,
                    itemBuilder: (context, i) {
                      final h = fases[i];
                      return Card(
                        key: ValueKey(h.chave),
                        color: AppColors.surface,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surface2,
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                          ),
                          title: Text('${h.emoji}  ${h.rotulo}',
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600)),
                          trailing: ReorderableDragStartListener(
                            index: i,
                            child: const Icon(Icons.drag_handle,
                                color: AppColors.dim),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
