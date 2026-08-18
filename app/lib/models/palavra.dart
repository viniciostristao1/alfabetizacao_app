import 'categoria.dart';

/// Uma palavra do banco.
///
/// Guardamos as **sílabas** (não só o texto) de propósito: o nível (2/3/4…) sai
/// direto de [nivelSilabas], e o futuro "modo sílabas coloridas" já tem os dados
/// prontos. A tela mostra [texto].
///
/// [sub] = subcategoria genérica (opcional), já pré-preenchida (ver IDEIAS.md):
///  - animais:  'aquatico' | 'terrestre' | 'voador'
///  - nomes:    'menino'   | 'menina'
///  - objetos:  'casa'     | 'rua'
///
/// [habitat] = habitat do jogo de ANIMAIS (mapa de habitats): 'artico' |
/// 'savana' | 'selva' | 'aquatico' | 'aves'. Só os animais do jogo têm.
///
/// [textoOverride] permite palavras com **espaço/hífen** (ex.: "urso polar",
/// "beija-flor") — nesses casos `silabas` ainda conta as sílabas p/ ordenar por
/// dificuldade, mas o que se mostra é o [textoOverride].
class Palavra {
  const Palavra(
    this.silabas,
    this.categoria, {
    this.sub,
    this.habitat,
    String? texto,
  }) : textoOverride = texto;

  /// Sílabas na ordem (ex.: ['ca','va','lo']). Minúsculas; nomes próprios com
  /// inicial maiúscula (ex.: ['Da','vi']).
  final List<String> silabas;
  final Categoria categoria;
  final String? sub;
  final String? habitat;
  final String? textoOverride;

  /// A palavra inteira exibida (ex.: 'cavalo', 'urso polar', 'beija-flor').
  String get texto => textoOverride ?? silabas.join();

  /// Número de sílabas = a dificuldade da palavra (usado para ordenar).
  int get nivelSilabas => silabas.length;
}
