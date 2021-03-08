# Running 
```bash
wget https://github.com/relf108/OSX-KVM-installer/releases/download/1.0.3/osx_kvm_installer
chmod +x osx_kvm_installer
./osx_kvm_installer
```
Thats it, you've just run the installer, now go to post installation for more info on setting up your install.

# Building 
An automation of the cli based installation process for the kholia / OSX-KVM project.
# Running the script form source
In order to run this you will need to have dcli installed. Do so with these commands.  <br>
wget https://github.com/bsutton/dcli/releases/download/latest-linux/dcli_install <br>
chmod +x dcli_install <br>
./dcli_install <br>
Next, clone this code to your local device, navigate to OSX-KVM-installer and type ./installer.dart. <br>
Answer requested input as the program runs and you're done.

# Post installation
After the script has been run a qemu view will pop up with the osx installer. <br>
Select the base-osx drive with your keyboard, another window will pop up. <br>
Open the disk utility and select the drive with storage set to whatever you passed in (64 is the default). <br>
Select erase on this drive and once that process is finished close the window. You should be taken back to the program select screen.<br>
Select reinstall macOS and follow the installation process.<br>
To run your new macOS installation any time simply navigate to the OSX-KVM-runner directory created inside the OSX-KVM-installer directory.<br>
and run the osx_kvm_runner file with <br>
```./osx_kvm_runner``` <br>
You're good to go, chief.
