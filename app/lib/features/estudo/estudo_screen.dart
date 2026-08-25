import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/alimentos_tema.dart';
import '../../models/estudo_opcoes.dart';
import '../../models/modo_leitura.dart';
import '../../models/palavra.dart';
import '../../models/regiao.dart';
import '../../models/tema.dart';
import '../../services/banco_palavras.dart';
import '../../services/completar_silaba.dart';
import '../../services/config_leitura.dart';
import '../../services/config_ordem.dart';
import '../../services/fala.dart';
import '../../services/progresso_alimentos_fases.dart';
import '../../services/progresso_fases.dart';
import '../../services/progresso_objetos_temas_fases.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';
import 'confete.dart';
import 'desenho.dart';
import 'feedback_pontos.dart';

/// Tela de estudo (PAISAGEM): mostra uma palavra grande de cada vez, com:
///  - **bolinhas de fundo (horizontais)** no topo, ao lado do título — preto,
///    branco, bege escuro, bege claro (a palavra fica branca só no preto);
///  - **bolinhas de caneta (verticais)** à esquerda + um "limpar" — a criança
///    escreve na tela por cima (como um caderno), com caneta capacitiva ou dedo;
///  - **botões baixos** embaixo (Voltar / Anterior / Recomeçar / Próximo).
///
/// Força paisagem ao abrir e RESTAURA o retrato ao sair (botão ou "voltar" do
/// sistema). O desenho é limpo ao trocar de palavra.
class EstudoScreen extends StatefulWidget {
  const EstudoScreen({
    super.key,
    required this.titulo,
    required this.palavras,
    this.manterPaisagemAoSair = false,
    this.habitatConcluivel,
    this.alimentosTemaConcluivel,
    this.objetosTemaConcluivel,
  });

  /// Cabeçalho da tela, ex.: "🍎  Alimentos · Fácil" ou "🐶  Animais · Ártico".
  final String titulo;
  final List<Palavra> palavras;

  /// Se `true`, ao sair volta para PAISAGEM (fluxo do mapa de habitats, que já é
  /// deitado); se `false` (padrão, fluxo de Nível), volta para RETRATO.
  final bool manterPaisagemAoSair;

  /// Se preenchido (chave do habitat), marca a **fase concluída** no
  /// [ProgressoFases] quando a criança chega na última palavra — o mapa-múndi
  /// então acende o círculo e o caminho até a próxima fase.
  final String? habitatConcluivel;

  final String? alimentosTemaConcluivel;

  final String? objetosTemaConcluivel;

  @override
  State<EstudoScreen> createState() => _EstudoScreenState();
}

class _EstudoScreenState extends State<EstudoScreen> {
  int _i = 0;
  FundoTela _fundo = FundoTela.preto;
  CorCaneta _caneta = CorCaneta.azul;
  final List<Traco> _tracos = [];

  // ── gamificação (XP/moedas): carregados no initState e atualizados no V/X ──
  int _moedas = 0;
  int _xp = 0;
  ModoLeitura _modo = ModoLeitura.maiuscula; // MAIÚSCULAS / minúsculas / completar

  // ── modo "completar a sílaba que falta" (múltipla escolha) ──
  int _blankIdx = -1; // sílaba que falta (-1 = palavra sem desafio: <2 sílabas)
  List<String> _opcoes = const []; // 4 opções embaralhadas (MAIÚSCULAS)
  String? _erradaSel; // opção errada tocada (fica vermelha até tentar de novo)
  String? _feedback; // "+4" / "-4" flutuando sobre a palavra
  int _feedbackSeq = 0; // key nova a cada feedback (reinicia a animação)

  // ── sequência de acertos 🔥 + confetes 🎉 ──
  int _sequencia = 0; // acertos seguidos (zera no erro)
  int _confeteSeq = 0; // key nova a cada acerto (reinicia o confete)

