# *NOTE*
As it stands this installer only works on debian based linux distributions (Ubuntu, POP_OS, etc).<br>
This is purely because it installs dependencies with apt. If you would like to use the installer with some other package manager raise an issue and I'll implement it.

# Running 
```bash
wget https://github.com/relf108/OSX-KVM-installer/releases/download/v1.5/osx_kvm_installer
chmod +x osx_kvm_installer
./osx_kvm_installer
```

# Building 

# OSX-KVM-installer
An automation of the cli based installation steps for the kholia / OSX-KVM project. This installer just calls each of the cli commands listed on the installation guide. All the credit for the software making this possible goes to kholia. <br>
All credit for dcli goes to bsutton.

# Running the script
In order to run this you will need to have dcli installed. Do so with these commands.  <br>
wget wget https://github.com/bsutton/dcli/releases/download/latest-linux/dcli_install <br>
chmod +x dcli_install <br>
./dcli_install <br>
Next, clone this code to your local device, navigate to OSX-KVM-installer and type ./installer.dart. <br>
Answer requested input as the program runs and you're done.

# Post installation
After the script has been run a qemu view will pop up with the osx installer. <br>
Select the base-osx drive with your keyboard, another windows will pop up. <br>
Open the disk utility and select the drive with storage set to whatever you passed in (32 is the default). <br>
Select erase on this drive and once that process is finished close the window. You should be taken back to the program select screen.<br>
Select reinstall macOS and follow the installation process.<br>
Your OSX VM should be available from virt-manager.<br>
You're good to go, chief.
