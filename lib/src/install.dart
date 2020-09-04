import 'package:dcli/dcli.dart';
import 'package:osx_kvm_installer/src/package_managers/package_manager.dart';
import 'installation_preparation.dart';

///Install OSX
void install(List<String> args) {
  PackageManager pm = PackageManager.detectPM();
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
  './OpenCore-Boot.sh'
      .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
  InstallationPreparation.libVirtManager();
}