  /// A cada [sequenciaAlvo] acertos seguidos, bônus crescente (2, 4, 6…).
  static const _sequenciaAlvo = 3;
  int get _bonusSequencia => (_sequencia ~/ _sequenciaAlvo) * 2;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _carregarGamificacao();
    _talvezConcluir(); // caso o habitat tenha 1 palavra só
  }

  Future<void> _carregarGamificacao() async {
    final moedas = await ProgressoRepository.moedas();
    final xp = await ProgressoRepository.xp();
    final modo = await ConfigLeitura.carregar();
    if (mounted) {
      setState(() {
        _moedas = moedas;
        _xp = xp;
        _modo = modo;
      });
      _prepararIncompleta();
      _falarPalavraAtual();
    }
  }

  /// Fala a palavra atual em voz alta (voz do celular) — a criança ouve o som
  /// enquanto vê a escrita. Disparada ao abrir e ao trocar de palavra.
  void _falarPalavraAtual() {
    unawaited(Fala.instance.falar(widget.palavras[_i].texto));
  }

  /// Monta o desafio "completar a sílaba" da palavra atual (se o modo for esse).
  void _prepararIncompleta() {
    if (_modo != ModoLeitura.incompleta) return;
    final d = montarDesafio(widget.palavras[_i]);
    setState(() {
      _blankIdx = d?.blankIndex ?? -1;
      _opcoes = d?.opcoes ?? const [];
      _erradaSel = null;
    });
  }

  /// Toque numa opção do modo "completar": certa → acerta e avança; errada →
  /// fica vermelha e deixa tentar de novo (não penaliza).
  Future<void> _escolheuIncompleta(String opcao) async {
    if (_blankIdx < 0) {
      await _acertou(); // palavra sem sílaba pra faltar: só avança
      return;
    }
    final correta = widget.palavras[_i].silabas[_blankIdx].toUpperCase();
    if (opcao == correta) {
      setState(() => _erradaSel = null);
      await _acertou();
    } else {
      setState(() => _erradaSel = opcao);
    }
  }

  /// Pontos da palavra atual: 2 × (sílabas − 1) → 2 sílabas = 2, 3 = 4, 4 = 6.
  /// Palavras do usuário (1 sílaba) dão 1 ponto.
  int get _pontosPalavra =>
      (2 * (widget.palavras[_i].nivelSilabas - 1)).clamp(1, 999);

  void _mostrarFeedback(String texto) {
    _feedback = texto;
    _feedbackSeq++;
  }

  /// V verde: acertou → soma pontos (XP + moedas) e avança. Se for a última
  /// palavra de uma fase do mapa-múndi, abre o baú (bônus + medalha).
  /// Sequência de acertos 🔥: a cada 3 seguidas, bônus extra de moedas.
  Future<void> _acertou() async {
    final pontos = _pontosPalavra;
    final habitat = widget.habitatConcluivel;
    await ProgressoRepository.registrarAcerto(pontos, habitat: habitat);
    if (!mounted) return;
    _sequencia++;
    final bonus = _bonusSequencia;
    if (bonus > 0) {
      await ProgressoRepository.registrarBonus(bonus);
    }
    if (!mounted) return;
    HapticFeedback.lightImpact(); // toque leve de "bom!"
    setState(() {
      _moedas += pontos + bonus;
      _xp += pontos + bonus;
      _tracos.clear();
      _confeteSeq++;
      if (bonus > 0) {
        _mostrarFeedback('🔥 $_sequencia seguidas! +$bonus');
      } else {
        _mostrarFeedback('+$pontos');
      }
    });
    final ultima = _i == widget.palavras.length - 1;
    final alimentosTema = widget.alimentosTemaConcluivel;
    final objetosTema = widget.objetosTemaConcluivel;
    if (ultima && habitat != null) {
      await _concluirFase();
    } else if (ultima && alimentosTema != null) {
      await _concluirFaseAlimentos();
    } else if (ultima && objetosTema != null) {
      await _concluirFaseObjetosTemas();
    } else if (ultima) {
      await _fimDeCategoria(); // pode ter SAÍDO da tela ("Sair")
    } else if (_temProximo) {
      setState(() => _i++);
      _falarPalavraAtual();
    }
    if (!mounted) return;
    _prepararIncompleta();
  }

  /// X vermelho: errou → perde os pontos da palavra (nunca abaixo de zero),
  /// ZERA a sequência de acertos 🔥 e a palavra REPETE até acertar (erro vira
  /// aprendizado, não frustração).
  Future<void> _errou() async {
    final pontos = _pontosPalavra;
    final habitat = widget.habitatConcluivel;
    await ProgressoRepository.registrarErro(pontos, habitat: habitat);
    if (!mounted) return;
    HapticFeedback.heavyImpact(); // toque firme de "atenção!"
    setState(() {
      _sequencia = 0;
      _moedas = (_moedas - pontos).clamp(0, 99999);
      _tracos.clear();
      _mostrarFeedback('-$pontos');
    });
  }

  /// Fim de fase no mapa-múndi: o BAÚ (fechado) com bônus de moedas + medalha
  /// pela precisão. O Davi TOCA no baú → ele abre animado e SAI o card da nova
  /// fase ("Você desbloqueou o cenário Ártico!") com "JOGAR AGORA" — o jogo
  /// continua sem voltar ao mapa. Na última fase, o card mostra 🏆.
  Future<void> _concluirFase() async {
    final regiao = Regiao.porChave(widget.habitatConcluivel!);
    await ProgressoRepository.registrarBonusFase();
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _moedas += ProgressoRepository.bonusFase);

    // qual a próxima fase da ordem? (o baú revela o card dela)
    final fases = await ConfigOrdem.fases();
    if (!mounted) return;
    final i = fases.indexWhere((r) => r.chave == widget.habitatConcluivel);
    final proxima =
        (i >= 0 && i < fases.length - 1) ? fases[i + 1] : null;

    final jogar = await showDialog<bool>(
      context: context,
      builder: (_) => _BauDialog(
        regiao: regiao,
        proxima: proxima,
      ),
    );
    if (jogar != true || !mounted || proxima == null) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${proxima.emoji}  Fase ${i + 2} · ${proxima.rotulo}',
          palavras: palavrasDaRegiao(proxima.chave),
          manterPaisagemAoSair: true,
          habitatConcluivel: proxima.chave,
        ),
      ),
    );
  }

  Future<void> _concluirFaseAlimentos() async {
    final tema = AlimentosTema.porChave(widget.alimentosTemaConcluivel!);
    await ProgressoRepository.registrarBonusFase();
    await ProgressoAlimentosFases.marcarConcluido(widget.alimentosTemaConcluivel!);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _moedas += ProgressoRepository.bonusFase);
    final fases = AlimentosTema.values;
    final i = fases.indexWhere((t) => t.chave == widget.alimentosTemaConcluivel);
    final proxima = (i >= 0 && i < fases.length - 1) ? fases[i + 1] : null;
    final jogar = await showDialog<bool>(
      context: context,
      builder: (_) => _BauAlimentosDialog(
        tema: tema,
        proxima: proxima,
      ),
    );
    if (jogar != true || !mounted || proxima == null) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${proxima.emoji}  ${proxima.rotulo}',
          palavras: palavrasDoTema(proxima.chave),
          manterPaisagemAoSair: true,
          alimentosTemaConcluivel: proxima.chave,
        ),
      ),
    );
  }

  Future<void> _concluirFaseObjetosTemas() async {
    final tema = Tema.porChave(widget.objetosTemaConcluivel!);
    await ProgressoRepository.registrarBonusFase();
    await ProgressoObjetosTemasFases.marcarConcluido(widget.objetosTemaConcluivel!);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _moedas += ProgressoRepository.bonusFase);
    final fases = Tema.values;
    final i = fases.indexWhere((t) => t.chave == widget.objetosTemaConcluivel);
    final proxima = (i >= 0 && i < fases.length - 1) ? fases[i + 1] : null;
    final jogar = await showDialog<bool>(
      context: context,
      builder: (_) => _BauObjetosDialog(
        tema: tema,
        proxima: proxima,
      ),
    );
    if (jogar != true || !mounted || proxima == null) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${proxima.emoji}  ${proxima.rotulo}',
          palavras: palavrasDoTema(proxima.chave),
          manterPaisagemAoSair: true,
          objetosTemaConcluivel: proxima.chave,
        ),
      ),
    );
  }

  /// Última palavra de uma categoria FORA do mapa-múndi (habitats, níveis,
  /// meus animais…): parabéns com "Jogar de novo" / "Sair". O "Sair" tem a
  /// MESMA função do Voltar — fecha a categoria e volta para os cenários.
  Future<void> _fimDeCategoria() async {
    final deNovo = await showDialog<bool>(
      context: context,
      builder: (_) => _FimCategoriaDialog(titulo: widget.titulo),
    );
    if (!mounted) return;
    if (deNovo == true) {
      setState(() {
        _i = 0;
        _tracos.clear();
        _sequencia = 0;
      });
      _prepararIncompleta();
      _falarPalavraAtual();
    } else {
      Navigator.of(context).pop(); // "Sair" = voltar aos cenários
    }
  }

  /// Marca a fase concluída quando a criança chega na última palavra do habitat.
  void _talvezConcluir() {
    if (widget.habitatConcluivel != null &&
        _i == widget.palavras.length - 1) {
      ProgressoFases.marcarConcluido(widget.habitatConcluivel!);
    }
    if (widget.alimentosTemaConcluivel != null &&
        _i == widget.palavras.length - 1) {
      ProgressoAlimentosFases.marcarConcluido(widget.alimentosTemaConcluivel!);
    }
    if (widget.objetosTemaConcluivel != null &&
        _i == widget.palavras.length - 1) {
      ProgressoObjetosTemasFases.marcarConcluido(widget.objetosTemaConcluivel!);
    }
  }

  @override
  void dispose() {
    // O app é todo PAISAGEM — garante ao sair (redundante, mas seguro).
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  bool get _temAnterior => _i > 0;
  bool get _temProximo => _i < widget.palavras.length - 1;

  void _limparDesenho() => setState(_tracos.clear);

  void _desfazer() {
    if (_tracos.isEmpty) return;
    setState(() => _tracos.removeLast());
  }

  void _anterior() {
    if (!_temAnterior) return;
    setState(() {
      _i--;
      _tracos.clear();
    });
    _prepararIncompleta();
    _falarPalavraAtual();
  }

  void _proximo() {
    if (!_temProximo) return;
    setState(() {
      _i++;
      _tracos.clear();
    });
    _talvezConcluir();
    _prepararIncompleta();
    _falarPalavraAtual();
  }

  void _recomecar() {
    setState(() {
      _i = 0;
      _tracos.clear();
    });
    _prepararIncompleta();
    _falarPalavraAtual();
  }

  void _sair() => Navigator.of(context).pop();

  // ── desenho (caneta) ──
  void _inicioTraco(PointerDownEvent e) {
    setState(() => _tracos.add(Traco(_caneta.cor)..pontos.add(e.localPosition)));
  }

  void _moveTraco(PointerMoveEvent e) {
    if (_tracos.isEmpty) return;
    setState(() => _tracos.last.pontos.add(e.localPosition));
  }

  /// Coluna de CANETAS à esquerda (cores + vassoura + desfazer) — usada tanto no
  /// modo normal quanto no "completar" (a criança pode escrever por cima).
  Widget _colunaCaneta(Color ui) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in CorCaneta.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: BolinhaCor(
                cor: c.cor,
                selecionada: c == _caneta,
                contraste: ui,
                onTap: () => setState(() => _caneta = c),
              ),
            ),
          const SizedBox(height: 3),
          // Vassoura = limpa TUDO que foi desenhado.
          BotaoIconeDesenho(
            icon: Icons.cleaning_services_rounded,
            cor: ui,
            onTap: _tracos.isEmpty ? null : _limparDesenho,
            tooltip: 'Limpar tudo',
          ),
          const SizedBox(height: 8),
          // Desfazer = apaga só o ÚLTIMO rabisco.
          BotaoIconeDesenho(
            icon: Icons.undo_rounded,
            cor: ui,
            onTap: _tracos.isEmpty ? null : _desfazer,
            tooltip: 'Apagar o último rabisco',
          ),
        ],
      ),
    );
  }

  /// Corpo do modo "completar a sílaba que falta": mantém a **coluna de canetas**
  /// e a **camada de desenho** (dá pra escrever por cima) — mostra a palavra com
  /// uma **lacuna** e, embaixo, as 4 opções (ou "Continuar" se não há desafio).
  Widget _meioIncompleto(Color ui) {
    final palavra = widget.palavras[_i];
    final temDesafio = _blankIdx >= 0 && _opcoes.isNotEmpty;
    final display = temDesafio
        ? [
            for (var i = 0; i < palavra.silabas.length; i++)
              i == _blankIdx ? '＿＿' : palavra.silabas[i].toUpperCase(),
          ].join()
        : palavra.texto.toUpperCase();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _colunaCaneta(ui),
        Expanded(
          child: Column(
            children: [
              // palavra com a lacuna + camada de desenho (o "caderno")
              Expanded(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _inicioTraco,
                  onPointerMove: _moveTraco,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                display,
                                style: TextStyle(
                                  fontSize: 150,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  color: ui,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: DesenhoPainter(_tracos)),
                        ),
                      ),
                      if (_feedback != null)
                        Positioned(
                          top: 4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: PontosFeedback(
                              key: ValueKey(_feedbackSeq),
                              texto: _feedback!,
                              onFim: () => setState(() => _feedback = null),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // opções (ou "Continuar" quando a palavra não tem sílaba pra faltar)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 12, 10),
                child: temDesafio
                    ? Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final op in _opcoes)
                            _OpcaoSilaba(
                              texto: op,
                              errada: op == _erradaSel,
                              ui: ui,
                              onTap: () => _escolheuIncompleta(op),
                            ),
                        ],
                      )
                    : SizedBox(
                        width: 220,
                        height: 46,
                        child: FilledButton.icon(
                          onPressed: () => _escolheuIncompleta(''),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Continuar'),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final palavra = widget.palavras[_i];
    final letra = _fundo.corLetra; // cor da palavra (contraste)
    final ui = _fundo.corLetra; // cor base da UI sobre o fundo

    return Scaffold(
      backgroundColor: _fundo.cor,
      body: Stack(
        children: [
          Column(
            children: [
              // Linha do topo FORA do SafeArea. O padding direito (104)
              // RESERVA o espaço dos botões V/X flutuantes (eles ficam por cima,
              // colados no canto). Sem V/X aqui — são posicionados no Stack.
              MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                removeRight: true,
                child: Padding(
                  // 132 à esquerda = reserva o botão flutuante "Início"
                  // (casinha) no canto superior esquerdo.
                  padding: const EdgeInsets.fromLTRB(132, 10, 104, 0),
                  child: Row(
                    children: [
                      // Grupo esquerdo (título + bolinhas de fundo) absorve o
                      // espaço livre.
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.titulo,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ui.withValues(alpha: 0.65),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            for (final f in FundoTela.values)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: BolinhaCor(
                                  cor: f.cor,
                                  selecionada: f == _fundo,
                                  contraste: ui,
                                  onTap: () => setState(() => _fundo = f),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bloco da direita (progresso + moedas + nível).
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Text(
                        '${_i + 1} / ${widget.palavras.length}',
                        style: TextStyle(
                          color: ui.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // moedas + nível (gamificação)
                      Text(
                        '🪙 $_moedas',
                        style: TextStyle(
                          color: ui,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nv ${ProgressoRepository.nivelDe(_xp)}',
                        style: TextStyle(
                          color: ui.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // sequência de acertos 🔥 (visível a partir de 2)
                      if (_sequencia >= 2) ...[
                        const SizedBox(width: 8),
                        Text(
                          '🔥 $_sequencia',
                          style: TextStyle(
                            color: ui,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
            // ── meio: bolinhas de CANETA (verticais) + palavra + desenho ──
            Expanded(
              child: _modo == ModoLeitura.incompleta
                  ? _meioIncompleto(ui)
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _colunaCaneta(ui),
                  // área da palavra + camada de desenho (o "caderno")
                  Expanded(
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: _inicioTraco,
                      onPointerMove: _moveTraco,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 4, 20, 4),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _modo.aplicar(palavra.texto),
                                    style: TextStyle(
                                      fontSize: 200,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                      color: letra,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: DesenhoPainter(_tracos),
                              ),
                            ),
                          ),
                          // feedback "+4" / "-4" (acerto/erro) — no topo,
                          // CENTRALIZADO (não fica sobre a palavra).
                          if (_feedback != null)
                            Positioned(
                              top: 4,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: PontosFeedback(
                                  key: ValueKey(_feedbackSeq),
                                  texto: _feedback!,
                                  onFim: () =>
                                      setState(() => _feedback = null),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── embaixo: botões baixos ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
              child: Row(
                children: [
                  _Botao(
                    icon: Icons.arrow_back_rounded,
                    label: 'Voltar',
                    ui: ui,
                    onTap: _sair,
                  ),
                  _Botao(
                    icon: Icons.chevron_left_rounded,
                    label: 'Anterior',
                    ui: ui,
                    onTap: _temAnterior ? _anterior : null,
                  ),
                  _Botao(
                    icon: Icons.restart_alt_rounded,
                    label: 'Recomeçar',
                    ui: ui,
                    onTap: _i == 0 ? null : _recomecar,
                  ),
                  _Botao(
                    icon: Icons.chevron_right_rounded,
                    label: 'Próximo',
                    ui: ui,
                    onTap: _temProximo ? _proximo : null,
                    destaque: true,
                  ),
                ],
              ),
            ),
                ],
              ),
            ),
          ),
            ],
          ),
          // INÍCIO (flutuante, topo-esq): casinha + nome — impossível de não
          // achar; volta direto pra página inicial.
          Positioned(
            top: 6,
            left: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Início',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // V/X FLUTUANTES (só nos modos de escrita — no "completar" a criança
          // toca nas opções). Canto superior direito da TELA, lado a lado.
          if (_modo != ModoLeitura.incompleta)
            Positioned(
            top: 10,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BotaoAcertoErro(
                  cor: AppColors.acerto,
                  letra: 'V',
                  tooltip: 'Acertou! Ganha os pontos e passa pra próxima',
                  onTap: _acertou,
                ),
                const SizedBox(width: 8),
                _BotaoAcertoErro(
                  cor: AppColors.danger,
                  letra: 'X',
                  tooltip: 'Errou. Perde os pontos e repete a palavra',
                  onTap: _errou,
                ),
              ],
            ),
          ),
          // confetes 🎉 a cada acerto (efeito visual por cima de tudo)
          if (_confeteSeq > 0)
            Positioned.fill(
              child: ConfeteBurst(key: ValueKey(_confeteSeq)),
            ),
        ],
      ),
    );
  }
}

/// Baú do tesouro (fim de fase no mapa-múndi): começa FECHADO com o bônus de
/// moedas + aviso do animal novo na coleção. O Davi TOCA no baú → a tampa
/// abre animada, estouram confetes 🎉 e o CARD da nova fase "sai" de dentro
/// (escala elástica) com "▶ JOGAR AGORA" (continua a aventura) ou "Mapa". Na
/// ÚLTIMA fase, o card mostra o 🏆 da aventura.
class _BauDialog extends StatefulWidget {
  const _BauDialog({
    required this.regiao,
    required this.proxima,
  });

  /// Região concluída (o animal vai pra coleção) — pode ser null se a fase
  /// não for uma região do mapa-múndi.
  final Regiao? regiao;

  /// Próxima fase da ordem (o card sai do baú). `null` = última fase.
  final Regiao? proxima;

  @override
  State<_BauDialog> createState() => _BauDialogState();
}

class _BauDialogState extends State<_BauDialog>
    with TickerProviderStateMixin {
  late final AnimationController _abertura = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _card = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  bool get _aberto => _abertura.isCompleted;

  @override
  void initState() {
    super.initState();
    unawaited(Fala.instance.falar('Fase concluída!'));
    // quando a abertura termina, aparece o card + os botões (rebuild).
    _abertura.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _abertura.dispose();
    _card.dispose();
    super.dispose();
  }

  /// Toca no baú: abre a tampa (com brilho), confetes estouram, o card da
  /// próxima fase sai de dentro e o app anuncia o cenário em voz alta.
  void _abrirBau() {
    if (_aberto) return;
    HapticFeedback.mediumImpact();
    _abertura.forward();
    _card.forward(from: 0.2);
    final proxima = widget.proxima;
    unawaited(
      proxima == null
          ? Fala.instance.falar('Parabéns! Você completou a aventura!')
          : Fala.instance.falar(
              'Você desbloqueou o cenário ${proxima.rotulo}!',
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ehUltima = widget.proxima == null;
    return AlertDialog(
      // Compacto: a tela é deitada (360 de altura) — sem espaço pra sobrar.
      // `scrollable` = rede de segurança: em telas ainda mais baixas a janela
      // ROLA em vez de cortar em cima. Largura limitada (não estica até a borda).
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      constraints: const BoxConstraints(maxWidth: 360),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+${ProgressoRepository.bonusFase} moedas!',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 2),
          // baú (fechado) + card da nova fase "saindo" dele. Fechado: caixa
          // baixa (só o baú). Aberto: caixa ALTA o bastante para CONTER o card
          // inteiro acima do baú — ele não sobe além do topo da janela (era
          // isso que cortava). A janela cresce quando o baú abre.
          SizedBox(
            height: _aberto ? 200 : 124,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // confetes estouram quando o baú abre
                if (_aberto)
                  const Positioned.fill(child: ConfeteBurst(muito: true)),
                AnimatedBuilder(
                  animation: _abertura,
                  builder: (_, _) => _Bau(
                    p: Curves.easeInOutCubic.transform(_abertura.value),
                    onTap: _abrirBau,
                  ),
                ),
                if (_aberto)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 82,
                    child: AnimatedBuilder(
                      animation: _card,
                      builder: (_, _) {
                        final t = Curves.elasticOut.transform(_card.value);
                        return Opacity(
                          opacity: _card.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 0.15 + 0.85 * t,
                            child: _CardNovaFase(
                              proxima: widget.proxima,
                              ehUltima: ehUltima,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          if (widget.regiao != null) ...[
            const SizedBox(height: 2),
            Text(
              '🐾 Novo animal da coleção: '
              '${widget.regiao!.emoji} ${widget.regiao!.rotulo}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (!_aberto) ...[
            const SizedBox(height: 4),
            const Text(
              'Toque no baú para abrir! 🗝️',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.bauOuro,
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      actions: _aberto
          ? (ehUltima
              ? [
                  FilledButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Voltar ao mapa'),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Mapa'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('JOGAR AGORA'),
                  ),
                ])
          : const [],
    );
  }
}

/// Card que "sai" do baú: emoji + nome da nova fase (ou 🏆 no fim da
/// aventura).
class _CardNovaFase extends StatelessWidget {
  const _CardNovaFase({required this.proxima, required this.ehUltima});

  final Regiao? proxima;
  final bool ehUltima;

  @override
  Widget build(BuildContext context) {
    // Card COMPACTO (a tela é deitada e baixa): emoji + rótulo curto. A frase
    // longa "Você desbloqueou o cenário…" a voz (TTS) já anuncia — aqui ela só
    // deixava o card alto demais e o empurrava para fora do topo da janela.
    return Material(
      color: AppColors.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lineStrong),
        ),
        child: ehUltima
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏆', style: TextStyle(fontSize: 34)),
                  SizedBox(height: 2),
                  Text(
                    'AVENTURA CONCLUÍDA!',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(proxima!.emoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(height: 2),
                  const Text(
                    'NOVA FASE! 🔓',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    proxima!.rotulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _BauAlimentosDialog extends StatefulWidget {
  const _BauAlimentosDialog({required this.tema, required this.proxima});

  final AlimentosTema? tema;
  final AlimentosTema? proxima;

  @override
  State<_BauAlimentosDialog> createState() => _BauAlimentosDialogState();
}

class _BauAlimentosDialogState extends State<_BauAlimentosDialog>
    with TickerProviderStateMixin {
  late final AnimationController _abertura = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _card = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  bool get _aberto => _abertura.isCompleted;

  @override
  void initState() {
    super.initState();
    unawaited(Fala.instance.falar('Fase concluída!'));
    _abertura.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _abertura.dispose();
    _card.dispose();
    super.dispose();
  }

  void _abrirBau() {
    if (_aberto) return;
    HapticFeedback.mediumImpact();
    _abertura.forward();
    _card.forward(from: 0.2);
    final proxima = widget.proxima;
    unawaited(
      proxima == null
          ? Fala.instance.falar('Parabéns! Você completou a aventura dos alimentos!')
          : Fala.instance.falar('Você desbloqueou ${proxima.rotulo}!'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ehUltima = widget.proxima == null;
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      constraints: const BoxConstraints(maxWidth: 360),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+${ProgressoRepository.bonusFase} moedas!',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: _aberto ? 200 : 124,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                if (_aberto) const Positioned.fill(child: ConfeteBurst(muito: true)),
                AnimatedBuilder(
                  animation: _abertura,
                  builder: (_, _) => _Bau(p: Curves.easeInOutCubic.transform(_abertura.value), onTap: _abrirBau),
                ),
                if (_aberto)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 82,
                    child: AnimatedBuilder(
                      animation: _card,
                      builder: (_, _) {
                        final t = Curves.elasticOut.transform(_card.value);
                        return Opacity(
                          opacity: _card.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 0.15 + 0.85 * t,
                            child: _CardNovaFaseAlimentos(
                              proxima: widget.proxima,
                              ehUltima: ehUltima,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          if (widget.tema != null) ...[
            const SizedBox(height: 2),
            Text(
              '${widget.tema!.premioEmoji} Novo sabor desbloqueado: ${widget.tema!.premioNome}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
          if (!_aberto) ...[
            const SizedBox(height: 4),
            const Text(
              'Toque no baú para abrir! 🗝️',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bauOuro),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      actions: _aberto
          ? (ehUltima
              ? [
                  FilledButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Voltar à fazenda'),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Fazenda'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('JOGAR AGORA'),
                  ),
                ])
          : const [],
    );
  }
}

class _CardNovaFaseAlimentos extends StatelessWidget {
  const _CardNovaFaseAlimentos({required this.proxima, required this.ehUltima});
  final AlimentosTema? proxima;
  final bool ehUltima;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lineStrong),
        ),
        child: ehUltima
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🍫', style: TextStyle(fontSize: 34)),
                  SizedBox(height: 2),
                  Text('AVENTURA CONCLUÍDA!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                  Text('Todos os sabores! 🎉', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(proxima!.premioEmoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(height: 2),
                  const Text('NOVA FASE! 🔓', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  Text(proxima!.rotulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
      ),
    );
  }
}

class _BauObjetosDialog extends StatefulWidget {
  const _BauObjetosDialog({required this.tema, required this.proxima});
  final Tema? tema;
  final Tema? proxima;
  @override
  State<_BauObjetosDialog> createState() => _BauObjetosDialogState();
}

class _BauObjetosDialogState extends State<_BauObjetosDialog>
    with TickerProviderStateMixin {
  late final AnimationController _abertura = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  late final AnimationController _card = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
  bool get _aberto => _abertura.isCompleted;
  @override
  void initState() {
    super.initState();
    unawaited(Fala.instance.falar('Fase concluída!'));
    _abertura.addStatusListener((s) { if (s == AnimationStatus.completed && mounted) setState(() {}); });
  }
  @override
  void dispose() { _abertura.dispose(); _card.dispose(); super.dispose(); }
  void _abrirBau() {
    if (_aberto) return;
    HapticFeedback.mediumImpact();
    _abertura.forward();
    _card.forward(from: 0.2);
    final proxima = widget.proxima;
    unawaited(proxima == null ? Fala.instance.falar('Parabéns! Você completou a aventura dos objetos!') : Fala.instance.falar('Você desbloqueou ${proxima.rotulo}!'));
  }
  @override
  Widget build(BuildContext context) {
    final ehUltima = widget.proxima == null;
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      constraints: const BoxConstraints(maxWidth: 360),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('+${ProgressoRepository.bonusFase} moedas!', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent)),
          const SizedBox(height: 2),
          SizedBox(
            height: _aberto ? 200 : 124,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                if (_aberto) const Positioned.fill(child: ConfeteBurst(muito: true)),
                AnimatedBuilder(animation: _abertura, builder: (_, _) => _Bau(p: Curves.easeInOutCubic.transform(_abertura.value), onTap: _abrirBau)),
                if (_aberto)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 82,
                    child: AnimatedBuilder(
                      animation: _card,
                      builder: (_, _) {
                        final t = Curves.elasticOut.transform(_card.value);
                        return Opacity(
                          opacity: _card.value.clamp(0.0, 1.0),
                          child: Transform.scale(scale: 0.15 + 0.85 * t, child: _CardNovaFaseObjetos(proxima: widget.proxima, ehUltima: ehUltima)),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          if (widget.tema != null) ...[
            const SizedBox(height: 2),
            Text('${widget.tema!.premioEmoji} Novo brinquedo desbloqueado: ${widget.tema!.premioNome}!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
          if (!_aberto) ...[const SizedBox(height: 4), const Text('Toque no baú para abrir! 🗝️', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bauOuro))],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      actions: _aberto
          ? (ehUltima
              ? [FilledButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar à cidade'))]
              : [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cidade')), FilledButton.icon(onPressed: () => Navigator.pop(context, true), icon: const Icon(Icons.play_arrow_rounded), label: const Text('JOGAR AGORA'))])
          : const [],
    );
  }
}

class _CardNovaFaseObjetos extends StatelessWidget {
  const _CardNovaFaseObjetos({required this.proxima, required this.ehUltima});
  final Tema? proxima;
  final bool ehUltima;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.lineStrong)),
        child: ehUltima
            ? const Column(mainAxisSize: MainAxisSize.min, children: [Text('🎁', style: TextStyle(fontSize: 34)), SizedBox(height: 2), Text('AVENTURA CONCLUÍDA!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)), Text('Todos os brinquedos! 🎉', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))])
            : Column(mainAxisSize: MainAxisSize.min, children: [Text(proxima!.premioEmoji, style: const TextStyle(fontSize: 34)), const SizedBox(height: 2), const Text('NOVA FASE! 🔓', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)), Text(proxima!.rotulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))]),
      ),
    );
  }
}

/// O baú em si: `p` = abertura (0 fechado → 1 aberto): a tampa gira para trás
/// na dobradiça de cima e o TESOURO de dentro aparece.
class _Bau extends StatelessWidget {
  const _Bau({required this.p, required this.onTap});

  final double p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('bau'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        size: const Size(168, 112),
        painter: _BauPainter(p),
      ),
    );
  }
}

class _BauPainter extends CustomPainter {
  _BauPainter(this.p);
  final double p;
  final Random _r = Random(7);
  static const _moedaRaio = 7.0;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final topo = h * 0.42;
    final baixo = h * 0.96;
    final lidH = h * 0.30;
    _sombra(canvas, w, h);
    _glow(canvas, w, h, topo);
    _interiorETesouro(canvas, w, h, topo, lidH);
    _corpo(canvas, w, h, topo, baixo);
    _tesouroDerramado(canvas, w, h, topo);
    _cadeado(canvas, w, h, topo);
    _tampa(canvas, w, h, topo, lidH);
  }
  void _sombra(Canvas canvas, double w, double h) {
    canvas.drawOval(
      Rect.fromLTRB(w * 0.14, h * 0.90, w * 0.86, h * 0.985),
      Paint()..color = Colors.black.withValues(alpha: 0.42)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawOval(
      Rect.fromLTRB(w * 0.22, h * 0.92, w * 0.78, h * 0.975),
      Paint()..color = Colors.black.withValues(alpha: 0.22)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
  void _glow(Canvas canvas, double w, double h, double topo) {
    if (p <= 0) return;
    final eased = Curves.easeOutCubic.transform(p);
    canvas.drawRect(
      Rect.fromLTRB(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          colors: [AppColors.bauOuro.withValues(alpha: 0.75 * eased), AppColors.bauOuro.withValues(alpha: 0.18 * eased), AppColors.bauOuro.withValues(alpha: 0)],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(w / 2, topo - 4), radius: w * (0.38 + 0.32 * eased))),
    );
    canvas.drawRect(
      Rect.fromLTRB(w * 0.08, topo - 18 * eased, w * 0.92, topo + 2),
      Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: 0.42 * eased), Colors.transparent]).createShader(Rect.fromLTRB(w * 0.08, topo - 18 * eased, w * 0.92, topo + 2)),
    );
  }
  void _interiorETesouro(Canvas canvas, double w, double h, double topo, double lidH) {
    final eased = Curves.easeOutCubic.transform(p);
    final aberto = eased * lidH;
    if (aberto <= 0.8) return;
    final clip = Path()..addRect(Rect.fromLTRB(w * 0.085, topo - aberto, w * 0.915, topo + 1));
    canvas.save();
    canvas.clipPath(clip);
    final parede = Path()..addRect(Rect.fromLTRB(w * 0.085, topo - aberto, w * 0.915, topo + 2));
    canvas.drawPath(parede, Paint()..color = AppColors.bauInterior);
    canvas.drawRect(Rect.fromLTRB(w * 0.085, topo - aberto, w * 0.915, topo - aberto + 3), Paint()..color = Colors.black.withValues(alpha: 0.55));
    final sombraInterna = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent]).createShader(Rect.fromLTRB(w * 0.085, topo - aberto, w * 0.915, topo));
    canvas.drawRect(Rect.fromLTRB(w * 0.085, topo - aberto, w * 0.915, topo), sombraInterna);
    canvas.drawRect(Rect.fromLTRB(w * 0.085, topo - 8, w * 0.915, topo + 1), Paint()..color = AppColors.bauInterior.withValues(alpha: 0.95));
    final fundoTesouro = Paint()..shader = RadialGradient(center: const Alignment(0, -0.3), colors: [AppColors.bauOuro.withValues(alpha: 0.22), Colors.transparent], stops: const [0.0, 1.0]).createShader(Rect.fromCircle(center: Offset(w / 2, topo - 10), radius: w * 0.42));
    canvas.drawRect(Rect.fromLTRB(w * 0.10, topo - 28, w * 0.90, topo), fundoTesouro);
    _fileiraMoedas(canvas, w, topo, aberto, 0, 5);
    _fileiraMoedas(canvas, w, topo, aberto, 1, 4);
    _fileiraMoedas(canvas, w, topo, aberto, 2, 3);
    _fileiraMoedas(canvas, w, topo, aberto, 3, 3);
    for (var i = 0; i < 4; i++) {
      final sx = w * (0.26 + 0.18 * i) + (i == 2 ? 0 : _r.nextDouble() * 14 - 7);
      final sy = topo - (5 + i * 8) - _r.nextDouble() * 5;
      _brilho(canvas, Offset(sx, sy), 2.8 + _r.nextDouble() * 1.8, 0.50 + 0.50 * eased);
    }
    canvas.restore();
    canvas.drawRect(Rect.fromLTRB(w * 0.085, topo - 1.2, w * 0.915, topo + 1.2), Paint()..color = AppColors.bauOuro.withValues(alpha: 0.9));
    canvas.drawRect(Rect.fromLTRB(w * 0.085, topo + 1.2, w * 0.915, topo + 2.8), Paint()..color = Colors.white.withValues(alpha: 0.18));
  }
  void _fileiraMoedas(Canvas canvas, double w, double topo, double aberto, int i, int n) {
    final dy = -4 - 10.5 * i;
    final need = 6.5 - dy;
    if (aberto < need) return;
    final scaleByRow = [1.0, 0.96, 0.92, 0.88][i.clamp(0, 3)];
    for (var k = 0; k < n; k++) {
      final spread = n == 5 ? 0.48 : n == 4 ? 0.42 : 0.34;
      final baseX = w * (0.5 - spread / 2 + spread * (k + 0.5) / n);
      final jitter = (k * 1.7) % 2 - 1;
      final x = baseX + jitter + _r.nextDouble() * 1.2 - 0.6;
      final y = topo + dy + _r.nextDouble() * 2.4 - 1.2;
      final off = Offset(x, y);
      if (i == 1 && k == n ~/ 2) {
        _joia(canvas, off + const Offset(0, -1.5), 7.2 * scaleByRow, AppColors.acerto);
      } else if (i == 2 && k == 0) {
        _joia(canvas, off + const Offset(0, -1.2), 6.8 * scaleByRow, AppColors.accent);
      } else if (i == 3 && k == 1) {
        _joia(canvas, off + const Offset(0, -1), 5.8, AppColors.danger.withValues(alpha: 0.95));
      } else {
        _moeda(canvas, off, scale: scaleByRow);
      }
    }
  }
  void _moeda(Canvas canvas, Offset c, {double scale = 1.0}) {
    final rx = _moedaRaio * scale;
    final ry = _moedaRaio * 0.58 * scale;
    final thick = 2.2 * scale;
    canvas.drawOval(Rect.fromCenter(center: c + Offset(0.9 * scale, 1.9 * scale), width: rx * 2, height: ry * 2), Paint()..color = Colors.black.withValues(alpha: 0.38));
    final sideRect = Rect.fromCenter(center: c + Offset(0, thick * 0.55), width: rx * 2, height: ry * 2);
    canvas.drawOval(sideRect, Paint()..color = const Color(0xFF8C6A0E));
    canvas.drawOval(Rect.fromCenter(center: c + Offset(0, thick * 0.22), width: rx * 2, height: ry * 1.92), Paint()..color = const Color(0xFFA67C0A));
    final topRect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    final topPaint = Paint()..shader = RadialGradient(center: const Alignment(-0.45, -0.55), radius: 1.0, colors: [Color.lerp(AppColors.bauOuro, Colors.white, 0.52)!, AppColors.bauOuro, const Color(0xFFE8A910), AppColors.bauOuroEscuro], stops: const [0.0, 0.32, 0.68, 1.0]).createShader(topRect);
    canvas.drawOval(topRect, topPaint);
    canvas.drawOval(topRect, Paint()..color = AppColors.bauOuroEscuro.withValues(alpha: 0.95)..style = PaintingStyle.stroke..strokeWidth = 1.05 * scale);
    final innerRim = Rect.fromCenter(center: c, width: rx * 1.28, height: ry * 1.28);
    canvas.drawOval(innerRim, Paint()..color = AppColors.bauOuroEscuro.withValues(alpha: 0.52)..style = PaintingStyle.stroke..strokeWidth = 0.85 * scale);
    final innerDot = Rect.fromCenter(center: c, width: rx * 0.42, height: ry * 0.42);
    canvas.drawOval(innerDot, Paint()..color = AppColors.bauOuroEscuro.withValues(alpha: 0.22));
    final highlight = Rect.fromCenter(center: c + Offset(-rx * 0.32, -ry * 0.42), width: rx * 0.62, height: ry * 0.48);
    canvas.drawOval(highlight, Paint()..color = Colors.white.withValues(alpha: 0.78));
    canvas.drawOval(Rect.fromCenter(center: c + Offset(-rx * 0.18, -ry * 0.28), width: rx * 0.22, height: ry * 0.18), Paint()..color = Colors.white.withValues(alpha: 0.92));
  }
  void _joia(Canvas canvas, Offset c, double r, Color cor) {
    final ovalH = r * 1.45;
    canvas.drawOval(Rect.fromCenter(center: c + Offset(0.9, 1.4), width: r * 1.6, height: ovalH), Paint()..color = Colors.black.withValues(alpha: 0.38));
    final path = Path()..moveTo(c.dx, c.dy - r)..lineTo(c.dx + r * 0.82, c.dy)..lineTo(c.dx, c.dy + r)..lineTo(c.dx - r * 0.82, c.dy)..close();
    canvas.drawPath(path, Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.lerp(cor, Colors.white, 0.48)!, cor, Color.lerp(cor, Colors.black, 0.58)!], stops: const [0.0, 0.52, 1.0]).createShader(Rect.fromCircle(center: c, radius: r)));
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.18)..style = PaintingStyle.stroke..strokeWidth = 1.1);
    final faceta = Paint()..color = Colors.white.withValues(alpha: 0.52)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    canvas.drawLine(Offset(c.dx - r * 0.52, c.dy - r * 0.32), Offset(c.dx + r * 0.52, c.dy - r * 0.32), faceta);
    canvas.drawLine(Offset(c.dx - r * 0.52, c.dy - r * 0.32), Offset(c.dx, c.dy + r * 0.28), faceta);
    canvas.drawLine(Offset(c.dx + r * 0.52, c.dy - r * 0.32), Offset(c.dx, c.dy + r * 0.28), faceta);
    canvas.drawPath(Path()..moveTo(c.dx, c.dy - r)..lineTo(c.dx, c.dy + r)..close(), Paint()..color = Colors.white.withValues(alpha: 0.22)..style = PaintingStyle.stroke..strokeWidth = 0.9);
    canvas.drawCircle(c + Offset(-r * 0.28, -r * 0.32), r * 0.22, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawCircle(c + Offset(r * 0.22, r * 0.18), r * 0.10, Paint()..color = Colors.white.withValues(alpha: 0.55));
  }
  void _brilho(Canvas canvas, Offset c, double r, double alpha) {
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: r * 3.8, height: r * 0.95), Radius.circular(r / 2)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: r * 0.95, height: r * 3.8), Radius.circular(r / 2)), paint);
    canvas.drawCircle(c, r * 0.78, Paint()..color = Colors.white.withValues(alpha: alpha * 0.95));
    canvas.drawCircle(c, r * 0.28, Paint()..color = Colors.white.withValues(alpha: 1.0));
  }
  void _corpo(Canvas canvas, double w, double h, double topo, double baixo) {
    final outer = RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.078, topo - 0.5, w * 0.922, baixo + 0.8), const Radius.circular(11));
    canvas.drawRRect(outer, Paint()..color = Colors.black.withValues(alpha: 0.55));
    final corpo = RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.08, topo, w * 0.92, baixo), const Radius.circular(10));
    canvas.drawRRect(corpo, Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFFB07A3A), AppColors.bauMadeira, AppColors.bauMadeiraEscura, const Color(0xFF4E2E14)], stops: const [0.0, 0.35, 0.72, 1.0]).createShader(corpo.outerRect));
    canvas.drawRRect(corpo, Paint()..color = const Color(0xFF3A1F0A).withValues(alpha: 0.95)..style = PaintingStyle.stroke..strokeWidth = 1.4);
    final highlightTop = RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.085, topo + 0.6, w * 0.915, topo + 5.5), const Radius.circular(6));
    canvas.drawRRect(highlightTop, Paint()..color = Colors.white.withValues(alpha: 0.16));
    final vinco = Paint()..color = const Color(0xFF3A1F0A).withValues(alpha: 0.42)..strokeWidth = 1.25..style = PaintingStyle.stroke;
    final sombraVinco = Paint()..color = Colors.white.withValues(alpha: 0.08)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    for (final fx in const [0.30, 0.50, 0.70]) {
      canvas.drawLine(Offset(w * fx, topo + 3), Offset(w * fx, baixo - 3), vinco);
      canvas.drawLine(Offset(w * fx + 0.9, topo + 3), Offset(w * fx + 0.9, baixo - 3), sombraVinco);
    }
    final veioClaro = Paint()..color = Colors.white.withValues(alpha: 0.07)..style = PaintingStyle.stroke..strokeWidth = 1.15;
    final veioEscuro = Paint()..color = Colors.black.withValues(alpha: 0.14)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    for (var i = 0; i < 3; i++) {
      final y = topo + h * (0.13 + 0.11 * i);
      final pathC = Path()..moveTo(w * 0.11, y);
      final pathE = Path()..moveTo(w * 0.11, y + 1.2);
      for (var x = w * 0.11; x < w * 0.89; x += w * 0.035) {
        pathC.lineTo(x, y + 1.5 * sin(x / w * 3.2 + i * 1.1));
        pathE.lineTo(x, y + 1.2 + 1.5 * sin(x / w * 3.2 + i * 1.1));
      }
      canvas.drawPath(pathE, veioEscuro);
      canvas.drawPath(pathC, veioClaro);
    }
    final frisoBoca = RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.08, topo - 2.8, w * 0.92, topo + 2.9), const Radius.circular(2));
    canvas.drawRRect(frisoBoca, Paint()..shader = LinearGradient(colors: [Color.lerp(AppColors.bauOuro, Colors.white, 0.35)!, AppColors.bauOuro, AppColors.bauOuroEscuro]).createShader(frisoBoca.outerRect));
    canvas.drawRRect(frisoBoca, Paint()..color = Colors.black.withValues(alpha: 0.28)..style = PaintingStyle.stroke..strokeWidth = 0.8);
    final rodape = RRect.fromRectAndRadius(Rect.fromLTRB(w * 0.08, baixo - 3.6, w * 0.92, baixo), const Radius.circular(3));
    canvas.drawRRect(rodape, Paint()..color = AppColors.bauOuroEscuro);
    canvas.drawRRect(rodape, Paint()..color = Colors.white.withValues(alpha: 0.14)..style = PaintingStyle.stroke..strokeWidth = 0.7);
    for (final fx in const [0.26, 0.74]) {
      final faixa = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * fx, (topo + baixo) / 2), width: 9.5, height: baixo - topo - 6), const Radius.circular(4));
      canvas.drawRRect(faixa, Paint()..color = Colors.black.withValues(alpha: 0.35));
      final faixaF = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * fx - 0.4, (topo + baixo) / 2), width: 9.5, height: baixo - topo - 6), const Radius.circular(4));
      canvas.drawRRect(faixaF, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(AppColors.bauOuro, Colors.white, 0.32)!, AppColors.bauOuro, AppColors.bauOuroEscuro, const Color(0xFF7A5806)]).createShader(faixa.outerRect));
      canvas.drawRRect(faixaF, Paint()..color = const Color(0xFF5A3E05).withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 0.9);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w * fx - 0.4, (topo + baixo) / 2 - 0.6), width: 7, height: (baixo - topo - 6) * 0.55), const Radius.circular(2)), Paint()..color = Colors.white.withValues(alpha: 0.22));
      for (var i = 0; i < 3; i++) {
        _rebite(canvas, Offset(w * fx - 0.3, topo + h * (0.12 + 0.14 * i)));
      }
    }
  }
  void _rebite(Canvas canvas, Offset c) {
    canvas.drawCircle(c + const Offset(0.6, 0.7), 2.0, Paint()..color = Colors.black.withValues(alpha: 0.42));
    canvas.drawCircle(c, 1.85, Paint()..shader = RadialGradient(center: const Alignment(-0.4, -0.45), colors: [Color.lerp(AppColors.bauOuro, Colors.white, 0.5)!, AppColors.bauOuro, AppColors.bauOuroEscuro]).createShader(Rect.fromCircle(center: c, radius: 1.85)));
    canvas.drawCircle(c, 1.85, Paint()..color = AppColors.bauOuroEscuro.withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 0.7);
    canvas.drawCircle(c + const Offset(-0.45, -0.55), 0.72, Paint()..color = Colors.white.withValues(alpha: 0.92));
  }
  void _tesouroDerramado(Canvas canvas, double w, double h, double topo) {
    if (p < 0.52) return;
    final eased = Curves.easeOutCubic.transform(((p - 0.52) / 0.48).clamp(0.0, 1.0));
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(w * 0.10, topo + 1, w * 0.90, h * 0.98));
    _moeda(canvas, Offset(w * 0.30, topo + 6 + eased * 16), scale: 0.92);
    _moeda(canvas, Offset(w * 0.50, topo + 10 + eased * 20), scale: 1.02);
    _moeda(canvas, Offset(w * 0.70, topo + 7 + eased * 17), scale: 0.94);
    if (eased > 0.45) _moeda(canvas, Offset(w * 0.42, topo + 14 + eased * 12), scale: 0.78);
    canvas.restore();
  }
  void _cadeado(Canvas canvas, double w, double h, double topo) {
    final show = (1 - (p * 1.35).clamp(0.0, 1.0));
    if (show <= 0.02) return;
    canvas.save();
    canvas.translate(w / 2, topo + h * 0.16);
    canvas.scale(show, show);
    final placaOuter = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w * 0.135, height: h * 0.175), const Radius.circular(5));
    canvas.drawRRect(placaOuter, Paint()..color = Colors.black.withValues(alpha: 0.38));
    final placa = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-0.5, -0.6), width: w * 0.135, height: h * 0.175), const Radius.circular(5));
    canvas.drawRRect(placa, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(AppColors.bauOuro, Colors.white, 0.34)!, AppColors.bauOuro, AppColors.bauOuroEscuro]).createShader(placa.outerRect));
    canvas.drawRRect(placa, Paint()..color = const Color(0xFF5A3E05)..style = PaintingStyle.stroke..strokeWidth = 1.4);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(-0.5, -h * 0.03), width: w * 0.08, height: 4.5), const Radius.circular(2)), Paint()..color = Colors.white.withValues(alpha: 0.28));
    canvas.drawCircle(Offset(-0.5, -h * 0.025), 2.5, Paint()..color = AppColors.bauInterior);
    canvas.drawPath(Path()..moveTo(-0.5 - 1.9, -h * 0.022)..lineTo(-0.5 + 1.9, -h * 0.022)..lineTo(-0.5, h * 0.028)..close(), Paint()..color = AppColors.bauInterior);
    canvas.drawCircle(Offset(-0.5, -h * 0.025), 2.5, Paint()..color = Colors.black.withValues(alpha: 0.55)..style = PaintingStyle.stroke..strokeWidth = 0.6);
    canvas.drawArc(Rect.fromCircle(center: Offset(-0.5, -h * 0.088), radius: 5.8), pi, pi, false, Paint()..color = Colors.black.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 3.6);
    canvas.drawArc(Rect.fromCircle(center: Offset(-0.5, -h * 0.092), radius: 5.8), pi, pi, false, Paint()..shader = LinearGradient(colors: [Color.lerp(AppColors.bauOuro, Colors.white, 0.3)!, AppColors.bauOuroEscuro]).createShader(Rect.fromCircle(center: Offset(-0.5, -h * 0.092), radius: 5.8))..style = PaintingStyle.stroke..strokeWidth = 3.2);
    canvas.restore();
  }
  void _tampa(Canvas canvas, double w, double h, double topo, double lidH) {
    final angle = p * 1.92;
    final cosA = cos(angle);
    final sinA = sin(angle);
    const thickness = 7.0;
    final visH = (lidH * cosA).clamp(thickness * 0.55, lidH) + thickness * sinA * 0.55;
    final lidW = w * 0.884;
    canvas.save();
    canvas.translate(w / 2, topo);
    final lidRect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -visH / 2), width: lidW, height: visH), Radius.circular(16 * (0.45 + 0.55 * cosA.clamp(0.0, 1.0))));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0.8, -visH / 2 + 0.9), width: lidW, height: visH), Radius.circular(16 * (0.45 + 0.55 * cosA.clamp(0.0, 1.0)))), Paint()..color = Colors.black.withValues(alpha: 0.28 * (1 - p * 0.5)));
    canvas.drawRRect(lidRect, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFFBD7F3A), AppColors.bauMadeira, AppColors.bauMadeiraEscura, const Color(0xFF4A2A12)], stops: const [0.0, 0.38, 0.74, 1.0]).createShader(lidRect.outerRect));
    canvas.drawRRect(lidRect, Paint()..color = const Color(0xFF3A1F0A).withValues(alpha: 0.92)..style = PaintingStyle.stroke..strokeWidth = 1.35);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, -visH + 2.2), width: lidW * 0.96, height: 3.2), const Radius.circular(2)), Paint()..color = Colors.white.withValues(alpha: 0.14 * cosA.clamp(0.0, 1.0)));
    final vinco = Paint()..color = const Color(0xFF3A1F0A).withValues(alpha: 0.50)..strokeWidth = 1.15..style = PaintingStyle.stroke;
    final vincoLight = Paint()..color = Colors.white.withValues(alpha: 0.07)..strokeWidth = 0.9..style = PaintingStyle.stroke;
    for (final fx in const [-0.30, 0.0, 0.30]) {
      canvas.drawLine(Offset(lidW * fx, -visH + 5), Offset(lidW * fx, -1.2), vinco);
      canvas.drawLine(Offset(lidW * fx + 0.8, -visH + 5), Offset(lidW * fx + 0.8, -1.2), vincoLight);
    }
    final frisoY = -2.6;
    final friso = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, frisoY), width: lidW, height: 5.8), const Radius.circular(2));
    canvas.drawRRect(friso, Paint()..shader = LinearGradient(colors: [Color.lerp(AppColors.bauOuro, Colors.white, 0.38)!, AppColors.bauOuro, AppColors.bauOuroEscuro]).createShader(friso.outerRect));
    canvas.drawRRect(friso, Paint()..color = Colors.black.withValues(alpha: 0.28)..style = PaintingStyle.stroke..strokeWidth = 0.75);
    canvas.drawRect(Rect.fromCenter(center: Offset(0, frisoY - 1.0), width: lidW * 0.92, height: 1.1), Paint()..color = Colors.white.withValues(alpha: 0.32));
    if (cosA > 0.12) {
      canvas.drawArc(Rect.fromCenter(center: Offset(0, -visH + 0.6), width: lidW * 0.985, height: visH * 1.55), 0, pi, false, Paint()..color = Colors.white.withValues(alpha: 0.13 * cosA)..style = PaintingStyle.stroke..strokeWidth = 1.8);
      canvas.drawArc(Rect.fromCenter(center: Offset(0, -visH * 0.92), width: lidW * 0.72, height: visH * 0.55), pi, pi, false, Paint()..color = Colors.white.withValues(alpha: 0.09 * cosA)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    }
    for (final fx in const [-0.242, 0.242]) {
      final faixaH = (visH - 12).clamp(8.0, 28.0);
      final faixa = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(lidW * fx, -visH / 2), width: 9.8, height: faixaH), const Radius.circular(4));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(lidW * fx + 0.5, -visH / 2 + 0.5), width: 9.8, height: faixaH), const Radius.circular(4)), Paint()..color = Colors.black.withValues(alpha: 0.32));
      canvas.drawRRect(faixa, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(AppColors.bauOuro, Colors.white, 0.32)!, AppColors.bauOuro, AppColors.bauOuroEscuro]).createShader(faixa.outerRect));
      canvas.drawRRect(faixa, Paint()..color = const Color(0xFF5A3E05)..style = PaintingStyle.stroke..strokeWidth = 0.85);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(lidW * fx, -visH / 2 - 0.4), width: 7, height: faixaH * 0.58), const Radius.circular(2)), Paint()..color = Colors.white.withValues(alpha: 0.20));
      _rebite(canvas, Offset(lidW * fx, -visH + 9.5));
      _rebite(canvas, Offset(lidW * fx, -9.0));
    }
    if (cosA > 0.18) {
      canvas.save();
      canvas.translate(0, -visH * 0.58);
      final s = (0.85 + 0.15 * cosA);
      canvas.scale(s, s);
      canvas.rotate(pi / 4);
      final glow = Paint()..color = Colors.white.withValues(alpha: 0.10)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 11, height: 11), glow);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 9.5, height: 9.5), const Radius.circular(1.5)), Paint()..shader = LinearGradient(colors: [Color.lerp(AppColors.bauOuro, Colors.white, 0.32)!, AppColors.bauOuroEscuro]).createShader(Rect.fromCenter(center: Offset.zero, width: 9.5, height: 9.5)));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 9.5, height: 9.5), const Radius.circular(1.5)), Paint()..color = const Color(0xFF5A3E05)..style = PaintingStyle.stroke..strokeWidth = 0.9);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 4.8, height: 4.8), Paint()..color = const Color(0xFF7A5806));
      canvas.drawRect(Rect.fromCenter(center: Offset(-0.7, -0.7), width: 2.2, height: 2.2), Paint()..color = Colors.white.withValues(alpha: 0.65));
      canvas.restore();
    }
    if (sinA > 0.12) {
      final innerH = (thickness * 0.92).clamp(3.0, 7.0);
      final inner = RRect.fromRectAndRadius(Rect.fromLTRB(-lidW / 2 + 1, 0.6, lidW / 2 - 1, 0.6 + innerH * sinA), const Radius.circular(2));
      canvas.drawRRect(inner, Paint()..color = const Color(0xFF5A3418));
      canvas.drawRRect(inner, Paint()..color = Colors.black.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 0.7);
      canvas.drawRect(Rect.fromLTRB(-lidW / 2 + 6, 0.8, lidW / 2 - 6, 1.8), Paint()..color = AppColors.bauOuro.withValues(alpha: 0.85 * sinA));
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(_BauPainter old) => old.p != p;
}

