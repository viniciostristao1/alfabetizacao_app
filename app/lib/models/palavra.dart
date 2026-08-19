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
/// 'savana' | 'selva' | 'aquatico' | 'aves' | 'fazenda'. Só os animais do jogo
/// têm (alguns animais só de região podem ter habitat nulo).
///
/// [regiao] = **onde o animal vive no planeta** (mapa-múndi por continente):
/// 'norte' | 'sul' | 'africa' | 'asia' | 'australia' | 'artico' | 'oceano' |
/// 'ceu'. É uma classificação GEOGRÁFICA, independente do [habitat] (ex.: o tigre
/// tem habitat 'selva' mas região 'asia'). Ver [Regiao] e o mapa-múndi.
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
    this.regiao,
    String? texto,
  }) : textoOverride = texto;

  /// Sílabas na ordem (ex.: ['ca','va','lo']). Minúsculas; nomes próprios com
  /// inicial maiúscula (ex.: ['Da','vi']).
  final List<String> silabas;
  final Categoria categoria;
  final String? sub;
  final String? habitat;
  final String? regiao;
  final String? textoOverride;

  /// A palavra inteira exibida (ex.: 'cavalo', 'urso polar', 'beija-flor').
  String get texto => textoOverride ?? silabas.join();

  /// Número de sílabas = a dificuldade da palavra (usado para ordenar).
  int get nivelSilabas => silabas.length;
}
