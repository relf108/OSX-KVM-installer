#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:meta/meta.dart';

class InstallationPreparation{
  static bool installDependencies(){
    var result = true;
    try{
      'sudo apt-get install python qemu uml-utilities virt-manager dmg2img git wget libguestfs-tools -y'
          .start(privileged: true);
    }
    on Exception catch(_){
      result = false;
    }
    return result;
  }

  static bool cloneOSXKVM(){
    var result = true;
    try{
      'git clone https://github.com/kholia/OSX-KVM.git'.start(privileged: true, workingDirectory: HOME);
    }
    on Exception catch(_){
      result = false;
    }
    return result;
  }

  static bool fetchInstaller(){
    var result = true;
    try{
      './fetch-macOS.py'.start(privileged: true , workingDirectory: '$HOME/OSX-KVM', terminal: true);
    }
    on Exception catch(_){
      result = false;
    }
    return result;
  }

  static bool convertToIMG(){
    var result = true;
    try{
      'dmg2img BaseSystem.dmg BaseSystem.img'.start(privileged: true ,workingDirectory: '$HOME/OSX-KVM');
    }
    on Exception catch(_){
      result = false;
    }
    return result;
  }
  static bool createHDD({@required int sizeGB}){
    var result = true;
    try{
      'qemu-img create -f qcow2 mac_hdd_ng.img ${sizeGB.toString()}G'.start(privileged: true,workingDirectory: '$HOME/OSX-KVM');
    }
    on Exception catch(_){
      result = false;
    }
    return result;
  }

  static bool setupQuickNetworking(){
    var result = true;
    try{
      'ip tuntap add dev tap0 mode tap'.start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
      'ip link set tap0 up promisc on'.start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
      'ip link set dev virbr0 up'.start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
      'ip link set dev tap0 master virbr0'.start(privileged: true, workingDirectory: '$HOME/OSX-KVM');
    }
    on Exception catch(_){
      result = false;
    }
    return result;
  }
}