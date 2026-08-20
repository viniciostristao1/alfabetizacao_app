import 'package:flutter/material.dart';

import '../../models/modo_leitura.dart';
import '../../models/regiao.dart';
import '../../services/config_leitura.dart';
import '../../services/config_ordem.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';

/// Configurações. Por enquanto:
///  - **Pontuação:** o pai/mãe ajusta as moedas 🪙 e o nível ⭐ do Davi
///    (ex.: começar de novo, acertar a contagem);
///  - **Ordem das fases** do mapa-múndi — arrasta pra decidir em que sequência
///    as categorias de animais rodam (Ártico, Fazenda, Aves…).
/// Salvo local (ConfigOrdem / ProgressoRepository).
class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  List<Regiao>? _fases;
  int _moedas = 0;
  int _xp = 0;
  ModoLeitura _modo = ModoLeitura.maiuscula;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final fases = await ConfigOrdem.fases();
    final moedas = await ProgressoRepository.moedas();
    final xp = await ProgressoRepository.xp();
    final modo = await ConfigLeitura.carregar();
    if (mounted) {
      setState(() {
        _fases = fases;
        _moedas = moedas;
        _xp = xp;
        _modo = modo;
      });
    }
  }

  void _mudarModo(ModoLeitura modo) {
    setState(() => _modo = modo);
    ConfigLeitura.salvar(modo);
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

  void _mudarMoedas(int delta) {
    final novo = (_moedas + delta).clamp(0, 999999);
    setState(() => _moedas = novo);
    ProgressoRepository.salvarMoedas(novo);
  }

  void _mudarNivel(int delta) {
    // O nível é derivado do XP; editar o nível ajusta o XP correspondente.
    final nivelAtual = ProgressoRepository.nivelDe(_xp);
    final novoNivel = (nivelAtual + delta).clamp(1, 99);
    if (novoNivel == nivelAtual) return;
    final novoXp = (novoNivel - 1) * ProgressoRepository.xpPorNivel;
    setState(() => _xp = novoXp);
    ProgressoRepository.salvarXp(novoXp);
  }

  /// Zera as moedas e o nível (XP) — "começar do zero". Pede confirmação.
  Future<void> _zerarPontuacao() async {
    final zerar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zerar tudo?'),
        content: const Text(
          'As moedas e o nível do Davi voltam a zero.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Zerar'),
          ),
        ],
      ),
    );
    if (zerar != true || !mounted) return;
    setState(() {
      _moedas = 0;
      _xp = 0;
    });
    await ProgressoRepository.salvarMoedas(0);
    await ProgressoRepository.salvarXp(0);
  }

  /// A seção de pontuação é o ITEM 0 da lista (não é arrastável).
  Widget _secaoPontuacao() {
    return Padding(
      key: const ValueKey('pontuacao'),
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pontuação',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ajuste as moedas e o nível do Davi (o toque muda 1; segurar '
            'pressionado muda 10 nas moedas).',
            style: TextStyle(color: AppColors.dim),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppColors.surface,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Text('🪙', style: TextStyle(fontSize: 24)),
                  title: const Text('Moedas',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BotaoMaisMenos(
                        icon: Icons.restart_alt_rounded,
                        tooltip: 'Zerar moedas e nível',
                        onTap: _zerarPontuacao,
                      ),
                      const SizedBox(width: 8),
                      _BotaoMaisMenos(
                        icon: Icons.remove_rounded,
                        onTap: () => _mudarMoedas(-1),
                        onLongPress: () => _mudarMoedas(-10),
                      ),
                      SizedBox(
                        width: 56,
                        child: Center(
                          child: Text('$_moedas',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      _BotaoMaisMenos(
                        icon: Icons.add_rounded,
                        onTap: () => _mudarMoedas(1),
                        onLongPress: () => _mudarMoedas(10),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.line),
                ListTile(
                  leading: const Text('⭐', style: TextStyle(fontSize: 24)),
                  title: const Text('Nível',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BotaoMaisMenos(
                        icon: Icons.remove_rounded,
                        onTap: () => _mudarNivel(-1),
                      ),
                      SizedBox(
                        width: 56,
                        child: Center(
                          child: Text(
                              'Nv ${ProgressoRepository.nivelDe(_xp)}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      _BotaoMaisMenos(
                        icon: Icons.add_rounded,
                        onTap: () => _mudarNivel(1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Como mostrar as palavras',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'MAIÚSCULAS (mais fácil de começar) ou minúsculas. '
            '(Em breve: completar a sílaba que falta.)',
            style: TextStyle(color: AppColors.dim),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ModoLeitura>(
            segments: [
              for (final m in ModoLeitura.values)
                ButtonSegment(value: m, label: Text(m.rotulo)),
            ],
            selected: {_modo},
            showSelectedIcon: false,
            onSelectionChanged: (s) => _mudarModo(s.first),
          ),
          const SizedBox(height: 14),
          const Text(
            'Ordem das fases no mapa-múndi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Arraste pelas alças ⠿ para mudar a sequência dos continentes '
            '(África, Ásia, Oceano, Céu…) na aventura do mapa-múndi.',
            style: TextStyle(color: AppColors.dim),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fases = _fases;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: fases == null
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              // item 0 = seção de pontuação; itens 1..n = fases.
              itemCount: fases.length + 1,
              onReorderItem: (velho, novo) {
                if (velho == 0 || novo == 0) return; // não move a pontuação
                _reordenar(velho - 1, novo - 1);
              },
              itemBuilder: (context, i) {
                if (i == 0) return _secaoPontuacao();
                final h = fases[i - 1];
                return Card(
                  key: ValueKey(h.chave),
                  color: AppColors.surface,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surface2,
                      child: Text('$i',
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
    );
  }
}

/// Botão circular "−"/"+" dos ajustes de pontuação.
class _BotaoMaisMenos extends StatelessWidget {
  const _BotaoMaisMenos({
    required this.icon,
    required this.onTap,
    this.onLongPress,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final botao = InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lineStrong),
        ),
        child: Icon(icon, color: AppColors.text, size: 22),
      ),
    );
    return tooltip == null ? botao : Tooltip(message: tooltip!, child: botao);
  }
}
