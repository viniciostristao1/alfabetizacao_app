import 'package:flutter/material.dart';

/// Tela de TEMAS: abre a foto `assets/objetos/objetos_temas_foto.png` em tela
/// cheia (com zoom/pano) — o ponto de partida do modo por tema (o que a foto
/// vira será definido depois).
class TemasScreen extends StatelessWidget {
  const TemasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Temas'),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Center(
            child: Image.asset(
              'assets/objetos/objetos_temas_foto.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) => const Center(
                child: Text(
                  'Imagem indisponível',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
