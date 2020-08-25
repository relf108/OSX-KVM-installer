#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';
import './installationPreparation.dart';

void main(List<String> args) {
  InstallationPreparation.installDependencies();
  InstallationPreparation.cloneOSXKVM();
  InstallationPreparation.fetchInstaller();
  InstallationPreparation.convertToIMG();
  ///change vm size here, must be at least 30
  InstallationPreparation.createHDD(sizeGB: 32);
  InstallationPreparation.setupQuickNetworking();
  './OpenCore-Boot.sh'.start(privileged: true ,workingDirectory: '$HOME/OSX-KVM');
}
