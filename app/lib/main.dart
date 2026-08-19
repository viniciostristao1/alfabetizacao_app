import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/home/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // O app TODO vive em PAISAGEM (deitado) e em TELA CHEIA (imersivo) — todas as
  // telas escondem a barra de status/navegação do sistema (clima de jogo).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ProviderScope(child: AppPrimeirasPalavras()));
}

class AppPrimeirasPalavras extends StatelessWidget {
  const AppPrimeirasPalavras({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo do Davi',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
