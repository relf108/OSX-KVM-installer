# OSX-KVM-installer
An automation of the cli based installation steps for the kholia / OSX-KVM project. This is installer just calls each of the cli commands listed. All the credit for cli based applications being called goes to kholia.

# Running the script
In order to run this you will need to have dcli installed.Do so with these commands.  <br>
wget https://raw.githubusercontent.com/bsutton/dcli/master/bin/linux/dcli_install <br>
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
You're good to go, chief.
