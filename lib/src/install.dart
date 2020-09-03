import 'package:dcli/dcli.dart';

import 'installationPreparation.dart';

///Install OSX
void install(List<String> args) {
  InstallationPreparation.installDependencies();
  InstallationPreparation.cloneOSXKVM();
  InstallationPreparation.fetchInstaller();
  InstallationPreparation.convertToIMG();
  var size = ask('Enter size of install in GB (default 64)',
      defaultValue: '64', validator: Ask.integer);
  while (!checkSize(size)) {
    size = ask('Enter size of install in GB (default 64)', defaultValue: '64');
  }
  InstallationPreparation.createHDD(sizeGB: 64);
  InstallationPreparation.setupQuickNetworking();
  './OpenCore-Boot.sh'
      .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
  InstallationPreparation.libVirtManager();
}
