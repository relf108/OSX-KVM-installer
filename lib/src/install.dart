import 'package:dcli/dcli.dart';
import 'package:osx_kvm_installer/src/package_managers/package_manager.dart';
import 'installation_preparation.dart';

///Install OSX
void install(List<String> args) {
  //InstallationPreparation.installDependencies();
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
  InstallationPreparation.createHDD(sizeGB: 64);
  InstallationPreparation.setupQuickNetworking();
  './OpenCore-Boot.sh'.start(
      privileged: true, workingDirectory: '$HOME/OSX-KVM', detached: true);
  InstallationPreparation.libVirtManager();
}
