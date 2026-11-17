import 'package:flutter/material.dart';

/// Quiz das posições (jogo do Davi): a lousa tática do vestiário
/// (`assets/futebol/futebol_campo.png`, 1536×1024) já desenha o time com
/// pontinhos azuis — cada [FutebolPin] é um desses pontos, em fração da
/// imagem (0..1), para o alvo acompanhar qualquer tamanho de tela.
///
/// O app pergunta "ONDE FICA O GOLEIRO?" e a criança TOCA o ponto certo.
/// A palavra perguntada é sempre o texto do banco ([palavra]); [rotuloLousa]
/// documenta como a lousa escreve (ex.: a lousa diz "MEI", o banco diz
/// "meia" — a posição de meio-campista).
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
const List<FutebolPin> kPinosCampo = [
  FutebolPin('atacante', 0.654, 0.122, 'ATACANTE'),
  FutebolPin('meia', 0.509, 0.227, 'MEI'),
  FutebolPin('meia', 0.782, 0.250, 'MEI'),
  FutebolPin('volante', 0.635, 0.311, 'VOLANTE'),
  FutebolPin('lateral', 0.503, 0.367, 'LATERAL ESQUERDO'),
  FutebolPin('lateral', 0.789, 0.377, 'LATERAL DIREITO'),
  FutebolPin('zagueiro', 0.596, 0.450, 'ZAGUEIRO'),
  FutebolPin('zagueiro', 0.699, 0.450, 'ZAGUEIRO'),
  FutebolPin('goleiro', 0.658, 0.563, 'GOLEIRO'),
];

/// Pins de uma posição (ex.: 'zagueiro' → os 2 da linha de trás).
List<FutebolPin> pinosDe(String palavra) =>
    kPinosCampo.where((p) => p.palavra == palavra).toList();

/// Aspecto nativo da foto do campo (1536×1024) — mesmo 3:2 das fotos de Temas.
const double kFutebolCampoAspect = 1536 / 1024;

/// Cor do ponto (igual ao azul da lousa).
const Color kCorPinoCampo = Color(0xFF2E7DE1);
