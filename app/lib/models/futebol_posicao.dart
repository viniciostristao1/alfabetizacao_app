import 'package:flutter/material.dart';

/// Quiz das posições (jogo do Davi): a lousa tática do vestiário
/// (`assets/futebol/futebol_campo.png`, 1774×887, arte larga 2:1) já desenha
/// o time com pontinhos azuis — cada [FutebolPin] é um desses pontos, em
/// fração da imagem (0..1), para o alvo acompanhar qualquer tamanho de tela.
///
/// A arte larga foi gerada por fora e o quadro mantido no centro-direita; as
/// frações abaixo foram REMEDIDAS por script (centroide dos pixels azuis) na
/// arte nova e conferidas numa imagem de debug — cada centroide cai no ponto.
///
/// O app pergunta "ONDE FICA O GOLEIRO?" e a criança TOCA o ponto certo.
/// A palavra perguntada é sempre o texto do banco ([palavra]); [rotuloLousa]
/// documenta como a lousa escreve (a lousa nova já diz "MEIA").
class FutebolPin {
  const FutebolPin(this.palavra, this.fx, this.fy, this.rotuloLousa);

  /// Texto no banco de palavras (o que o app mostra e fala).
  final String palavra;

  /// Posição do ponto azul na imagem (fração 0..1).
  final double fx;
  final double fy;

  /// Como a lousa rotula este ponto (só documentação).
  final String rotuloLousa;
}

/// Ordem pedagógica do quiz: de trás pra frente (defesa → ataque).
const List<String> kOrdemPosicoes = [
  'goleiro',
  'zagueiro',
  'lateral',
  'volante',
  'meia',
  'atacante',
];

/// Os 9 pontos azuis da lousa (algumas posições têm 2: zagueiro, lateral, meia).
/// Coordenadas MEDIDAS por script na arte larga 1774×887 (centroide dos
/// pixels azuis, conferidas na imagem de debug).
const List<FutebolPin> kPinosCampo = [
  FutebolPin('atacante', 0.686, 0.190, 'ATACANTE'),
  FutebolPin('meia', 0.585, 0.282, 'MEIA'),
  FutebolPin('meia', 0.787, 0.285, 'MEIA'),
  FutebolPin('volante', 0.686, 0.372, 'VOLANTE'),
  FutebolPin('lateral', 0.556, 0.437, 'LATERAL ESQUERDO'),
  FutebolPin('lateral', 0.814, 0.441, 'LATERAL DIREITO'),
  FutebolPin('zagueiro', 0.637, 0.522, 'ZAGUEIRO'),
  FutebolPin('zagueiro', 0.737, 0.523, 'ZAGUEIRO'),
  FutebolPin('goleiro', 0.685, 0.654, 'GOLEIRO'),
];

/// Pins de uma posição (ex.: 'zagueiro' → os 2 da linha de trás).
List<FutebolPin> pinosDe(String palavra) =>
    kPinosCampo.where((p) => p.palavra == palavra).toList();

/// Aspecto nativo da arte larga do campo (1774×887 = 2:1). A tela preenche a
/// largura com ela e corta SÓ o excedente vertical, ancorado no centro dos
/// pontos (fy 0.425) — o quadro (fy ~0,09–0,76) nunca entra no corte.
const double kFutebolCampoAspect = 1774 / 887;

/// Centro vertical dos 9 pontos (âncora da janela de corte).
const double kFyCentroPontos = 0.425;

/// Cor do ponto (igual ao azul da lousa).
const Color kCorPinoCampo = Color(0xFF2E7DE1);
