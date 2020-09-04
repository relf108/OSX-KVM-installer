import 'package:osx_kvm_installer/src/package_managers/package_manager.dart';
import 'package:dcli/dcli.dart';

class AptPackageManger extends PackageManager {
  @override
  void installDependencies() {
    try {
      'apt-get install python qemu uml-utilities virt-manager dmg2img git wget libguestfs-tools -y'
          .start(privileged: true);
    } on Exception catch (_) {
      rethrow;
    }
  }
}
