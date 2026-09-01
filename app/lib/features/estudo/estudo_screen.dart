import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/alimentos_tema.dart';
import '../../models/categoria.dart';
import '../../models/estudo_opcoes.dart';
import '../../models/modo_leitura.dart';
import '../../models/nomes_tema.dart';
import '../../models/palavra.dart';
import '../../models/regiao.dart';
import '../../models/tema.dart';
import '../../services/banco_palavras.dart';
import '../../services/completar_silaba.dart';
import '../../services/config_leitura.dart';
import '../../services/config_mic.dart';
import '../../services/config_ordem.dart';
import '../../services/fala.dart';
import '../../services/reconhecimento.dart';
import '../../services/voz.dart';
import '../../services/progresso_alimentos_fases.dart';
import '../../services/progresso_fases.dart';
import '../../services/progresso_nomes_temas_fases.dart';
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
    this.nomesTemaConcluivel,
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

  final String? nomesTemaConcluivel;

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

  // ── Modo Microfone (o Davi FALA a palavra e o app decide) ──
  int _tentativas = 0; // erros seguidos NA PALAVRA ATUAL (zera ao trocar)
  bool _ouvindo = false; // está gravando/ouvindo agora
  bool _micAceito = false; // já aceitou o acerto NESTA escuta (via parcial)?
  double _nivelMic = 0; // 0..1 — volume captado (barra "estou te ouvindo")
  String? _statusMic; // "🎤 Ouvindo…" / "Tenta de novo!" / "Não entendi"
  bool _micAtivado = true; // o pai/mãe ligou o mic nas Configurações?
  int _micTolerancia = kTolerancia; // ajuste fino escolhido nas Configurações

  /// Máximo de tentativas por palavra antes de o app falar a resposta e passar.
  static const _maxTentativas = 3;

  /// Texto do status enquanto está ouvindo (constante p/ o _fimMic comparar).
  static const _msgOuvindo = '🎤 Ouvindo… fala pertinho do celular';

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
    final micAtivado = await ConfigMic.ativado();
    final micTolerancia = await ConfigMic.tolerancia();
    if (mounted) {
      setState(() {
        _moedas = moedas;
        _xp = xp;
        _modo = modo;
        _micAtivado = micAtivado;
        _micTolerancia = micTolerancia;
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
      _tentativas = 0; // acertou → zera as tentativas do microfone
      _statusMic = null;
      _confeteSeq++;
      if (bonus > 0) {
        _mostrarFeedback('🔥 $_sequencia seguidas! +$bonus');
      } else {
        _mostrarFeedback('+$pontos');
      }
    });
    await _avancarAposResposta();
  }

  /// Fecha a fase (baú) ou avança para a próxima palavra. Compartilhado pelo
  /// acerto (V/microfone) e pelo fim das 3 tentativas do microfone — evita
  /// duplicar o switch de conclusão de fases.
  Future<void> _avancarAposResposta() async {
    final ultima = _i == widget.palavras.length - 1;
    final habitat = widget.habitatConcluivel;
    final alimentosTema = widget.alimentosTemaConcluivel;
    final objetosTema = widget.objetosTemaConcluivel;
    final nomesTema = widget.nomesTemaConcluivel;
    if (ultima && habitat != null) {
      await _concluirFase();
    } else if (ultima && alimentosTema != null) {
      await _concluirFaseAlimentos();
    } else if (ultima && objetosTema != null) {
      await _concluirFaseObjetosTemas();
    } else if (ultima && nomesTema != null) {
      await _concluirFaseNomesTemas();
    } else if (ultima) {
      await _fimDeCategoria(); // pode ter SAÍDO da tela ("Sair")
    } else if (_temProximo) {
      setState(() {
        _i++;
        _tentativas = 0;
      });
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

  // ── Modo Microfone: o Davi toca no 🎤, FALA a palavra e o app decide ──

  /// Toca no microfone: começa a ouvir a criança dizer a palavra atual. Se já
  /// estiver ouvindo, para. Se o aparelho não tiver microfone/reconhecedor,
  /// avisa sem travar.
  Future<void> _ouvirMic() async {
    if (_ouvindo) {
      await Voz.instance.parar();
      return;
    }
    final ok = await Voz.instance.disponivel();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microfone não disponível neste aparelho.')),
      );
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _ouvindo = true;
      _micAceito = false;
      _nivelMic = 0;
      _statusMic = _msgOuvindo;
    });
    await Voz.instance.ouvir(
      onResultado: _resultadoMic,
      onParcial: _parcialMic,
      onFim: _fimMic,
      onNivel: (n) {
        if (mounted && _ouvindo) setState(() => _nivelMic = n);
      },
    );
  }

  /// Resultado PARCIAL (enquanto fala): se já bater com a palavra, ACEITA na
  /// hora — não espera o silêncio → acerto quase instantâneo.
  Future<void> _parcialMic(List<String> ditas) async {
    if (_micAceito || !mounted) return;
    final alvo = widget.palavras[_i].texto;
    if (!reconheceu(alvo, ditas, tolerancia: _micTolerancia)) return;
    _micAceito = true;
    unawaited(Voz.instance.parar()); // para de ouvir imediatamente
    setState(() {
      _ouvindo = false;
      _nivelMic = 0;
      _statusMic = null;
    });
    await _acertou();
  }

  /// Chegou o que a criança falou (principal + alternativas do motor; **vazio**
  /// se não entendeu). Acertou → mesmo efeito do V. Errou → conta tentativa; na
  /// 3ª, falha. Não entendeu → avisa SEM gastar tentativa (mostra o que ouviu).
  Future<void> _resultadoMic(List<String> ditas) async {
    if (!mounted || _micAceito) return; // já aceito no parcial → ignora o final
    final limpas = ditas.where((s) => s.trim().isNotEmpty).toList();
    if (limpas.isEmpty) {
      setState(() {
        _ouvindo = false;
        _nivelMic = 0;
        _statusMic = 'Não entendi 🤔 Toca no 🎤 e fala de novo.';
      });
      return;
    }
    setState(() {
      _ouvindo = false;
      _nivelMic = 0;
    });
    final alvo = widget.palavras[_i].texto;
    if (reconheceu(alvo, limpas, tolerancia: _micTolerancia)) {
      setState(() => _statusMic = null);
      await _acertou();
      return;
    }
    _tentativas++;
    if (_tentativas >= _maxTentativas) {
      await _falharPalavra(alvo);
    } else {
      final faltam = _maxTentativas - _tentativas;
      // mostra o que ele ouviu — ajuda a criança e a calibrar a tolerância
      setState(() => _statusMic =
          'Ouvi "${limpas.first}" 🙂 Tenta de novo (falta${faltam == 1 ? '' : 'm'} $faltam)');
    }
  }

  /// A escuta terminou. Reabilita o botão; se ainda estava "Ouvindo…" (nenhum
  /// resultado processado), avisa que não entendeu.
  void _fimMic() {
    if (!mounted) return;
    setState(() {
      _ouvindo = false;
      _nivelMic = 0;
      if (_statusMic == _msgOuvindo) {
        _statusMic = 'Não entendi 🤔 Toca no 🎤 e fala de novo.';
      }
    });
  }

  /// Errou [_maxTentativas] vezes seguidas: mesmo efeito do X (perde pontos,
  /// "-N"), o app FALA a palavra certa (vira aprendizado) e passa para a próxima.
  Future<void> _falharPalavra(String alvo) async {
    setState(() => _statusMic = null);
    await _errou(); // desconta pontos, mostra "-N", zera a sequência
    if (!mounted) return;
    _tentativas = 0;
    await Fala.instance.falar(alvo); // ex.: fala "gato"
    if (!mounted) return;
    await _avancarAposResposta();
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
    if (!mounted) return;
    if (jogar == true && proxima != null) {
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
    } else if (jogar == false) {
      Navigator.of(context).pop();
    }
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
    if (!mounted) return;
    if (jogar == true && proxima != null) {
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
    } else if (jogar == false) {
      Navigator.of(context).pop();
    }
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
    if (!mounted) return;
    if (jogar == true && proxima != null) {
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
    } else if (jogar == false) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _concluirFaseNomesTemas() async {
    final tema = NomesTema.porChave(widget.nomesTemaConcluivel!);
    await ProgressoRepository.registrarBonusFase();
    await ProgressoNomesTemasFases.marcarConcluido(widget.nomesTemaConcluivel!);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() => _moedas += ProgressoRepository.bonusFase);
    final fases = NomesTema.values;
    final i = fases.indexWhere((t) => t.chave == widget.nomesTemaConcluivel);
    final proxima = (i >= 0 && i < fases.length - 1) ? fases[i + 1] : null;
    final jogar = await showDialog<bool>(
      context: context,
      builder: (_) => _BauNomesTemasDialog(
        tema: tema,
        proxima: proxima,
      ),
    );
    if (!mounted) return;
    if (jogar == true && proxima != null) {
      final palavras = switch (proxima) {
        NomesTema.curtos => palavrasDe(Categoria.nomes, Nivel.facil),
        NomesTema.medios => palavrasDe(Categoria.nomes, Nivel.media),
        NomesTema.longos => palavrasDe(Categoria.nomes, Nivel.dificil),
        NomesTema.compostos => palavrasDoTema('compostos'),
      };
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EstudoScreen(
            titulo: '${proxima.emoji}  ${proxima.rotulo}',
            palavras: palavras,
            manterPaisagemAoSair: true,
            nomesTemaConcluivel: proxima.chave,
          ),
        ),
      );
    } else if (jogar == false) {
      Navigator.of(context).pop();
    }
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
        _tentativas = 0;
        _statusMic = null;
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
    if (widget.nomesTemaConcluivel != null &&
        _i == widget.palavras.length - 1) {
      ProgressoNomesTemasFases.marcarConcluido(widget.nomesTemaConcluivel!);
    }
  }

  @override
  void dispose() {
    unawaited(Voz.instance.parar()); // se estava ouvindo, para ao sair
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
      _tentativas = 0;
      _statusMic = null;
    });
    _prepararIncompleta();
    _falarPalavraAtual();
  }

  void _proximo() {
    if (!_temProximo) return;
    setState(() {
      _i++;
      _tracos.clear();
      _tentativas = 0;
      _statusMic = null;
    });
    _talvezConcluir();
    _prepararIncompleta();
    _falarPalavraAtual();
  }

  void _recomecar() {
    setState(() {
      _i = 0;
      _tracos.clear();
      _tentativas = 0;
      _statusMic = null;
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
    return Transform.translate(
      offset: const Offset(-6, 0),
      child: Padding(
        padding: const EdgeInsets.only(left: 0, top: 2),
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
            // status do microfone ("Ouvindo…", "Tenta de novo", "Não entendi")
            // + barra "estou te ouvindo" (mexe conforme o volume captado).
            if (_statusMic != null || _ouvindo)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_statusMic != null)
                      Text(
                        _statusMic!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ui.withValues(alpha: 0.88),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (_ouvindo) ...[
                      const SizedBox(height: 4),
                      _MedidorNivel(nivel: _nivelMic, ui: ui),
                    ],
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
                  // 🎤 Falar — o Davi toca, fala a palavra, o app decide sozinho.
                  // Só se ligado nas Configurações e nos modos de palavra inteira
                  // (no "completar" é por toque).
                  if (_micAtivado && _modo != ModoLeitura.incompleta)
                    _BotaoMic(ouvindo: _ouvindo, onTap: _ouvirMic),
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
    duration: const Duration(milliseconds: 750),
  );
  late final AnimationController _card = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
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
                    p: Curves.easeOutCubic.transform(_abertura.value),
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
    duration: const Duration(milliseconds: 750),
  );
  late final AnimationController _card = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
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
                  builder: (_, _) => _Bau(p: Curves.easeOutCubic.transform(_abertura.value), onTap: _abrirBau),
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
  late final AnimationController _abertura = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  late final AnimationController _card = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
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
                AnimatedBuilder(animation: _abertura, builder: (_, _) => _Bau(p: Curves.easeOutCubic.transform(_abertura.value), onTap: _abrirBau)),
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

class _BauNomesTemasDialog extends StatefulWidget {
  const _BauNomesTemasDialog({required this.tema, required this.proxima});
  final NomesTema? tema;
  final NomesTema? proxima;
  @override
  State<_BauNomesTemasDialog> createState() => _BauNomesTemasDialogState();
}

class _BauNomesTemasDialogState extends State<_BauNomesTemasDialog>
    with TickerProviderStateMixin {
  late final AnimationController _abertura = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  late final AnimationController _card = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
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
    unawaited(proxima == null ? Fala.instance.falar('Parabéns! Você completou a aventura dos nomes!') : Fala.instance.falar('Você desbloqueou ${proxima.rotulo}!'));
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
                AnimatedBuilder(animation: _abertura, builder: (_, _) => _Bau(p: Curves.easeOutCubic.transform(_abertura.value), onTap: _abrirBau)),
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
                          child: Transform.scale(scale: 0.15 + 0.85 * t, child: _CardNovaFaseNomes(proxima: widget.proxima, ehUltima: ehUltima)),
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
            Text('${widget.tema!.premioEmoji} Novo nome desbloqueado: ${widget.tema!.premioNome}!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
          if (!_aberto) ...[const SizedBox(height: 4), const Text('Toque no baú para abrir! 🗝️', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bauOuro))],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      actions: _aberto
          ? (ehUltima
              ? [FilledButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar à chegada'))]
              : [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Chegada')), FilledButton.icon(onPressed: () => Navigator.pop(context, true), icon: const Icon(Icons.play_arrow_rounded), label: const Text('JOGAR AGORA'))])
          : const [],
    );
  }
}

class _CardNovaFaseNomes extends StatelessWidget {
  const _CardNovaFaseNomes({required this.proxima, required this.ehUltima});
  final NomesTema? proxima;
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
            ? const Column(mainAxisSize: MainAxisSize.min, children: [Text('🏁', style: TextStyle(fontSize: 34)), SizedBox(height: 2), Text('AVENTURA CONCLUÍDA!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)), Text('Todos os nomes! 🎉', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))])
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
        painter: BauPainter(p),
      ),
    );
  }
}

/// Painter do baú do tesouro em **3D de videogame** (perspectiva 3/4,
/// projeção cavalier): enxerga frente + lateral direita + topo/interior.
/// Público para permitir preview/testes de render (test/bau_preview_test.dart).
///
/// Modelo 3D em px: X = largura (centro 0), Y = altura (0 = boca do baú,
/// corpo desce até -_alt), Z = profundidade (0 = frente, _prof = trás, onde
/// fica a DOBRADIÇA). Projeção: tela = (ox + X + _kx*Z, oy - Y - _ky*Z).
///
/// A TAMPA é um semicilindro (eixo X, raio _raioT) com espessura, que GIRA em
/// torno da linha da dobradiça (Z=_prof, Y=0) — nunca em torno do centro. O
/// corpo fica parado; as moedas ficam dentro; a abertura chega a ~90°.
class BauPainter extends CustomPainter {
  BauPainter(this.p);

  /// Abertura: 0 = fechado → 1 = aberto (90°). Já vem suavizado (easeOut) do
  /// AnimationController; aqui só um overshoot sutil de acomodação.
  final double p;

  final Random _r = Random(7);

  // ── medidas 3D (px) ──
  static const _larg = 98.0; // largura da frente
  static const _prof = 32.0; // profundidade (frente → dobradiça)
  static const _alt = 42.0; // altura do corpo
  static const _raioT = _prof / 2; // raio da tampa semicircular
  static const _espT = 3.2; // espessura da tampa
  static const _parede = 4.0; // parede interna
  static const _saia = 5.0; // saia frontal da tampa (cobre a junção)

  // ── projeção cavalier: +Z = trás-direita-cima ──
  static const _kx = 0.55;
  static const _ky = 0.30;

  double _ox = 0; // centro da boca frontal em tela
  double _oy = 0;

  Offset _proj(double x, double y, double z) =>
      Offset(_ox + x + _kx * z, _oy - y - _ky * z);

  /// Ângulo da tampa (0 → 90°) com leve overshoot de acomodação no fim.
  double get _theta {
    final t = p.clamp(0.0, 1.0);
    return (t + 0.06 * sin(t * pi) * (1 - t)) * (pi / 2);
  }

  /// Ponto da TAMPA: coordenadas de fechada (y0, z0) giradas θ em torno da
  /// dobradiça (Z=_prof, Y=0).
  Offset _lid(double x, double y0, double z0) {
    final th = _theta;
    final s = sin(th);
    final c = cos(th);
    final dz0 = z0 - _prof;
    final y = y0 * c - dz0 * s;
    final z = _prof + y0 * s + dz0 * c;
    return _proj(x, y, z);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _ox = size.width * 0.462;
    _oy = size.height * 0.50;
    final th = _theta;
    _sombraChao(canvas, th);
    _glow(canvas, size, th);
    if (th > 0.05) {
      _interior(canvas, th);
    }
    if (th > 0.22) {
      _tesouro(canvas, th);
    }
    _corpo(canvas);
    _derramado(canvas, th);
    _cadeado(canvas);
    _tampa(canvas, th);
  }

  // ── sombra no chão (acompanha a abertura: a tampa projeta sombra atrás) ──
  void _sombraChao(Canvas canvas, double th) {
    final s = sin(th);
    final base = _proj(0, -_alt, _prof * 0.45);
    canvas.drawOval(
      Rect.fromCenter(
          center: base + const Offset(0, 3), width: _larg * 1.28, height: 15),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: base + const Offset(0, 2), width: _larg * 1.05, height: 10),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    if (s > 0.08) {
      final atras = _proj(0, -_alt, _prof + 4 + s * _prof * 0.7);
      canvas.drawOval(
        Rect.fromCenter(
            center: atras + const Offset(0, 2.5),
            width: _larg * 0.9,
            height: 8),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.20 * s)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }

  // ── luz dourada saindo do interior (cresce com a abertura) ──
  void _glow(Canvas canvas, Size size, double th) {
    if (th <= 0.02) return;
    final f = (th / 1.2).clamp(0.0, 1.0);
    final c = _proj(0, 3, _prof * 0.45);
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.bauOuro.withValues(alpha: 0.55 * f),
            AppColors.bauOuro.withValues(alpha: 0.14 * f),
            AppColors.bauOuro.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(
            Rect.fromCircle(center: c, radius: 52 + 26 * f)),
    );
  }

  // ── interior: piso + paredes internas (escuras) visíveis ao abrir ──
  void _interior(Canvas canvas, double th) {
    final xi = _larg / 2 - _parede;
    final z0 = _parede;
    final z1 = _prof - _parede;
    const yPiso = -6.0;

    // piso (visto de cima)
    final piso = Path()
      ..moveTo(_proj(-xi, yPiso, z1).dx, _proj(-xi, yPiso, z1).dy)
      ..lineTo(_proj(xi, yPiso, z1).dx, _proj(xi, yPiso, z1).dy)
      ..lineTo(_proj(xi, yPiso, z0).dx, _proj(xi, yPiso, z0).dy)
      ..lineTo(_proj(-xi, yPiso, z0).dx, _proj(-xi, yPiso, z0).dy)
      ..close();
    canvas.drawPath(piso, Paint()..color = const Color(0xFF241304));
    canvas.drawPath(
      piso,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
        ).createShader(piso.getBounds()),
    );

    // parede frontal interna (recebe luz: mais clara)
    final pF = Path()
      ..moveTo(_proj(-xi, 0, z1).dx, _proj(-xi, 0, z1).dy)
      ..lineTo(_proj(xi, 0, z1).dx, _proj(xi, 0, z1).dy)
      ..lineTo(_proj(xi, yPiso, z1).dx, _proj(xi, yPiso, z1).dy)
      ..lineTo(_proj(-xi, yPiso, z1).dx, _proj(-xi, yPiso, z1).dy)
      ..close();
    canvas.drawPath(pF, Paint()..color = const Color(0xFF3A2410));

    // parede traseira interna (em sombra: a mais escura)
    final pT = Path()
      ..moveTo(_proj(-xi, 0, z0).dx, _proj(-xi, 0, z0).dy)
      ..lineTo(_proj(xi, 0, z0).dx, _proj(xi, 0, z0).dy)
      ..lineTo(_proj(xi, yPiso, z0).dx, _proj(xi, yPiso, z0).dy)
      ..lineTo(_proj(-xi, yPiso, z0).dx, _proj(-xi, yPiso, z0).dy)
      ..close();
    canvas.drawPath(pT, Paint()..color = const Color(0xFF180B04));

    // parede lateral direita interna
    final pL = Path()
      ..moveTo(_proj(xi, 0, z1).dx, _proj(xi, 0, z1).dy)
      ..lineTo(_proj(xi, 0, z0).dx, _proj(xi, 0, z0).dy)
      ..lineTo(_proj(xi, yPiso, z0).dx, _proj(xi, yPiso, z0).dy)
      ..lineTo(_proj(xi, yPiso, z1).dx, _proj(xi, yPiso, z1).dy)
      ..close();
    canvas.drawPath(pL, Paint()..color = const Color(0xFF1E0F06));

    // sombra que a tampa projeta no interior enquanto abre
    final cobre = (1 - th / 1.45).clamp(0.0, 1.0);
    if (cobre > 0.02) {
      final boca = Path()
        ..moveTo(_proj(-xi, 0, z1).dx, _proj(-xi, 0, z1).dy)
        ..lineTo(_proj(xi, 0, z1).dx, _proj(xi, 0, z1).dy)
        ..lineTo(_proj(xi, 0, z0).dx, _proj(xi, 0, z0).dy)
        ..lineTo(_proj(-xi, 0, z0).dx, _proj(-xi, 0, z0).dy)
        ..close();
      canvas.drawPath(
          boca,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.55 * cobre));
    }
  }

  // ── monte de moedas (posições 3D fixas — não tremem entre frames) ──
  late final List<({double x, double y, double z, double s, Color? joia})>
      _monte = _gerarMonte();

  List<({double x, double y, double z, double s, Color? joia})> _gerarMonte() {
    final rnd = Random(11);
    final list = <({double x, double y, double z, double s, Color? joia})>[];
    for (var i = 0; i < 6; i++) {
      list.add((
        x: -36 + i * 14 + rnd.nextDouble() * 6 - 3,
        y: -5.2,
        z: 9 + rnd.nextDouble() * 16,
        s: 1.0,
        joia: null,
      ));
    }
    for (var i = 0; i < 5; i++) {
      list.add((
        x: -28 + i * 14 + rnd.nextDouble() * 5 - 2.5,
        y: -1.8,
        z: 11 + rnd.nextDouble() * 12,
        s: 0.97,
        joia: null,
      ));
    }
    for (var i = 0; i < 3; i++) {
      list.add((
        x: -14 + i * 14 + rnd.nextDouble() * 4 - 2,
        y: 1.6,
        z: 14 + rnd.nextDouble() * 7,
        s: 0.94,
        joia: null,
      ));
    }
    list[3] = (
      x: list[3].x,
      y: list[3].y,
      z: list[3].z,
      s: 1.0,
      joia: AppColors.acerto, // esmeralda
    );
    list[10] = (
      x: list[10].x,
      y: list[10].y,
      z: list[10].z,
      s: 0.9,
      joia: AppColors.accent, // safira
    );
    // pintor 3D: trás primeiro (z maior), mais baixo antes
    list.sort((a, b) {
      final dz = b.z.compareTo(a.z);
      return dz != 0 ? dz : a.y.compareTo(b.y);
    });
    return list;
  }

  void _tesouro(Canvas canvas, double th) {
    final f = ((th - 0.22) / 0.5).clamp(0.0, 1.0);
    for (final m in _monte) {
      final c = _proj(m.x, m.y, m.z);
      if (m.joia != null) {
        _joia(canvas, c + const Offset(0, -2), 6.4 * m.s, m.joia!);
      } else {
        _moeda3d(canvas, c, m.s);
      }
    }
    // brilhos sobre o monte
    for (var i = 0; i < 4; i++) {
      final bx = -20 + i * 13 + _r.nextDouble() * 6 - 3;
      final bz = 12 + _r.nextDouble() * 10;
      final c = _proj(bx, 4 + _r.nextDouble() * 3, bz);
      _brilho(canvas, c, 2.6 + _r.nextDouble() * 1.4, (0.35 + 0.55 * f));
    }
  }

  /// Moeda deitada (plano XZ) projetada: elipse metálica com espessura,
  /// aro interno e highlight — volume dourado, não um círculo chapado.
  void _moeda3d(Canvas canvas, Offset c, double s) {
    final rx = 5.4 * s;
    final ry = rx * 0.40;
    // sombra projetada (luz de cima-esquerda)
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(1.6 * s, 1.4 * s), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.black.withValues(alpha: 0.34),
    );
    // espessura (borda inferior mais escura)
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(0, 1.2 * s), width: rx * 2, height: ry * 2),
      Paint()..color = const Color(0xFF8C6A0E),
    );
    // face superior metálica
    final face = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      face,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.42, -0.55),
          radius: 1.0,
          colors: [
            Color.lerp(AppColors.bauOuro, Colors.white, 0.55)!,
            AppColors.bauOuro,
            const Color(0xFFE8A910),
            AppColors.bauOuroEscuro,
          ],
          stops: const [0.0, 0.34, 0.68, 1.0],
        ).createShader(face),
    );
    canvas.drawOval(
      face,
      Paint()
        ..color = AppColors.bauOuroEscuro.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9 * s,
    );
    // aro interno + centro (detalhe de moeda cunhada)
    canvas.drawOval(
      Rect.fromCenter(center: c, width: rx * 1.3, height: ry * 1.3),
      Paint()
        ..color = AppColors.bauOuroEscuro.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7 * s,
    );
    // highlight especular
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(-rx * 0.30, -ry * 0.40),
          width: rx * 0.6,
          height: ry * 0.5),
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  /// Joia em losango facetada (esmeralda/safira).
  void _joia(Canvas canvas, Offset c, double r, Color cor) {
    canvas.drawOval(
      Rect.fromCenter(
          center: c + Offset(0.9, 1.3), width: r * 1.6, height: r * 1.3),
      Paint()..color = Colors.black.withValues(alpha: 0.38),
    );
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * 0.82, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * 0.82, c.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(cor, Colors.white, 0.48)!,
            cor,
            Color.lerp(cor, Colors.black, 0.58)!,
          ],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final faceta = Paint()
      ..color = Colors.white.withValues(alpha: 0.52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(c.dx - r * 0.52, c.dy - r * 0.32),
        Offset(c.dx + r * 0.52, c.dy - r * 0.32), faceta);
    canvas.drawLine(Offset(c.dx - r * 0.52, c.dy - r * 0.32),
        Offset(c.dx, c.dy + r * 0.28), faceta);
    canvas.drawLine(Offset(c.dx + r * 0.52, c.dy - r * 0.32),
        Offset(c.dx, c.dy + r * 0.28), faceta);
    canvas.drawCircle(c + Offset(-r * 0.28, -r * 0.32), r * 0.22,
        Paint()..color = Colors.white.withValues(alpha: 0.92));
  }

  /// Estrelinha de brilho (duas cápsulas cruzadas + núcleo).
  void _brilho(Canvas canvas, Offset c, double r, double alpha) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: r * 3.8, height: r * 0.95),
          Radius.circular(r / 2)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: r * 0.95, height: r * 3.8),
          Radius.circular(r / 2)),
      paint,
    );
    canvas.drawCircle(
        c, r * 0.78, Paint()..color = Colors.white.withValues(alpha: alpha));
    canvas.drawCircle(c, r * 0.28, Paint()..color = Colors.white);
  }

  // ── corpo: frente + lateral direita + frisos/faixas/rebites ──
  void _corpo(Canvas canvas) {
    final a = _proj(-_larg / 2, 0, 0); // boca frente esq
    final b = _proj(_larg / 2, 0, 0); // boca frente dir
    final c = _proj(_larg / 2, -_alt, 0); // base frente dir
    final d = _proj(-_larg / 2, -_alt, 0); // base frente esq
    final bz = _proj(_larg / 2, 0, _prof); // boca trás dir
    final cz = _proj(_larg / 2, -_alt, _prof); // base trás dir

    // contorno de sombra do corpo inteiro
    final sombraCorpo = Path()
      ..moveTo(a.dx + 1, a.dy + 1)
      ..lineTo(bz.dx + 1, bz.dy + 1)
      ..lineTo(cz.dx + 1, cz.dy + 1)
      ..lineTo(c.dx + 1, c.dy + 1)
      ..lineTo(d.dx + 1, d.dy + 1)
      ..close();
    canvas.drawPath(sombraCorpo, Paint()..color = Colors.black.withValues(alpha: 0.30));

    // LATERAL DIREITA (mais escura: menos luz)
    final lado = Path()
      ..moveTo(b.dx, b.dy)
      ..lineTo(bz.dx, bz.dy)
      ..lineTo(cz.dx, cz.dy)
      ..lineTo(c.dx, c.dy)
      ..close();
    canvas.drawPath(
      lado,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF7A4A1F),
            Color(0xFF6B3E1A),
            Color(0xFF3A1F0A),
          ],
        ).createShader(lado.getBounds()),
    );
    canvas.drawPath(
      lado,
      Paint()
        ..color = const Color(0xFF2A1608)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    // tábuas da lateral (vincos ao longo de Z)
    final vincoL = Paint()
      ..color = const Color(0xFF2A1608).withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (final zz in const [10.0, 20.0]) {
      final p1 = _proj(_larg / 2, 0, zz);
      final p2 = _proj(_larg / 2, -_alt, zz);
      canvas.drawLine(p1, p2, vincoL);
    }
    // friso dourado da boca + rodapé na lateral
    _faixaOuroQuad(canvas, _proj(_larg / 2, -1.2, 0), _proj(_larg / 2, -1.2, _prof),
        _proj(_larg / 2, -4.6, _prof), _proj(_larg / 2, -4.6, 0), claro: false);
    _faixaOuroQuad(canvas, _proj(_larg / 2, -_alt + 3.4, 0),
        _proj(_larg / 2, -_alt + 3.4, _prof), cz, c, claro: false);
    // faixa vertical da lateral (meio) com rebites
    final zMeio = _prof / 2;
    _faixaOuroQuad(canvas, _proj(_larg / 2, -3, zMeio - 3.4),
        _proj(_larg / 2, -3, zMeio + 3.4),
        _proj(_larg / 2, -_alt + 4, zMeio + 3.4),
        _proj(_larg / 2, -_alt + 4, zMeio - 3.4));
    _rebite(canvas, _proj(_larg / 2, -8, zMeio));
    _rebite(canvas, _proj(_larg / 2, -_alt + 8, zMeio));

    // FRENTE (mais clara: luz principal)
    final frente = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(d.dx, d.dy)
      ..close();
    canvas.drawPath(
      frente,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFFB57E3E),
            Color(0xFF9C6B3C),
            Color(0xFF6B4523),
            Color(0xFF4E2E14),
          ],
          stops: const [0.0, 0.4, 0.78, 1.0],
        ).createShader(frente.getBounds()),
    );
    canvas.drawPath(
      frente,
      Paint()
        ..color = const Color(0xFF2A1608)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    // aresta frontal direita (oclusão entre frente e lateral)
    canvas.drawLine(
        b, c, Paint()..color = Colors.black.withValues(alpha: 0.4)..strokeWidth = 1.4);

    // tábuas da frente (3 vincos verticais + linha clara ao lado)
    final vinco = Paint()
      ..color = const Color(0xFF2A1608).withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final vincoLuz = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    for (final fx in const [-0.167, 0.0, 0.167]) {
      final x = fx * _larg;
      final p1 = _proj(x, -1, 0);
      final p2 = _proj(x, -_alt + 1, 0);
      canvas.drawLine(p1, p2, vinco);
      canvas.drawLine(p1 + const Offset(0.9, 0), p2 + const Offset(0.9, 0), vincoLuz);
    }
    // veios da madeira (2 ondas sutis na frente)
    final veio = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (final yy in const [-14.0, -26.0]) {
      final path = Path()..moveTo(a.dx + 5, _oy + yy * -1 * -1);
      path.reset();
      path.moveTo(_proj(-_larg / 2 + 5, yy, 0).dx, _proj(-_larg / 2 + 5, yy, 0).dy);
      for (var x = -_larg / 2 + 5; x < _larg / 2 - 4; x += 6) {
        final pt = _proj(x, yy + 1.2 * sin(x / 9), 0);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, veio);
    }

    // friso dourado da boca na frente + rodapé frontal
    _faixaOuroQuad(canvas, a, b, _proj(_larg / 2, -4.4, 0), _proj(-_larg / 2, -4.4, 0));
    _faixaOuroQuad(canvas, _proj(-_larg / 2, -_alt + 3.4, 0),
        _proj(_larg / 2, -_alt + 3.4, 0), c, d, claro: false);
    // faixas verticais da frente com rebites
    for (final fx in const [-0.30, 0.30]) {
      final x = fx * _larg;
      _faixaOuroQuad(canvas, _proj(x - 3.6, -2, 0), _proj(x + 3.6, -2, 0),
          _proj(x + 3.6, -_alt + 4, 0), _proj(x - 3.6, -_alt + 4, 0));
      _rebite(canvas, _proj(x, -8.5, 0));
      _rebite(canvas, _proj(x, -_alt / 2, 0));
      _rebite(canvas, _proj(x, -_alt + 8.5, 0));
    }
  }

  /// Faixa dourada num quadrilátero 3D (4 pontos já projetados).
  void _faixaOuroQuad(Canvas canvas, Offset p1, Offset p2, Offset p3, Offset p4,
      {bool claro = true}) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: claro
              ? [
                  Color.lerp(AppColors.bauOuro, Colors.white, 0.35)!,
                  AppColors.bauOuro,
                  AppColors.bauOuroEscuro,
                ]
              : [
                  AppColors.bauOuro,
                  AppColors.bauOuroEscuro,
                  const Color(0xFF7A5806),
                ],
        ).createShader(path.getBounds()),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF4A3205).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }

  /// Rebite dourado com brilho.
  void _rebite(Canvas canvas, Offset c) {
    canvas.drawCircle(c + const Offset(0.5, 0.6), 1.9,
        Paint()..color = Colors.black.withValues(alpha: 0.4));
    canvas.drawCircle(
      c,
      1.8,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.45),
          colors: [
            Color.lerp(AppColors.bauOuro, Colors.white, 0.5)!,
            AppColors.bauOuro,
            AppColors.bauOuroEscuro,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: 1.8)),
    );
    canvas.drawCircle(c + const Offset(-0.4, -0.5), 0.7,
        Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  // ── moedas que escorrem para o chão à frente (efeito ao abrir) ──
  void _derramado(Canvas canvas, double th) {
    if (th < 1.0) return;
    final f = ((th - 1.0) / 0.55).clamp(0.0, 1.0);
    _moeda3d(canvas, _proj(-24, -_alt + 0.5 - 1.5 * f, -6 - 3 * f), 0.9);
    _moeda3d(canvas, _proj(2, -_alt + 0.2 - 1.0 * f, -8 - 4 * f), 1.0);
    _moeda3d(canvas, _proj(22, -_alt + 0.6 - 1.8 * f, -5 - 2.5 * f), 0.86);
  }

  // ── cadeado na frente do corpo (fixo; a tampa cobre a parte de cima) ──
  void _cadeado(Canvas canvas) {
    final c = _proj(0, -_alt * 0.30, 0);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    final placa = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 13.5, height: 11),
        const Radius.circular(3));
    canvas.drawRRect(placa.shift(const Offset(0.6, 0.9)),
        Paint()..color = Colors.black.withValues(alpha: 0.35));
    canvas.drawRRect(
      placa,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(AppColors.bauOuro, Colors.white, 0.34)!,
            AppColors.bauOuro,
            AppColors.bauOuroEscuro,
          ],
        ).createShader(placa.outerRect),
    );
    canvas.drawRRect(
      placa,
      Paint()
        ..color = const Color(0xFF4A3205)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // buraco da fechadura
    canvas.drawCircle(const Offset(0, -1.2), 1.9,
        Paint()..color = AppColors.bauInterior);
    canvas.drawPath(
      Path()
        ..moveTo(-1.4, -0.6)
        ..lineTo(1.4, -0.6)
        ..lineTo(0, 3.2)
        ..close(),
      Paint()..color = AppColors.bauInterior,
    );
    // alça (arco para cima, some atrás da tampa fechada)
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -5.2), radius: 4.2),
      pi,
      pi,
      false,
      Paint()
        ..color = AppColors.bauOuroEscuro
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
    canvas.restore();
  }

  // ── TAMPA: semicilindro (eixo X) girando na dobradiça traseira ──
  void _tampa(Canvas canvas, double th) {
    const n = 12; // segmentos do arco
    final xl = -_larg / 2;
    final xr = _larg / 2;
    // pontos do arco FECHADO: t∈[0,pi]: frente-base(t=0) → topo → trás-base(t=pi)
    double arcoY(double t) => _raioT * sin(t);
    double arcoZ(double t) => _prof / 2 - _raioT * cos(t);

    // 1) face INTERNA (underside) — aparece quando a tampa levanta
    if (th > 0.12) {
      final ri = _raioT - _espT;
      for (var i = 0; i < n; i++) {
        final t0 = pi * i / n;
        final t1 = pi * (i + 1) / n;
        final q = Path()
          ..moveTo(_lid(xl, ri * sin(t0), _prof / 2 - ri * cos(t0)).dx,
              _lid(xl, ri * sin(t0), _prof / 2 - ri * cos(t0)).dy)
          ..lineTo(_lid(xr, ri * sin(t0), _prof / 2 - ri * cos(t0)).dx,
              _lid(xr, ri * sin(t0), _prof / 2 - ri * cos(t0)).dy)
          ..lineTo(_lid(xr, ri * sin(t1), _prof / 2 - ri * cos(t1)).dx,
              _lid(xr, ri * sin(t1), _prof / 2 - ri * cos(t1)).dy)
          ..lineTo(_lid(xl, ri * sin(t1), _prof / 2 - ri * cos(t1)).dx,
              _lid(xl, ri * sin(t1), _prof / 2 - ri * cos(t1)).dy)
          ..close();
        canvas.drawPath(q, Paint()..color = const Color(0xFF5A3418));
      }
      // estruturas arqueadas internas (2 nervuras douradas escuras)
      final nerv = Paint()
        ..color = AppColors.bauOuroEscuro.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      for (final tt in const [0.35, 0.65]) {
        final path = Path();
        final pIni = _lid(xl, (_raioT - _espT) * sin(pi * tt),
            _prof / 2 - (_raioT - _espT) * cos(pi * tt));
        path.moveTo(pIni.dx, pIni.dy);
        for (var x = xl + 4; x <= xr; x += 5) {
          final pt = _lid(x, (_raioT - _espT) * sin(pi * tt),
              _prof / 2 - (_raioT - _espT) * cos(pi * tt));
          path.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(path, nerv);
      }
      // face interna da saia frontal
      final saiaInt = Path()
        ..moveTo(_lid(xl, 0, 0).dx, _lid(xl, 0, 0).dy)
        ..lineTo(_lid(xr, 0, 0).dx, _lid(xr, 0, 0).dy)
        ..lineTo(_lid(xr, 0, -0.01).dx, _lid(xr, 0, -0.01).dy)
        ..lineTo(_lid(xl, 0, -0.01).dx, _lid(xl, 0, -0.01).dy)
        ..close();
      canvas.drawPath(saiaInt, Paint()..color = const Color(0xFF4A2A12));
    }

    // 2) cap lateral DIREITA (semicírculo com espessura visível)
    final cap = Path()..moveTo(_lid(xr, 0, 0).dx, _lid(xr, 0, 0).dy);
    for (var i = 1; i <= n; i++) {
      final t = pi * i / n;
      final pt = _lid(xr, arcoY(t), arcoZ(t));
      cap.lineTo(pt.dx, pt.dy);
    }
    cap.lineTo(_lid(xr, 0, _prof).dx, _lid(xr, 0, _prof).dy);
    cap.close();
    canvas.drawPath(
      cap,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF8E5A24), Color(0xFF5A3418), Color(0xFF3A1F0A)],
        ).createShader(cap.getBounds()),
    );
    canvas.drawPath(
      cap,
      Paint()
        ..color = const Color(0xFF2A1608)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    // aro dourado da cap
    final aro = Paint()
      ..color = AppColors.bauOuro
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final aroPath = Path();
    final aroIni = _lid(xr + 0.6, arcoY(0.08), arcoZ(0.08));
    aroPath.moveTo(aroIni.dx, aroIni.dy);
    for (var i = 1; i <= n; i++) {
      final t = 0.08 + (pi - 0.16) * i / n;
      final pt = _lid(xr + 0.6, arcoY(t), arcoZ(t));
      aroPath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(aroPath, aro);
    _rebite(canvas, _lid(xr + 0.8, arcoY(pi / 2), arcoZ(pi / 2)));

    // 3) MANTO externo (shading por segmento = volume arqueado)
    for (var i = 0; i < n; i++) {
      final t0 = pi * i / n;
      final t1 = pi * (i + 1) / n;
      final q = Path()
        ..moveTo(_lid(xl, arcoY(t0), arcoZ(t0)).dx,
            _lid(xl, arcoY(t0), arcoZ(t0)).dy)
        ..lineTo(_lid(xr, arcoY(t0), arcoZ(t0)).dx,
            _lid(xr, arcoY(t0), arcoZ(t0)).dy)
        ..lineTo(_lid(xr, arcoY(t1), arcoZ(t1)).dx,
            _lid(xr, arcoY(t1), arcoZ(t1)).dy)
        ..lineTo(_lid(xl, arcoY(t1), arcoZ(t1)).dx,
            _lid(xl, arcoY(t1), arcoZ(t1)).dy)
        ..close();
      // luz de cima-frente: máximo no topo-frontal, escuro atrás
      final tm = (t0 + t1) / 2;
      final lum = 0.45 + 0.55 * sin(tm * 0.85 + 0.42);
      final cor = Color.lerp(const Color(0xFF4E2E14),
          const Color(0xFFC98A44), lum)!;
      canvas.drawPath(q, Paint()..color = cor);
      canvas.drawPath(
          q,
          Paint()
            ..color = const Color(0xFF2A1608).withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5);
    }
    // vincos das tábuas no manto (linhas ao longo do arco)
    final vinco = Paint()
      ..color = const Color(0xFF2A1608).withValues(alpha: 0.35)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    for (final fx in const [-0.167, 0.0, 0.167]) {
      final path = Path();
      final x = fx * _larg;
      final ini = _lid(x, arcoY(0.06), arcoZ(0.06));
      path.moveTo(ini.dx, ini.dy);
      for (var i = 1; i <= n; i++) {
        final t = 0.06 + (pi - 0.12) * i / n;
        final pt = _lid(x, arcoY(t), arcoZ(t));
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, vinco);
    }
    // faixas douradas no manto (seguem o arco) com rebites
    for (final fx in const [-0.30, 0.30]) {
      final x0 = fx * _larg - 3.4;
      final x1 = fx * _larg + 3.4;
      final path = Path();
      final ini = _lid(x0, arcoY(0.05), arcoZ(0.05));
      path.moveTo(ini.dx, ini.dy);
      for (var i = 1; i <= n; i++) {
        final t = 0.05 + (pi - 0.10) * i / n;
        final pt = _lid(x0, arcoY(t), arcoZ(t));
        path.lineTo(pt.dx, pt.dy);
      }
      for (var i = n; i >= 0; i--) {
        final t = 0.05 + (pi - 0.10) * i / n;
        final pt = _lid(x1, arcoY(t), arcoZ(t));
        path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(AppColors.bauOuro, Colors.white, 0.3)!,
              AppColors.bauOuro,
              AppColors.bauOuroEscuro,
            ],
          ).createShader(path.getBounds()),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF4A3205).withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
      _rebite(canvas, _lid((fx * _larg), arcoY(pi / 2), arcoZ(pi / 2)));
      _rebite(canvas, _lid((fx * _larg), arcoY(0.18), arcoZ(0.18)));
    }

    // 4) saia frontal (cobre a junção tampa/corpo) + friso dourado
    final saia = Path()
      ..moveTo(_lid(xl, 0, 0).dx, _lid(xl, 0, 0).dy)
      ..lineTo(_lid(xr, 0, 0).dx, _lid(xr, 0, 0).dy)
      ..lineTo(_lid(xr, -_saia, 0).dx, _lid(xr, -_saia, 0).dy)
      ..lineTo(_lid(xl, -_saia, 0).dx, _lid(xl, -_saia, 0).dy)
      ..close();
    canvas.drawPath(
      saia,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF9C6B3C), Color(0xFF6B4523)],
        ).createShader(saia.getBounds()),
    );
    canvas.drawPath(
      saia,
      Paint()
        ..color = const Color(0xFF2A1608)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    // friso dourado na saia
    final friso = Path()
      ..moveTo(_lid(xl, -1.4, 0).dx, _lid(xl, -1.4, 0).dy)
      ..lineTo(_lid(xr, -1.4, 0).dx, _lid(xr, -1.4, 0).dy)
      ..lineTo(_lid(xr, -3.4, 0).dx, _lid(xr, -3.4, 0).dy)
      ..lineTo(_lid(xl, -3.4, 0).dx, _lid(xl, -3.4, 0).dy)
      ..close();
    canvas.drawPath(
      friso,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Color.lerp(AppColors.bauOuro, Colors.white, 0.35)!,
            AppColors.bauOuro,
            AppColors.bauOuroEscuro,
          ],
        ).createShader(friso.getBounds()),
    );

    // 5) brasão no arco frontal (some ao passar de ~70°)
    if (cos(th) > 0.30) {
      final cB = _lid(0, arcoY(pi * 0.30), arcoZ(pi * 0.30));
      final s = 0.6 + 0.4 * cos(th);
      canvas.save();
      canvas.translate(cB.dx, cB.dy);
      canvas.scale(s, s * 0.9);
      canvas.rotate(pi / 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 8.4, height: 8.4),
            const Radius.circular(1.2)),
        Paint()
          ..shader = LinearGradient(
            colors: [
              Color.lerp(AppColors.bauOuro, Colors.white, 0.32)!,
              AppColors.bauOuroEscuro,
            ],
          ).createShader(Rect.fromCenter(center: Offset.zero, width: 8.4, height: 8.4)),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 8.4, height: 8.4),
            const Radius.circular(1.2)),
        Paint()
          ..color = const Color(0xFF4A3205)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 3.8, height: 3.8),
          Paint()..color = const Color(0xFF7A5806));
      canvas.restore();
    }

    // 6) highlight de contorno no topo do arco
    final cont = Paint()
      ..color = Colors.white.withValues(alpha: 0.16 * cos(th).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final contPath = Path();
    final contIni = _lid(xl, arcoY(pi * 0.38), arcoZ(pi * 0.38));
    contPath.moveTo(contIni.dx, contIni.dy);
    for (var i = 1; i <= 6; i++) {
      final pt = _lid(xl + (xr - xl) * i / 6, arcoY(pi * 0.42), arcoZ(pi * 0.42));
      contPath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(contPath, cont);
  }

  @override
  bool shouldRepaint(BauPainter old) => old.p != p;
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

/// Barra "estou te ouvindo": enche conforme o volume captado (0..1). Serve pra
/// ver, na hora, se o microfone está pegando a voz — mesmo falando baixinho.
class _MedidorNivel extends StatelessWidget {
  const _MedidorNivel({required this.nivel, required this.ui});

  final double nivel; // 0..1
  final Color ui;

  @override
  Widget build(BuildContext context) {
    final n = nivel.clamp(0.0, 1.0);
    // verde quando há sinal, cinza quando quase nada — dica visual clara.
    final cor = n < 0.06 ? ui.withValues(alpha: 0.35) : AppColors.acerto;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.graphic_eq_rounded, size: 16, color: ui.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Container(
          width: 200,
          height: 10,
          decoration: BoxDecoration(
            color: ui.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: n < 0.02 ? 0.02 : n,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botão 🎤 da barra inferior (Modo Microfone): o Davi toca e FALA a palavra.
/// Verde quando pronto; vermelho quando está ouvindo. Mesma altura/estilo do
/// [_Botao] (também `Expanded`) para ficar "junto dos demais".
class _BotaoMic extends StatelessWidget {
  const _BotaoMic({required this.ouvindo, required this.onTap});

  final bool ouvindo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cor = ouvindo ? AppColors.danger : AppColors.acerto;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Material(
          color: cor,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ouvindo ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      ouvindo ? 'Ouvindo…' : 'Falar',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
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
