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
    if (!exists('$HOME\\..\\..\\Downloads\\vcxsrv-64.1.20.9.0.installer.exe')) {
      fetch(
          url:
              'https://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.20.9.0/vcxsrv-64.1.20.9.0.installer.exe?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fvcxsrv%2Ffiles%2Flatest%2Fdownload&ts=1611373071',
          saveToPath:
              '$HOME\\..\\..\\Downloads\\vcxsrv-64.1.20.9.0.installer.exe');
    }

    '.\\Downloads\\vcxsrv-64.1.20.9.0.installer.exe'
        .start(workingDirectory: '$HOME\\..\\..', privileged: true);

    'wsl --export DISPLAY="`grep nameserver /etc/resolv.conf | sed \'s/nameserver //\'`:0\" >> .bashrc'
        .start(workingDirectory: '$HOME', privileged: false);
    'wsl --export DISPLAY="`grep nameserver /etc/resolv.conf | sed \'s/nameserver //\'`:0\" >> .zshrc'
        .start(workingDirectory: '$HOME', privileged: false);
    try {
      //Older versions of dart have pub on the path directly
      'wsl dart pub global activate osx_kvm_installer'
          .start(workingDirectory: '$HOME', privileged: true);
    } on Exception catch (_) {
      'wsl pub global activate osx_kvm_installer'
          .start(workingDirectory: '$HOME', privileged: true);
    }
    'wsl osx_kvm_installer'.start(workingDirectory: '$HOME', privileged: true);
  }
}