/// Parabéns por terminar uma CATEGORIA (fora do mapa-múndi): festa com
/// confetes + "Jogar de novo" ou "Sair".
class _FimCategoriaDialog extends StatefulWidget {
  const _FimCategoriaDialog({required this.titulo});

  /// Título da categoria concluída, ex.: "🍎  Alimentos · Fácil".
  final String titulo;

  @override
  State<_FimCategoriaDialog> createState() => _FimCategoriaDialogState();
}

class _FimCategoriaDialogState extends State<_FimCategoriaDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _escala = CurvedAnimation(
    parent: _c,
    curve: Curves.elasticOut,
  );

  @override
  void initState() {
    super.initState();
    unawaited(Fala.instance.falar('Parabéns! Você terminou!'));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Largura limitada: a janela não precisa esticar até a borda da tela.
      constraints: const BoxConstraints(maxWidth: 360),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      title: Text(
        'PARABÉNS! 🎉',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
      ),
      content: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: ConfeteBurst(muito: true)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _escala,
                child: const Text('🏆', style: TextStyle(fontSize: 52)),
              ),
              const SizedBox(height: 6),
              Text(
                'Você terminou:\n${widget.titulo}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Sair'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('Jogar de novo'),
        ),
      ],
    );
  }
}

/// Botão V (verde, acertou) / X (vermelho, errou) do topo direito — QUADRADO
/// com bordas levemente arredondadas (mesmo clima dos botões de baixo).
class _BotaoAcertoErro extends StatelessWidget {
  const _BotaoAcertoErro({
    required this.cor,
    required this.letra,
    required this.tooltip,
    required this.onTap,
  });

