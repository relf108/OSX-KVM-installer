#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';

class InstallationPreparation {
  ///
  static void cloneOSXKVM({String name}) async {
    if (name == null) {
      if (exists('$HOME/OSX-KVM-installer/OSX-KVM')) {
        var allowed = ask(
            orange('OSX-KVM found, re-clone to ensure latest version?'
                ' \n [y(Y)/n(N)]'),
            defaultValue: 'n',
            validator: Ask.alpha);
        if (allowed.toLowerCase() == 'y') {
          'rm -rf OSX-KVM-installer/OSX-KVM'
              .start(privileged: true, workingDirectory: '$HOME');
          try {
            'git clone https://github.com/kholia/OSX-KVM.git'
                .start(workingDirectory: '$HOME/OSX-KVM-installer');
          } on Exception catch (_) {
            rethrow;
          }
        } else {
          echo(green('Continuing with local version\n'));
        }
      } else {
        try {
          'git clone https://github.com/kholia/OSX-KVM.git'
              .start(workingDirectory: '$HOME/OSX-KVM-installer');
        } on Exception catch (_) {
          rethrow;
        }
      }
    } else {
      'git clone https://github.com/kholia/OSX-KVM.git'
          .start(workingDirectory: '$HOME/OSX-KVM-installer-$name');
      var fetcher =
          File('$HOME/OSX-KVM-installer-$name/OSX-KVM/fetch-macOS-v2.py');
      //await editFetcher(fetcher);
    }
  }

