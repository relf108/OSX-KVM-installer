import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:osx_kvm_installer/src/package_managers/package_manager.dart';

class UnsupportedPackageManager extends PackageManager {
  @override
  void installDependencies() {
    echo(
        'Can\'t find apt or pacman package manager. you\'ll need to install the dependencies '
        '[python qemu uml-utilities virt-manager dmg2img git wget libguestfs-tools] yourself');
    var selfInsalled = ask(
        'If you\'ve already insatlled the dependencies press [y(Y)] to continue. Press any button to stop');
    if (selfInsalled.toLowerCase() != 'y') {
      echo('User will install depenendencies');
      exit(1);
    }
  }
}
