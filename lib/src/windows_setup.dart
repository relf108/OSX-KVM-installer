import 'package:dcli/dcli.dart';

class WindowsSetup {
  static bool detectWSL() {
    if ('uname -a'.firstLine.contains('Microsoft')) {
      echo(green('WSL DETECTED\n'));
      return true;
    }
    return false;
  }

  static void wslX11Setup() {
    if (!exists('$HOME\\OSX-KVM-installer\\vcxsrv-64.1.20.8.1.installer.exe')) {
      fetch(
          url:
              'https://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.20.9.0/vcxsrv-64.1.20.9.0.installer.exe?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fvcxsrv%2Ffiles%2Flatest%2Fdownload&ts=1611373071',
          saveToPath: '$HOME\\Downloads\\vcxsrv-64.1.20.8.1.installer.exe');
    }

    './vcxsrv-64.1.20.8.1.installer.exe'
        .start(workingDirectory: '$HOME\\Downloads', privileged: true);
    'wsl pub global activate osx_kvm_installer'.start(privileged: true);
  }
}
