#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';

class InstallationPreparation {
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

      './fetch-macOS-v2.py'.start(
          privileged: true,
          workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM',
          terminal: true);

      // './fetch-macOS.py --version 10.15.6'.start(
      //     privileged: true,
      //     workingDirectory: '$HOME/OSX-KVM-installer/OSX-KVM',
      //     terminal: true);
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
  static void setupQuickNetworking(bool retry) {
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
      echo('tap0 unavailable freeing resource and retrying');
      'ip link delete tap0'.start(privileged: true);
      'virsh net-start default'.start();
      if (retry == false) {
        setupQuickNetworking(true);
      } else {
        echo(
            'unable to setup networking after retry. There might be some issue other than unavailable resources');
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
}

///
bool checkSize(String size) {
  if (int.tryParse(size) < 30) {
    echo('Size must be at least 30GB');
    return false;
  }
  return true;
}
