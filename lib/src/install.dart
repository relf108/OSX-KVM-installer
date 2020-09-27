import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:osx_kvm_installer/src/package_managers/package_manager.dart';
import 'installation_preparation.dart';

///Install OSX
void install(List<String> args) {
  if (!exists('$HOME/OSX-KVM-installer')) {
    createDir('$HOME/OSX-KVM-installer');
  }

  if (InstallationPreparation.detectWSL()) {
    // echo('WSL detected make sure you have VcXsrv Windows X Server installed. \n'
    //     'If you do not, follow this guide to do so https://techcommunity.microsoft.com/t5/windows-dev-appconsult/running-wsl-gui-apps-on-windows-10/ba-p/1493242');
    // var installedVcXsrv = ask('If it is already installed press [y(Y)]');
    // if (installedVcXsrv.toLowerCase() != 'y') {
    //   echo('VcXsrv not installed, exiting');
    //   exit(1);
    // }
    InstallationPreparation.wslX11Setup();
  }

  //if flag -s is passed in skip dep install
  var flag = '';
  if (!args.isEmpty) {
    flag = args[0].toString();
  }
  var pm = PackageManager.detectPM(flag);
  pm.installDependencies();
  InstallationPreparation.cloneOSXKVM();
  InstallationPreparation.fetchInstaller();
  InstallationPreparation.convertToIMG();
  var size = ask('Enter size of install in GB (default 64)',
      defaultValue: '64', validator: Ask.integer);
  while (!checkSize(size)) {
    size = ask('Enter size of install in GB (default 64)', defaultValue: '64');
  }
  InstallationPreparation.createHDD(sizeGB: int.tryParse(size));
  InstallationPreparation.setupQuickNetworking();
  echo('STARTING OSX. DO NOT TURN OFF THE VM UNTIL INSTALL IS FINISHED \n'
      'GO TO https://github.com/relf108/OSX-KVM-installer#post-installation FOR GRAPHICAL INSTALL STEPS\n');
  './OpenCore-Boot.sh'.start(
      privileged: true, workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
  InstallationPreparation.libVirtManager();
  InstallationPreparation.setupEXE();
}
