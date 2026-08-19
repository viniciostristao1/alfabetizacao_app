import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/home/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // O app TODO vive em PAISAGEM (deitado) — todas as telas.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ProviderScope(child: AppPrimeirasPalavras()));
}

class AppPrimeirasPalavras extends StatelessWidget {
  const AppPrimeirasPalavras({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Primeiras Palavras',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
