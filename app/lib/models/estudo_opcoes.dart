import 'package:flutter/material.dart';

/// Cor de fundo da tela de estudo (bolinhas HORIZONTAIS ao lado do título).
/// `corLetra` = cor da palavra para contraste: **só o preto usa letra branca**;
/// os demais (branco/bege) usam letra preta (regra do usuário).
enum FundoTela {
  preto('Preto', Color(0xFF000000), Colors.white),
  branco('Branco', Color(0xFFFFFFFF), Colors.black),
  begeEscuro('Bege escuro', Color(0xFFC7B08A), Colors.black),
  begeClaro('Bege claro', Color(0xFFF4EAD5), Colors.black);

  const FundoTela(this.rotulo, this.cor, this.corLetra);

  final String rotulo;
  final Color cor;
  final Color corLetra;
}

/// Cor da CANETA para escrever na tela (bolinhas VERTICAIS abaixo do título).
/// A posição vertical diferencia das cores de fundo (horizontais).
enum CorCaneta {
  azul('Azul', Color(0xFF2F6BFF)),
  vermelho('Vermelho', Color(0xFFE23B3B)),
  amarelo('Amarelo', Color(0xFFF2C21A)),
  roxo('Roxo', Color(0xFF8A3FDB));

  const CorCaneta(this.rotulo, this.cor);

  final String rotulo;
  final Color cor;
}
