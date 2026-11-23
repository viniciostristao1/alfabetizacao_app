import 'package:flutter/material.dart';

import '../../models/modo_jogo.dart';
import '../../models/modo_leitura.dart';
import '../../models/regiao.dart';
import '../../services/config_fala.dart';
import '../../services/config_leitura.dart';
import '../../services/config_mic.dart';
import '../../services/config_modo.dart';
import '../../services/config_ordem.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';

/// Configurações. Por enquanto:
///  - **Pontuação:** o pai/mãe ajusta as moedas 🪙 e o nível ⭐ do Davi
///    (ex.: começar de novo, acertar a contagem);
///  - **Como mostrar as palavras** (MAIÚSCULAS / minúsculas) e se o app deve
///    **falar** em voz alta;
///  - **Palavra ou frases** (Modo Frases: cada palavra vira 1 frase);
///  - **Ordem das fases** do mapa-múndi — arrasta pra decidir em que sequência
///    as categorias de animais rodam (Ártico, Fazenda, Aves…).
/// Salvo local (ConfigOrdem / ConfigLeitura / ConfigFala / ProgressoRepository).
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
  ModoJogo _jogo = ModoJogo.palavra;
  bool _falar = true;
  bool _mic = true;
  int _micTol = 1;
  bool _ordemExpandida = false;
  // Acordeões: cada seção abre/fecha sozinha. Começam TODAS fechadas a cada
  // entrada na tela (o State nasce zerado); o estado vive aqui no State, então
  // sobrevive a setState de outros controles e à rolagem durante a sessão.
  bool _pontuacaoAberta = false;
  bool _leituraAberta = false;
  bool _jogoAberta = false;
  bool _falarAberta = false;
  bool _micAberta = false;
  bool _tolAberta = false;

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
    final jogo = await ConfigModo.carregar();
    final falar = await ConfigFala.ativado();
    final mic = await ConfigMic.ativado();
    final micTol = await ConfigMic.tolerancia();
    if (mounted) {
      setState(() {
        _fases = fases;
        _moedas = moedas;
        _xp = xp;
        _modo = modo;
        _jogo = jogo;
        _falar = falar;
        _mic = mic;
        _micTol = micTol;
      });
    }
  }

  void _mudarModo(ModoLeitura modo) {
    setState(() => _modo = modo);
    ConfigLeitura.salvar(modo);
  }

  void _mudarJogo(ModoJogo jogo) {
    setState(() => _jogo = jogo);
    ConfigModo.salvar(jogo);
  }

  void _mudarFalar(bool valor) {
    setState(() => _falar = valor);
    ConfigFala.salvar(valor);
  }

  void _mudarMic(bool valor) {
    setState(() => _mic = valor);
    ConfigMic.salvarAtivado(valor);
  }

  void _mudarMicTol(int valor) {
    setState(() => _micTol = valor);
    ConfigMic.salvarTolerancia(valor);
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
  /// Cada bloco é um acordeão RECOLHIDO por padrão (ver [_SecaoAcordeao]).
  Widget _secaoPontuacao() {
    final nivel = ProgressoRepository.nivelDe(_xp);
    const tolRotulos = ['Exato', 'Tolerante', 'Bem tolerante'];
    return Padding(
      key: const ValueKey('pontuacao'),
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SecaoAcordeao(
            titulo: 'Pontuação',
            descricao: 'Ajuste as moedas e o nível do Davi (o toque muda 1; segurar '
                'pressionado muda 10 nas moedas).',
            resumo: '🪙 $_moedas · Nv $nivel',
            aberta: _pontuacaoAberta,
            onToggle: () =>
                setState(() => _pontuacaoAberta = !_pontuacaoAberta),
            filho: Card(
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
                            child: Text('Nv $nivel',
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
          ),
          const SizedBox(height: 14),
          _SecaoAcordeao(
            titulo: 'Como mostrar as palavras',
            descricao: 'MAIÚSCULAS (mais fácil de começar), minúsculas, '
                'Completar (acha a sílaba que falta) ou Ditado (o app fala '
                'e o Davi monta a palavra).',
            resumo: _modo.rotulo,
            aberta: _leituraAberta,
            onToggle: () => setState(() => _leituraAberta = !_leituraAberta),
            filho: SegmentedButton<ModoLeitura>(
              segments: [
                for (final m in ModoLeitura.values)
                  ButtonSegment(value: m, label: Text(m.rotulo)),
              ],
              selected: {_modo},
              showSelectedIcon: false,
              onSelectionChanged: (s) => _mudarModo(s.first),
            ),
          ),
          const SizedBox(height: 14),
          _SecaoAcordeao(
            titulo: 'Palavra ou frases',
            descricao: 'Palavra mostra 1 palavra por vez. Frases mostra 1 frase por '
                'palavra (ex.: LEÃO vira O LEÃO MORA NA SAVANA). No modo frases o '
                'microfone continua ouvindo só a palavra.',
            resumo: _jogo.rotulo,
            aberta: _jogoAberta,
            onToggle: () => setState(() => _jogoAberta = !_jogoAberta),
            filho: SegmentedButton<ModoJogo>(
              segments: const [
                ButtonSegment(value: ModoJogo.palavra, label: Text('🔤 Palavra')),
                ButtonSegment(value: ModoJogo.frase, label: Text('💬 Frases')),
              ],
              selected: {_jogo},
              showSelectedIcon: false,
              onSelectionChanged: (s) => _mudarJogo(s.first),
            ),
          ),
          const SizedBox(height: 14),
          _SecaoAcordeao(
            titulo: 'Falar a palavra',
            descricao: 'O celular lê em voz alta quando aparece (a frase inteira, '
                'no Modo Frases).',
            resumo: _falar ? 'Ligada' : 'Desligada',
            aberta: _falarAberta,
            onToggle: () => setState(() => _falarAberta = !_falarAberta),
            filho: Card(
              color: AppColors.surface,
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                secondary: const Text('🗣️', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'Falar a palavra',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                value: _falar,
                onChanged: _mudarFalar,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SecaoAcordeao(
            titulo: 'Modo microfone 🎤',
            descricao: 'O Davi lê falando: toca no 🎤 na tela das palavras, fala, e o app '
                'decide sozinho (acerta → sobe moeda e passa; erra 3× → o app fala '
                'a palavra e passa).',
            resumo: _mic ? 'Ligado' : 'Desligado',
            aberta: _micAberta,
            onToggle: () => setState(() => _micAberta = !_micAberta),
            filho: Card(
              color: AppColors.surface,
              margin: EdgeInsets.zero,
              child: SwitchListTile(
                secondary: const Text('🎤', style: TextStyle(fontSize: 24)),
                title: const Text(
                  'Ler falando (microfone)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Mostra o botão 🎤 na tela das palavras.',
                  style: TextStyle(color: AppColors.dim),
                ),
                value: _mic,
                onChanged: _mudarMic,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SecaoAcordeao(
            titulo: 'Ajuste fino: tolerância',
            descricao: 'Quanto mais tolerante, mais o app perdoa a pronúncia (voz de '
                'criança erra mais no reconhecimento). "Exato" só aceita a palavra '
                'certinha.',
            resumo: tolRotulos[_micTol.clamp(0, 2)],
            aberta: _tolAberta,
            onToggle: () => setState(() => _tolAberta = !_tolAberta),
            filho: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Exato')),
                ButtonSegment(value: 1, label: Text('Tolerante')),
                ButtonSegment(value: 2, label: Text('Bem tolerante')),
              ],
              selected: {_micTol},
              showSelectedIcon: false,
              // desabilita (fica cinza) quando o microfone está desligado
              onSelectionChanged: _mic ? (s) => _mudarMicTol(s.first) : null,
            ),
          ),
          const SizedBox(height: 14),
          _SecaoAcordeao(
            titulo: 'Ordem das fases no mapa-múndi',
            descricao: 'Arraste pelas alças ⠿ para mudar a sequência dos continentes '
                '(África, Ásia, Oceano, Céu…) na aventura do mapa-múndi.',
            resumo: '${_fases?.length ?? 0} fases',
            aberta: _ordemExpandida,
            onToggle: () =>
                setState(() => _ordemExpandida = !_ordemExpandida),
            // A lista arrastável mora nos ITENS da ReorderableListView (fora
            // daqui) — some/aparece pelo itemCount. Ver build().
            filho: const SizedBox.shrink(),
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
              itemCount: _ordemExpandida ? fases.length + 1 : 1,
              onReorderItem: (velho, novo) {
                if (velho == 0 || novo == 0) return;
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

/// Uma seção recolhível das Configurações: fechada mostra só título +
/// descrição curta (+ resumo do estado atual) e setinha à direita, alinhada
/// ao título; aberta mostra os controles com animação suave (220 ms).
/// O estado (aberta/fechada) mora no State da tela — sobrevive a setState de
/// outros controles e à rolagem durante a sessão; a cada entrada nova na tela
/// tudo começa fechado (os flags nascem `false`).
/// Recolhida, a seção DESMONTA os controles (somem da árvore); aberta,
/// revela com dobra + fade.
class _SecaoAcordeao extends StatefulWidget {
  const _SecaoAcordeao({
    required this.titulo,
    required this.descricao,
    required this.aberta,
    required this.onToggle,
    required this.filho,
    this.resumo,
  });

  final String titulo;
  final String descricao;
  final bool aberta;
  final VoidCallback onToggle;
  final Widget filho;

  /// Resumo do estado atual (ex.: "Tolerante", "Nv 1") — só com a seção
  /// fechada, pra conferir sem precisar abrir.
  final String? resumo;

  static const duracao = Duration(milliseconds: 220);

  @override
  State<_SecaoAcordeao> createState() => _SecaoAcordeaoState();
}

class _SecaoAcordeaoState extends State<_SecaoAcordeao>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    value: widget.aberta ? 1 : 0,
    duration: _SecaoAcordeao.duracao,
  );
  late final Animation<double> _dobra =
      CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void didUpdateWidget(covariant _SecaoAcordeao oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.aberta != oldWidget.aberta) {
      if (widget.aberta) {
        _c.forward();
      } else {
        _c.reverse();
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: widget.onToggle,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.titulo,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (!widget.aberta && widget.resumo != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.resumo!,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.dim,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Área tocável 48×48, centrada na altura do título.
            SizedBox(
              width: 48,
              height: 48,
              child: InkWell(
                onTap: widget.onToggle,
                customBorder: const CircleBorder(),
                child: Center(
                  child: AnimatedRotation(
                    // ❯ fechada → ❯ girada pra baixo quando aberta.
                    turns: widget.aberta ? 0.25 : 0,
                    duration: _SecaoAcordeao.duracao,
                    curve: Curves.easeInOut,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.dim,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Text(
          widget.descricao,
          style: const TextStyle(color: AppColors.dim),
        ),
        AnimatedBuilder(
          animation: _c,
          builder: (_, _) {
            // Recolhida e parada: sem os controles na árvore.
            if (_c.status == AnimationStatus.dismissed && !widget.aberta) {
              return const SizedBox(width: double.infinity);
            }
            return SizeTransition(
              sizeFactor: _dobra,
              alignment: Alignment.topCenter,
              child: FadeTransition(
                opacity: _dobra,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: widget.filho,
                ),
              ),
            );
          },
        ),
      ],
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
