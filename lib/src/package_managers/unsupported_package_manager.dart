import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:osx_kvm_installer/src/package_managers/package_manager.dart';

class UnsupportedPackageManager extends PackageManager {
  @override
  void installDependencies() {
    echo(red('Either the skip depencies flag was used or we can\'t find apt or pacman package manager.'
        ' you\'ll need to install the dependencies '
        '[python qemu uml-utilities virt-manager dmg2img git wget libguestfs-tools] yourself\n'));
    var selfInsalled = ask(
        'If you\'ve already insatlled the dependencies press [y(Y)] to continue. Press any button to stop');
    if (selfInsalled.toLowerCase() != 'y') {
      echo(green('User will install depenendencies\n'));
      exit(1);
    }
  }
}
