import 'package:flutter/material.dart';

import '../../models/conta.dart';
import '../../theme/app_colors.dart';

/// Acima desta quantidade de bolinhas a faixa embaixo da conta fica pequena
/// demais; nesse caso a tela abre a janela central (`mostrarBolinhasDialogo`).
const int kMaxBolinhasInline = 40;

/// Os dois tons da multiplicação/divisão em fileiras: o **escuro** marca os
/// grupos (1ª bolinha de cada fileira = conta os grupos), o **claro** completa
/// cada fileira (fileira inteira = tamanho do grupo). Posição redundante com a
/// cor (legível p/ daltônicos e em cinza). Consts locais sob a exceção
/// documentada em `NOVA_CONTA.md` §3 (nada muda no `AppColors`).
const Color kGrupoEscuro = Color(0xFF1C7A44);
const Color kGrupoClaro = Color(0xFF62E68C);

/// Diâmetro adaptativo p/ fileiras: cabem `fileiras` linhas em `alturaMax` e
/// `colunas` bolinhas em `larguraMax` (piso 8px — pontinho ainda legível).
/// Mantém a regra dos 40 intacta: só o tamanho adapta, o gatilho não muda.
int diametroFileiras({
  required int fileiras,
  required int colunas,
  required double larguraMax,
  double? alturaMax,
  int base = 22,
}) {
  var d = base;
  final porLargura = (larguraMax / (1.3 * colunas - 0.3)).floor();
  if (porLargura < d) d = porLargura;
  if (alturaMax != null) {
    final porAltura = (alturaMax / (1.3 * fileiras - 0.3)).floor();
    if (porAltura < d) d = porAltura;
  }
  return d < 8 ? 8 : d;
}

/// Quantas bolinhas a conta vai mostrar (soma = a + b; subtração = a;
/// multiplicação = a × b, em fileiras; divisão = a, repartido em fileiras).
int totalBolinhas(Conta conta) {
  if (conta.vezes) return conta.a * conta.b;
  if (conta.divisao) return conta.a;
  return conta.soma ? conta.a + conta.b : conta.a;
}

/// Uma bolinha de contagem: **verde** = fica, **vermelha** = sai na subtração.
/// A borda usa a cor do texto atual (`contraste`) para a bolinha aparecer tanto
/// no fundo preto quanto nos beges.
class BolinhaContagem extends StatelessWidget {
  const BolinhaContagem({
    super.key,
    required this.cor,
    required this.contraste,
    this.diametro = 22,
  });

  final Color cor;
  final Color contraste;
  final double diametro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        color: cor,
        shape: BoxShape.circle,
        border: Border.all(color: contraste.withValues(alpha: 0.35)),
      ),
    );
  }
}

/// As bolinhas de UMA conta, para a criança contar com o dedo:
///  - **Soma:** `a` bolinhas verdes, o sinal `+`, `b` bolinhas verdes.
///  - **Subtração:** `a` bolinhas; as **`b` últimas ficam vermelhas** (o que
///    sai) e as demais verdes (o que fica = resultado).
///  - **Multiplicação:** `a` fileiras de `b` bolinhas; a **1ª de cada fileira
///    é escura** (conta os grupos = `a`), o resto é claro (fileira = `b`).
///    Ex.: 3×4 = 3 fileiras de (1 escura + 3 claras).
///  - **Divisão:** mesma linguagem — `b` fileiras de `a÷b` (reparte o
///    dividendo em grupos do tamanho do divisor). Ex.: 12÷3 = 3 fileiras de 4.
///  - Fileiras cabem pela largura (`diametroFileiras`); contas grandes caem
///    na janela central com scroll.
class BolinhasConta extends StatelessWidget {
  const BolinhasConta({
    super.key,
    required this.conta,
    required this.contraste,
    this.diametro = 22,
  });

  final Conta conta;
  final Color contraste;
  final double diametro;

  List<Widget> _grupo(int quantidade, Color cor) => [
        for (var i = 0; i < quantidade; i++)
          BolinhaContagem(cor: cor, contraste: contraste, diametro: diametro),
      ];

  @override
  Widget build(BuildContext context) {
    final espaco = diametro * 0.3;
    final verdes = conta.soma ? 0 : conta.a - conta.b;
    if (conta.vezes || conta.divisao) {
      // Fileiras = grupos: mult `a` fileiras de `b`; divisão `b` fileiras
      // de `a÷b`. A líder escura de cada fileira conta os grupos.
      final fileiras = conta.vezes ? conta.a : conta.b;
      final colunas = conta.vezes ? conta.b : conta.a ~/ conta.b;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < fileiras; i++) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BolinhaContagem(
                    cor: kGrupoEscuro,
                    contraste: contraste,
                    diametro: diametro),
                for (var j = 1; j < colunas; j++)
                  Padding(
                    padding: EdgeInsets.only(left: espaco),
                    child: BolinhaContagem(
                        cor: kGrupoClaro,
                        contraste: contraste,
                        diametro: diametro),
                  ),
              ],
            ),
            if (i < fileiras - 1) SizedBox(height: espaco),
          ],
        ],
      );
    }
    return Wrap(
      spacing: espaco,
      runSpacing: espaco,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (conta.soma) ...[
          ..._grupo(conta.a, AppColors.acerto),
          Text(
            conta.sinal,
            style: TextStyle(
              fontSize: diametro,
              fontWeight: FontWeight.w900,
              color: contraste,
            ),
          ),
          ..._grupo(conta.b, AppColors.acerto),
        ] else ...[
          ..._grupo(verdes, AppColors.acerto),
          ..._grupo(conta.b, AppColors.danger),
        ],
      ],
    );
  }
}

/// Janela central com as bolinhas (para contas com muitas bolinhas, que não
/// cabem na faixa embaixo da conta). Fecha no X ou no botão "Fechar".
Future<void> mostrarBolinhasDialogo(
  BuildContext context,
  Conta conta,
  Color contraste,
) {
  return showDialog<void>(
    context: context,
    builder: (_) => _BolinhasDialogo(conta: conta, contraste: contraste),
  );
}

class _BolinhasDialogo extends StatelessWidget {
  const _BolinhasDialogo({required this.conta, required this.contraste});

  final Conta conta;
  final Color contraste;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${conta.enunciado} = ${conta.resultado}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Fechar',
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.dim, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Flexible(
                child: SingleChildScrollView(
                  child: Center(
                    child: BolinhasConta(
                      conta: conta,
                      contraste: AppColors.text,
                      diametro: (conta.vezes || conta.divisao)
                          ? diametroFileiras(
                              fileiras:
                                  conta.vezes ? conta.a : conta.b,
                              colunas: conta.vezes
                                  ? conta.b
                                  : conta.a ~/ conta.b,
                              larguraMax: 700,
                              base: 28,
                            ).toDouble()
                          : 34,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
