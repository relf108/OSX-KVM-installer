import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:test/test.dart';
import 'package:osx_kvm_installer/src/installation_preparation.dart';

void main() {
  test('fetch edit test', () {
    var name = 'test';
    var fetcher =
        File('$HOME/OSX-KVM-installer-$name/OSX-KVM/fetch-macOS-v2.py');
    InstallationPreparation.editFetcher(fetcher);
  });

  test('setup quick networking', () {
    InstallationPreparation.setupQuickNetworking(0, name: 'test');
  });
}
