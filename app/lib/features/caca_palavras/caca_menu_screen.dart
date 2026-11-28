import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/grade_caca.dart';
import '../../services/progresso_repository.dart';
import 'caca_classica_screen.dart';

/// Menu do Caça-palavras (molde ContasMenuScreen): a criança escolhe o TEMA
/// das palavras (6 categorias, com o pool que já existe) e o NÍVEL
/// (fácil/médio/difícil) e toca em JOGAR.
///
/// Deitado (o caso real — o app trava paisagem): 2 colunas; esquerda = temas
/// (3 colunas x 2 fileiras, cartões baixos de 72px), direita = níveis lado a
/// lado (56px) + resumo da escolha + JOGAR grande. Retrato (defensivo, só em
/// teste): 1 coluna com temas 2x3. Cada coluna tem rolagem de segurança
/// (SingleChildScrollView): só rola se faltar altura (fonte ampliada ou
/// insets grandes); nenhum cartão fica cortado sem poder rolar.
class CacaMenuScreen extends StatefulWidget {
  const CacaMenuScreen({super.key});

  @override
  State<CacaMenuScreen> createState() => _CacaMenuScreenState();
}

class _CacaMenuScreenState extends State<CacaMenuScreen> {
  static const _temas = [
    Categoria.animais,
    Categoria.objetos,
    Categoria.alimentos,
    Categoria.nomes,
    Categoria.espaco,
    Categoria.futebol,
  ];

  Categoria _tema = Categoria.animais;
  Nivel _nivel = Nivel.facil;
  int _moedas = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final moedas = await ProgressoRepository.moedas();
    final xp = await ProgressoRepository.xp();
    if (mounted) {
      setState(() {
        _moedas = moedas;
        _xp = xp;
      });
    }
  }

  String get _resumo =>
      '${_tema.rotulo} · ${_nivel.rotulo} · ${palavrasParaCaca(_tema, _nivel).length} palavras';

  void _jogar() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => CacaClassicaScreen(
          titulo: 'Caça-palavras · ${_tema.rotulo} · ${_nivel.rotulo}',
          tema: _tema,
          nivel: _nivel,
        ),
      ),
    )
        .then((_) {
      if (mounted) {
        _carregar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'CAÇA-PALAVRAS',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '🪙 $_moedas · Nv ${ProgressoRepository.nivelDe(_xp)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final deitado = c.maxWidth > c.maxHeight;
                    if (deitado) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _colunaTemas(c.maxHeight)),
                          const SizedBox(width: 10),
                          Expanded(flex: 5, child: _colunaDireita(c.maxHeight)),
                        ],
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _rotulo('TEMA DAS PALAVRAS'),
                          const SizedBox(height: 4),
                          for (var r = 0; r < 3; r++)
                            Row(
                              children: [
                                for (var i = 0; i < 2; i++)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: SizedBox(
                                        height: 64,
                                        child: _TemaCard(
                                          key: Key(
                                              'caca-tema-${_temas[r * 2 + i].name}'),
                                          categoria: _temas[r * 2 + i],
                                          selecionado:
                                              _temas[r * 2 + i] == _tema,
                                          onTap: () => setState(() =>
                                              _tema = _temas[r * 2 + i]),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(height: 6),
                          _colunaDireita(double.infinity, rolar: false),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alturas calculadas da altura útil H (opção A da T007): cada coluna
  /// preenche o que cabe com botões grandes (até o teto) e o que sobrar
  /// fica embaixo — conteúdo sempre ANCORADO NO TOPO. Só centraliza quando
  /// a folga é grande (tablet com teto atingido); se faltar altura, rola.
  /// Retorna (fileiraTema, botaoNivel, jogar, alturaConteudo, centralizar).
  (double, double, double, double, bool) _alturas(double h) {
    var fileira = ((h - 26.0) / 2.0).clamp(56.0, 96.0);
    var nivel = (fileira * 0.85).clamp(52.0, 64.0);
    var jogar = fileira.clamp(52.0, 64.0);
    final esquerda = 18.0 + 4.0 + fileira * 2 + 4.0;
    final direita = 18.0 + 4.0 + nivel + 6.0 + 22.0 + 6.0 + jogar;
    final conteudo = esquerda > direita ? esquerda : direita;
    return (fileira, nivel, jogar, conteudo, h - conteudo > 150.0);
  }

  /// Coluna rolável: ancorada no topo; centraliza só com folga grande
  /// (tablet); rola se faltar altura (segurança).
  Widget _caixaRolavel(Widget child, {required bool centralizar}) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            mainAxisAlignment: centralizar
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [child],
          ),
        ),
      ),
    );
  }

  Widget _rotulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5),
    );
  }

  /// Coluna esquerda no deitado: 6 temas em 3 colunas x 2 fileiras.
  /// Fileiras crescem com H até o teto de 96px.
  Widget _colunaTemas(double h) {
    final (fileira, _, _, _, centralizar) = _alturas(h);
    return _caixaRolavel(
      centralizar: centralizar,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rotulo('TEMA DAS PALAVRAS'),
          const SizedBox(height: 4),
          for (var r = 0; r < 2; r++)
            Padding(
              padding: EdgeInsets.only(bottom: r == 0 ? 4 : 0),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          height: fileira,
                          child: _TemaCard(
                            key: Key(
                                'caca-tema-${_temas[r * 3 + i].name}'),
                            categoria: _temas[r * 3 + i],
                            selecionado:
                                _temas[r * 3 + i] == _tema,
                            onTap: () => setState(
                                () => _tema = _temas[r * 3 + i]),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Coluna direita no deitado (e bloco inferior no retrato): 3 níveis lado
  /// a lado + resumo da escolha + JOGAR grande.
  Widget _colunaDireita(double h, {bool rolar = true}) {
    final (_, nivel, jogar, _, centralizar) = _alturas(h);
    final corpo = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rotulo('NÍVEL'),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final n in Nivel.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    height: nivel,
                    child: _NivelCard(
                      key: Key('caca-nivel-${n.name}'),
                      nivel: n,
                      selecionado: n == _nivel,
                      onTap: () => setState(() => _nivel = n),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _resumo,
          key: const Key('caca-resumo'),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: jogar,
          child: FilledButton.icon(
            key: const Key('caca-jogar'),
            onPressed: _jogar,
            icon: const Icon(Icons.play_arrow_rounded, size: 26),
            label: const Text(
              'JOGAR',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
    if (!rolar) return corpo;
    return _caixaRolavel(corpo, centralizar: centralizar);
  }
}

/// Estilo ÚNICO de seleção (temas e níveis): selecionado = borda 3 + fundo
/// na cor; não-selecionado = fundo escuro + borda fina clara. Overlays do
/// InkWell neutralizados para nenhum cartão ficar com cinza fantasma.
class _TemaCard extends StatelessWidget {
  const _TemaCard(
      {super.key,
      required this.categoria,
      required this.selecionado,
      required this.onTap});

  final Categoria categoria;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionado
          ? categoria.cor.withValues(alpha: 0.35)
          : Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selecionado ? categoria.cor : Colors.white24,
              width: selecionado ? 3 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(categoria.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  categoria.rotulo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NivelCard extends StatelessWidget {
  const _NivelCard(
      {super.key,
      required this.nivel,
      required this.selecionado,
      required this.onTap});

  final Nivel nivel;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionado
          ? nivel.cor.withValues(alpha: 0.45)
          : Colors.white.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selecionado ? nivel.cor : Colors.white24,
              width: selecionado ? 3 : 1,
            ),
          ),
          child: Center(
            child: Text(
              nivel.rotulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
