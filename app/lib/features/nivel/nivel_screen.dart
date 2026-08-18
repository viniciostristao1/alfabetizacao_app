import 'package:flutter/material.dart';

import '../../models/categoria.dart';
import '../../services/banco_palavras.dart';
import '../../theme/app_colors.dart';
import '../estudo/estudo_screen.dart';

/// Segunda tela (retrato): escolher o nível dentro de uma categoria.
/// Ao tocar num nível, abre a EstudoScreen — que gira para paisagem.
class NivelScreen extends StatelessWidget {
  const NivelScreen({super.key, required this.categoria});

  final Categoria categoria;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${categoria.emoji}  ${categoria.rotulo}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Escolha o nível',
                style: TextStyle(fontSize: 16, color: AppColors.dim),
              ),
              const SizedBox(height: 14),
              for (final n in Nivel.values) ...[
                _NivelCard(categoria: categoria, nivel: n),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NivelCard extends StatelessWidget {
  const _NivelCard({required this.categoria, required this.nivel});

  final Categoria categoria;
  final Nivel nivel;

  @override
  Widget build(BuildContext context) {
    final total = contarPalavras(categoria, nivel);
    final habilitado = total > 0;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: habilitado
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EstudoScreen(
                      titulo:
                          '${categoria.emoji}  ${categoria.rotulo} · ${nivel.rotulo}',
                      palavras: palavrasDe(categoria, nivel),
                    ),
                  ),
                )
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: habilitado ? nivel.cor : AppColors.dim2,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nivel.rotulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nivel.descricao,
                    style: const TextStyle(color: AppColors.dim),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '$total ${total == 1 ? 'palavra' : 'palavras'}',
                style: const TextStyle(color: AppColors.dim, fontSize: 14),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.dim),
            ],
          ),
        ),
      ),
    );
  }
}
