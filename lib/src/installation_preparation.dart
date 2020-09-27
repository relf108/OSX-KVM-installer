#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';

class InstallationPreparation {
  static bool detectWSL() {
    var result = read('/proc/version');
    result.forEach((line) {
      if (line.contains('Microsoft')) {
        return true;
      }
    });
    return false;
  }

  ///
  static void cloneOSXKVM() {
    if (exists('$HOME/OSX-KVM-installer/OSX-KVM')) {
      var allowed = ask(
          'OSX-KVM found, re-clone to ensure latest version?'
          ' \n [y(Y)/n(N)]',
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
        echo('Continuing with local version');
      }
    } else {
      try {
        'git clone https://github.com/kholia/OSX-KVM.git'
            .start(workingDirectory: '$HOME/OSX-KVM-installer');
      } on Exception catch (_) {
        rethrow;
      }
    }
  }

  ///
  static void fetchInstaller() {
    try {
      //Installs the latest version of catalina as Koila's
      //menu seems to be broken at the moment
      './fetch-macOS.py --version 10.15.6'.start(
          privileged: true,
          workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM',
          terminal: true);
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void convertToIMG() {
    try {
      'dmg2img BaseSystem.dmg BaseSystem.img'.start(
          privileged: true,
          workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void createHDD({@required int sizeGB}) {
    try {
      'qemu-img create -f qcow2 mac_hdd_ng.img ${sizeGB.toString()}G'.start(
          privileged: true,
          workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void setupQuickNetworking() {
    var attempts = 0;
    try {
      'ip tuntap add dev tap0 mode tap'.start(
          privileged: true,
          workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
      'ip link set tap0 up promisc on'.start(
          privileged: true,
          workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
      'ip link set dev virbr0 up'.start(
          privileged: true,
          workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
      'ip link set dev tap0 master virbr0'.start(
          privileged: true,
          workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
    } on Exception catch (_) {
      echo('tap0 unavailable freeing resource and retrying ${attempts}');
      attempts++;
      'ip link delete tap0'.start(privileged: true);
      if (attempts <= 3) {
        setupQuickNetworking();
      } else {
        echo(
            'unable to setup networking after 3 retries. There might be some issue other than unavailable resources');
        exit(1);
      }
    }
  }

  ///
  static void libVirtManager() {
    r'sed -i "s/CHANGEME/$USER/g" macOS-libvirt-Catalina.xml'.start(
        privileged: true, workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
    'virt-xml-validate macOS-libvirt-Catalina.xml'
        .start(workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
    'virsh --connect qemu:///system define macOS-libvirt-Catalina.xml'
        .start(workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM');
  }

  ///
  static void setupEXE() {
    if (!exists('$HOME/OSX-KVM-installer/OSX-KVM-runner')) {
      createDir('$HOME/OSX-KVM-installer/OSX-KVM-runner');
    } else {
      'rm -rf OSX-KVM-runner'
          .start(workingDirectory: '$HOME/OSX-KVM-installer');
      createDir('$HOME/OSX-KVM-installer/OSX-KVM-runner');
    }
    fetch(
        url:
            'https://github.com/relf108/OSX-KVM-runner/releases/download/beta-2/OSX-KVM-runner',
        saveToPath: '$HOME/OSX-KVM-installer/OSX-KVM-runner/osx_kvm_runner');

    'chmod +x osx_kvm_runner'
        .start(workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM-runner');
  }

  static void wslX11Setup() {
    fetch(
        url:
            'https://downloads.sourceforge.net/project/vcxsrv/vcxsrv/1.20.8.1/vcxsrv-64.1.20.8.1.installer.exe?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fvcxsrv%2Ffiles%2Flatest%2Fdownload&ts=1601204263',
        saveToPath: '$HOME/OSX-KVM-installer/vcxsrv-installer.exe');

    'vcxsrv-installer.exe /quiet'
        .start(workingDirectory: '$HOME/OSX-KVM-installer');

    'export DISPLAY="`grep nameserver /etc/resolv.conf | sed \'s/nameserver //\'`:0\" >> /etc/bash.bashrc'
        .start(workingDirectory: '$HOME/OSX-KVM-installer', privileged: true);
  }
}

///
bool checkSize(String size) {
  if (int.tryParse(size) < 30) {
    echo('Size must be at least 30GB');
    return false;
  }
  return true;
}