  static Future editFetcher(File fetcher) async {
    var lines = await fetcher.readAsLines();
    var debugLine;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].toString().contains('debug = False')) {
        debugLine = i;
      }
    }
    lines[debugLine] = '    debug = True\n';
    for (var line in lines) {
      fetcher.writeAsString(line, mode: FileMode.append);
    }
  }

  ///
  static void fetchInstaller({String version, String name}) {
    var command;
    var directory;
    if (version == null || name == null) {
      command = './fetch-macOS-v2.py';
      directory = '$HOME/OSX-KVM-installer/OSX-KVM';
    } else {
      command = './fetch-macOS-v2.py --action download -os "$version"';
      directory = '$HOME/OSX-KVM-installer-$name/OSX-KVM';
    }
    try {
      echo(
          orange('Heads up, the installer has not been tested with Big Sur\n'));
      start(command,
          privileged: true, workingDirectory: directory, terminal: true);
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void convertToIMG({String name}) {
    var directory;
    if (name == null) {
      directory = '$HOME/OSX-KVM-installer/OSX-KVM';
    } else {
      directory = '$HOME/OSX-KVM-installer-$name/OSX-KVM';
    }
    try {
      'dmg2img BaseSystem.dmg BaseSystem.img'
          .start(privileged: true, workingDirectory: directory);
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void createHDD({@required int sizeGB, String name}) {
    var directory;
    if (name == null) {
      directory = '$HOME/OSX-KVM-installer/OSX-KVM';
    } else {
      directory = '$HOME/OSX-KVM-installer-$name/OSX-KVM';
    }
    try {
      'qemu-img create -f qcow2 mac_hdd_ng.img ${sizeGB.toString()}G'
          .start(privileged: true, workingDirectory: directory);
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static Future<void> setupQuickNetworking(int retries, {String name}) async {
    var directory;
    if (name == null) {
      directory = '$HOME/OSX-KVM-installer/OSX-KVM';
    } else {
      directory = '$HOME/OSX-KVM-installer-$name/OSX-KVM';
    }
    try {
      'ip tuntap add dev tap0 mode tap'
          .start(privileged: true, workingDirectory: directory);
    } on Exception catch (_) {
      echo(orange('tap0 unavailable freeing resource and retrying\n'));
      'ip link delete tap0'.start(privileged: true);
      if (retries < 10) {
        setupQuickNetworking(retries + 1);
      } else {
        echo(red(
            'FATAL: Unable to setup networking after retry. There might be some issue other than unavailable resources\n'));
        exit(1);
      }
    }
    try {
      'ip link set tap0 up promisc on'
          .start(privileged: true, workingDirectory: directory);
      'ip link set dev virbr0 up'
          .start(privileged: true, workingDirectory: directory);
      'ip link set dev tap0 master virbr0'
          .start(privileged: true, workingDirectory: directory);
    } on Exception catch (_) {
      try {
        'virsh net-start default'.start(privileged: true);
      } on Exception catch (_) {
        try {
          echo(orange("default network not found, creating default\n"));

          'systemctl enable libvirtd'
              .start(privileged: true, workingDirectory: directory);
          'systemctl start libvirtd'
              .start(privileged: true, workingDirectory: directory);

          var defaultXml =
              await new File('$HOME/OSX-KVM-installer/OSX-KVM/default.xml')
                  .create(recursive: false);
          var stream = defaultXml.openWrite();
          stream.write('<network>\n');
          stream.write('  <name>default</name>\n');
          stream.write('  <uuid>9a05da11-e96b-47f3-8253-a3a482e445f5</uuid>\n');
          stream.write('  <forward mode=\'nat\'/>\n');
          stream.write('  <bridge name=\'virbr0\' stp=\'on\' delay=\'0\'/>\n');
          stream.write('  <mac address=\'52:54:00:0a:cd:21\'/>\n');
          stream.write(
              '  <ip address=\'192.168.122.1\' netmask=\'255.255.255.0\'>\n');
          stream.write('    <dhcp>\n');
          stream.write(
              '      <range start=\'192.168.122.2\' end=\'192.168.122.254\'/>\n');
          stream.write('    </dhcp>\n');
          stream.write('  </ip>\n');
          stream.write('</network>\n');
          stream.close();

          'virsh net-define --file default.xml'
              .start(privileged: true, workingDirectory: directory);
          //'virsh net-start default'.start(privileged: true);
        } on Exception catch (_) {
          if (retries < 10) {
            setupQuickNetworking(retries + 1);
          } else {
            echo(red(
                'FATAL: Unable to setup networking after retry. There might be some issue other than unavailable resources\n'));
            exit(1);
          }
        }
      }

      if (retries < 10) {
        setupQuickNetworking(retries + 1);
      } else {
        echo(red(
            'FATAL: Unable to setup networking after retry. There might be some issue other than unavailable resources\n'));
        exit(1);
      }
    }
  }

  ///
  static void libVirtManager({String name}) {
    var directory;
    if (name == null) {
      directory = '$HOME/OSX-KVM-installer/OSX-KVM';
    } else {
      directory = '$HOME/OSX-KVM-installer-$name/OSX-KVM';
    }
    r'sed -i "s/CHANGEME/$USER/g" macOS-libvirt-Catalina.xml'
        .start(privileged: true, workingDirectory: directory);
    'virt-xml-validate macOS-libvirt-Catalina.xml'
        .start(workingDirectory: directory);
    'virsh --connect qemu:///system define macOS-libvirt-Catalina.xml'
        .start(workingDirectory: directory);
  }

  ///
  static void setupEXE({String name}) {
    var directory;
    if (name == null) {
      directory = '$HOME/OSX-KVM-installer/OSX-KVM-runner';
    } else {
      directory = '$HOME/OSX-KVM-installer-$name/OSX-KVM-runner';
    }
    if (!exists(directory)) {
      createDir('$HOME/OSX-KVM-installer/OSX-KVM-runner');
    } else {
      'rm -rf OSX-KVM-runner'
          .start(workingDirectory: '$HOME/OSX-KVM-installer');
      createDir(directory);
    }
    fetch(
        url:
            'https://github.com/relf108/OSX-KVM-runner/releases/download/beta-2/OSX-KVM-runner',
        saveToPath: '$directory/osx_kvm_runner');

    'chmod +x osx_kvm_runner'.start(workingDirectory: directory);
    if (Shell.current.matchByName(BashShell.shellName)) {
      '.bashrc'.append('PATH="\$PATH":"$directory"');
    }
    if (Shell.current.matchByName(ZshShell.shellName)) {
      '.zshrc'.append('PATH="\$PATH":"$directory"');
    }
  }
}

///
bool checkSize(String size) {
  if (int.tryParse(size) < 30) {
    red('Fatal: Size must be at least 30GB');
    return false;
  }
  return true;
}
