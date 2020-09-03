#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';

class InstallationPreparation {
  ///
  static void installDependencies() {
    try {
      'sudo apt-get install python qemu uml-utilities virt-manager dmg2img git wget libguestfs-tools -y'
          .start(privileged: true);
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void cloneOSXKVM() {
    if (exists('$HOME/OSX-KVM')) {
      var allowed = ask(
          'Path $HOME/OSX-KVM found, this must be deleted to continue'
          ' \n Delete OSX-KVM? [y(Y)/n(N)]',
          defaultValue: 'n',
          validator: Ask.alpha);
      if (allowed == 'y' || allowed == 'Y') {
        'rm -rf OSX-KVM'.start(privileged: true, workingDirectory: '$HOME');
      } else {
        echo('Dissallowed, exiting installer');
        exit(1);
      }
    }
    try {
      'git clone https://github.com/kholia/OSX-KVM.git'
          .start(privileged: true, workingDirectory: '$HOME');
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void fetchInstaller() {
    try {
      './fetch-macOS.py'.start(
          privileged: true, workingDirectory: '$HOME/OSX-KVM', terminal: true);
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void convertToIMG() {
    try {
      'dmg2img BaseSystem.dmg BaseSystem.img'
          .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void createHDD({@required int sizeGB}) {
    try {
      'qemu-img create -f qcow2 mac_hdd_ng.img ${sizeGB.toString()}G'
          .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void setupQuickNetworking() {
    try {
      'ip tuntap add dev tap0 mode tap'
          .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
      'ip link set tap0 up promisc on'
          .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
      'ip link set dev virbr0 up'
          .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
      'ip link set dev tap0 master virbr0'
          .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
    } on Exception catch (_) {
      rethrow;
    }
  }

  ///
  static void libVirtManager() {
    r'sed -i "s/CHANGEME/$USER/g" macOS-libvirt-Catalina.xml'
        .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
    'virt-xml-validate macOS-libvirt-Catalina.xml'
        .start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
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
