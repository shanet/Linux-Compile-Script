#! /bin/bash
# Shane Tully
# Modified from https://wiki.ubuntu.com/KernelTeam/GitKernelBuild

function printLine {
   for ((i=0; i<$1; i++)); do
      echo -en "=-"
   done
   echo "="
}


clear
printLine 27
echo -e "\t\tLinux Compile Script"
printLine 27
echo -e "\nThis script will compile the Linux kernel into a .deb package for use on Debian based systems. Ctrl + C to canel at any time."

# If given a kernel source directory, cd to it. If not, assume the source is in the working directory.
if [ $1 ]; then
   directory=$1
else
   echo -e "\nNo directory specified. Assuming already in kernel source directory."
   directory=$(pwd)
fi

# Print confirmation of directory
echo -en "\nUsing directory \"" $directory "\". Enter to begin. "
read junk

# cd to given directory
cd $directory

# At least make sure a MakeFile is present before attemping to compile
if [ ! -f "Makefile" ]; then
   echo -e "\nFATAL ERROR: Makefile not found. Exiting."
   cd -
   exit
fi

echo -en "\nCopying current kernel config..."
cp /boot/config-$(uname -r) .config
echo -e "done."

echo -en "\nUpdating config file to defaults..."
yes '' | make oldconfig > /dev/null
echo -e "done."

echo -en "\nRemoving \"echo \"+\"\" from scripts/setlocalversion..."
sed -rie 's/echo "\+"/#echo "\+"/' scripts/setlocalversion
echo -e "done."

echo -en "\nCleaning kernel source directory..."
make-kpkg clean > /dev/null
echo -e "done.\n"

printLine 27
echo -en "Ready to compile kernel. Make any custom config changes before going on. Enter to continue. "
read ready
CONCURRENCY_LEVEL=`getconf _NPROCESSORS_ONLN` fakeroot make-kpkg --initrd --append-to-version=-custom kernel_image kernel_headers

# Go back to the previous directory
cd -

echo -e "\n\n\n\n"
printLine 27
echo -e "Kernel compile finished. Use dpkg to install the\nkernel packages at will. Bye!"
exit
