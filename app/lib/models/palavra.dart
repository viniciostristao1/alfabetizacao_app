import 'categoria.dart';

/// Uma palavra do banco.
///
/// Guardamos as **sílabas** (não só o texto) de propósito: o nível (2/3/4) sai
/// direto de [nivelSilabas], e o futuro "modo sílabas coloridas" já tem os dados
/// prontos — sem reescrever o banco. Hoje a tela mostra só [texto].
///
/// [sub] é a subcategoria futura (opcional), já pré-preenchida para não dar
/// retrabalho quando as telas de subcategoria entrarem (ver IDEIAS.md):
///  - animais:  'aquatico' | 'terrestre' | 'voador'
///  - nomes:    'menino'   | 'menina'
///  - objetos:  'casa'     | 'rua'
class Palavra {
  const Palavra(this.silabas, this.categoria, {this.sub});

  /// Sílabas na ordem (ex.: ['ca','va','lo']). Minúsculas; nomes próprios com
  /// inicial maiúscula (ex.: ['Da','vi']).
  final List<String> silabas;
  final Categoria categoria;
  final String? sub;

  /// A palavra inteira (ex.: 'cavalo'). É o que a EstudoScreen exibe.
  String get texto => silabas.join();

  /// Número de sílabas = o nível da palavra.
  int get nivelSilabas => silabas.length;
}
