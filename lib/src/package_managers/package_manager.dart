import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:osx_kvm_installer/src/package_managers/apt_package_manager.dart';
import 'package:osx_kvm_installer/src/package_managers/pacman_package_manager.dart';
import 'package:osx_kvm_installer/src/package_managers/unsupported_package_manager.dart';

abstract class PackageManager {
  ///overidden of a supported package manager is detected.
  void installDependencies();

  ///Checks if pacman or apt are available on users system.
  static PackageManager detectPM() {
    var apt = which('apt');
    var pacman = which('pacman');
    if (apt != null) {
      PackageManager apt = AptPackageManger();
      return apt;
    } else if (pacman != null) {
      PackageManager pacman = PacmanPackageManager();
      return pacman;
    } else {
      PackageManager unsupported = UnsupportedPackageManager();
      return unsupported;
    }
  }
}
