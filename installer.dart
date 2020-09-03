#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';
import './installationPreparation.dart';

void main(List<String> args) {
  InstallationPreparation.installDependencies();
  InstallationPreparation.cloneOSXKVM();
  InstallationPreparation.fetchInstaller();
  InstallationPreparation.convertToIMG();
  var size =
      ask('Enter size of install in GB (default 64)', defaultValue: '64');
  while (!checkSize(size)) {
    size = ask('Enter size of install in GB (default 64)', defaultValue: '64');
  }
  InstallationPreparation.createHDD(sizeGB: 64);
  InstallationPreparation.setupQuickNetworking();
  './OpenCore-Boot.sh'
      .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
  InstallationPreparation.libVirtManager();
}

bool checkSize(String size) {
  if (size as int < 30) {
    echo('Size must be at least 30GB');
    return false;
  }
  return true;
}
