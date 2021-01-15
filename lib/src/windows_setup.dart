import 'package:dcli/dcli.dart';

class WindowsSetup {
  static bool detectWSL() {
    var result = read('/proc/version');
    result.forEach((line) {
      if (line.contains('Microsoft')) {
        echo(green('WSL DETECTED\n'));
        return true;
      }
    });
    return false;
  }

  static void wslX11Setup() {
    fetch(
        url:
            'https://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.20.8.1/vcxsrv-64.1.20.8.1.installer.exe?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fvcxsrv%2Ffiles%2Flatest%2Fdownload&ts=1601204263',
        saveToPath: '$HOME/OSX-KVM-installer/vcxsrv-installer.exe');

    'vcxsrv-installer.exe /quiet'
        .start(workingDirectory: '$HOME/OSX-KVM-installer');

    'export DISPLAY="`grep nameserver /etc/resolv.conf | sed \'s/nameserver //\'`:0\" >> .bashrc'
        .start(workingDirectory: '$HOME', privileged: true);
  }
}
