import 'dart:io';

import 'package:alfabetizacao/util/versao.dart';
import 'package:flutter_test/flutter_test.dart';

/// Trava de sincronia (ver `AGENTS.md` §4): o `versionName` do
/// `app/pubspec.yaml` (`X.Y.Z+N`) tem de ser igual ao `kVersao` da home.
void main() {
  test('pubspec versionName == kVersao (e versionCode > 0)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
            multiLine: true)
        .firstMatch(pubspec);
    expect(m, isNotNull, reason: 'version: X.Y.Z+N não encontrado no pubspec');
    expect(m!.group(1), kVersao);
    expect(int.parse(m.group(2)!), greaterThan(0));
  });
}
