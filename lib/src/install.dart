import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:osx_kvm_installer/src/package_managers/package_manager.dart';
import 'package:osx_kvm_installer/src/windows_setup.dart';
import 'installation_preparation.dart';

///Install OSX
void install(List<String> args) {
  //if flag -s is passed in skip dep install
  var flag = '';
  var name;
  var size;
  var version;
  if (args.isNotEmpty) {
    flag = args[0].toString();
  }
  if (flag == '-g') {
    name = args[1];
    size = args[2];
    version = args[3];
  }

  if (flag != '-g') {
    if (!exists('$HOME/OSX-KVM-installer')) {
      createDir('$HOME/OSX-KVM-installer');
    }
  } else {
    createDir('$HOME/OSX-KVM-installer-$name');
  }

  if (Platform.isWindows) {
    WindowsSetup.wslX11Setup();
    exit(0);
  }

  if (WindowsSetup.detectWSL()) {
    //This commands working directory may need to be hard coded as $HOME could pick up the windows %HOME
    'echo \'export DISPLAY="`grep nameserver /etc/resolv.conf | sed \'s/nameserver //\'`:0\"\' >> .bashrc'
        .start(workingDirectory: '$HOME');
    'echo \'export DISPLAY="`grep nameserver /etc/resolv.conf | sed \'s/nameserver //\'`:0\"\' >> .zshrc'
        .start(workingDirectory: '$HOME');
  }
  ///Install dependencies
  var pm = PackageManager.detectPM(flag);
  pm.installDependencies();
  echo(green('Dependencies installed\n'));

  ///Setup osx image
  InstallationPreparation.cloneOSXKVM(name: name);
  InstallationPreparation.fetchInstaller(version: version, name: name);
  InstallationPreparation.convertToIMG(name: name);

  ///Create virtual hdd
  if (flag != '-g') {
    size = ask('Enter size of install in GB (default 64)',
        defaultValue: '64', validator: Ask.integer);
    while (!checkSize(size)) {
      size =
          ask('Enter size of install in GB (default 64)', defaultValue: '64');
    }
  }
  InstallationPreparation.createHDD(sizeGB: int.tryParse(size), name: name);
  echo(green('Virtual hard drive setup\n'));

  ///Setup high speed networking using tap
  InstallationPreparation.setupQuickNetworking(0, name: name);
  echo(green('Networking setup complete\n'));

  ///Start vm to run install wizard
  echo(orange(
      'STARTING OSX. DO NOT TURN OFF THE VM OR CLOSE THIS TERMINAL UNTIL INSTALL IS FINISHED \n'
      'GO TO https://github.com/relf108/OSX-KVM-installer#post-installation FOR GRAPHICAL INSTALL STEPS\n'));
  echo(green(flag));
  if (flag == '-g') {
    echo('starting open core boot in $HOME/OSX-KVM-installer-$name/OSX-KVM');
    './OpenCore-Boot.sh'.start(
        privileged: true,
        workingDirectory: '$HOME/OSX-KVM-installer-$name/OSX-KVM');
  } else {
    './OpenCore-Boot.sh'.start(
        privileged: true, workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
  }

  ///Install runner
  InstallationPreparation.setupEXE(name: name);
  echo(green(
      'Setup complete. \n If you like this software please consider staring this project or donating'));
}
