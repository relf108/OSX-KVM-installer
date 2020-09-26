import 'dart:io';

import 'package_manager.dart';
import 'package:dcli/dcli.dart';

class PacmanPackageManager extends PackageManager {
  @override
  void installDependencies() {
    var aur = ask(
        'Pacman detected, if you do not have AUR packages enabled the installer will now do so. '
        'Press any button to continue or [n(N)] to stop');
    if (aur.toLowerCase() != 'n') {
      try {
        'pacman -Sy --noconfirm --needed base-devel'.start(privileged: true);
        'pacman -Sy --noconfirm python qemu virt-manager dmg2img git wget libguestfs -y'
            .start(privileged: true);
        'pacman -Syu --noconfirm pamac-gtk'.start(privileged: true);
        'pamac build uml_utilities'.start();
      } on Exception catch (_) {
        rethrow;
      }
    } else {
      echo('Dissallowed, exiting installer');
      exit(1);
    }
  }
}