  final Color cor;
  final String letra;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: cor.withValues(alpha: 0.6),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              letra,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opção de sílaba (modo "completar"): botão grande com a sílaba. `errada` =
/// pinta de vermelho quando a criança toca na errada.
class _OpcaoSilaba extends StatelessWidget {
  const _OpcaoSilaba({
    required this.texto,
    required this.errada,
    required this.ui,
    required this.onTap,
  });

  final String texto;
  final bool errada;
  final Color ui;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borda = errada ? AppColors.danger : ui.withValues(alpha: 0.4);
    return Material(
      color: errada ? AppColors.danger : ui.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 92),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borda, width: 2),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: errada ? Colors.white : ui,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão da barra inferior — BAIXO (ícone + rótulo lado a lado). `destaque` =
/// preenchido com o accent (o "Próximo"). Cores adaptam ao fundo via [ui].
class _Botao extends StatelessWidget {
  const _Botao({
    required this.icon,
    required this.label,
    required this.ui,
    required this.onTap,
    this.destaque = false,
  });

  final IconData icon;
  final String label;
  final Color ui;
  final VoidCallback? onTap;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    final Color fg;
    final Color bg;
    if (destaque) {
      fg = Colors.white;
      bg = habilitado
          ? AppColors.accent
          : AppColors.accent.withValues(alpha: 0.35);
    } else {
      fg = ui.withValues(alpha: habilitado ? 0.9 : 0.3);
      bg = ui.withValues(alpha: habilitado ? 0.08 : 0.04);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: fg, size: 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
