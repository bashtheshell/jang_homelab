#!/usr/bin/env bash
#
# A convenient bootstrapping script to download and configure all 
# necessary files needed to kickstart your physical host.
#
# Filename: preboot-configurator.sh (with 700 permission)
#

#**** NOTE: THIS SCRIPT WILL ATTEMPT TO USE YOUR PRIVATE KEY *****

##################################################################
# This script assumes to be located on a local linux web server  #
# (inaccessible to the public) with bash shell and git commands. #
# Hint: A Raspberry Pi running a web server would be ideal.      #
#                                                                #
# If you are using a PXE server, be sure to have it configured   #
# to point to correct web location where kickstart file is.      #
##################################################################

#**** NOTE: THIS SCRIPT WILL ATTEMPT TO USE YOUR PRIVATE KEY *****



#=================== PLEASE MAKE CHANGE BELOW ========================#


### Directory where 'preboot' directory with the kickstart file will be placed (usually in your web server DocumentRoot path)
kickstartDir=/var/www/your_document_root_path
#kickstartDir=$(dirname $0) # Uncomment this line and comment the above line if you prefer to use the directory the script is currently in

### Location of original private key to access private Bitbucket repo ( typically ~/.ssh/id_rsa )
# NOTE: This private key should not be world readable. A world-readable copy for kickstart will be made later.
bitbucketPrivateKey=~/.ssh/id_rsa


### Your private Bitbucket repo 
# Hint: it's the same repo in 'preboot/custom-variables-fb.var'
bitbucketRepo=my_account_username/my_repo.git


#=================== PLEASE MAKE CHANGE ABOVE ========================#



### Functions for later interactive scripts

prompt () {
	while true
	do
		read -p "$1 [y|q(uit)|N]: " yn
		case $yn in
			[Yy]|[Yy][Ee][Ss] )
				return 1
				;;
			[Nn]|[Nn][Oo]|q )
				return 0
				;;
			* ) echo "Please answer yes or no.";;
		esac
		done
}

response () {
	# 1st arg expects 'prompt' function and 2nd arg expects exit 
	if [ "$1" == "1" ]
	then
		echo "" # add a blank line and continue the script 
	else
		eval $2
		exit
	fi
}

### Exit strings for response functions later
kickstartDirExit='echo "Please modify the 'kickStartDir' value in this script file if necessary. This script will exit now."'

bitbucketPrivateKeyExit='echo "Please modify the 'bitbucketPrivateKey' value in this script file if necessary. This script will exit now."'

existingFilesExit='echo "Please make backup of the file and attempt the script again. This script will exit now."'


### Change this file permission (becomes effective after first run)
chmod go-rwx $0


# --------------------- BEGINNING OF INTERACTIVE SCRIPT -----------------------#

### Introduction to script
echo ""
echo "You are now entering in an interactive script from '$(basename $0)' file."
echo ""
echo "The purpose of this script is to prepare the web server hosting this script file \
to serve the physical host necessary files to kickstart a fresh server installation."
echo ""
echo "This script will use the following Bitbucket repository to download files:"
echo "---> $bitbucketRepo"
echo ""


### Setting the working directory
echo "Changing working directory to ..."
if [ -d "$kickstartDir" ]
then
	cd $kickstartDir
	echo "---> $kickstartDir"
	echo ""
else
	echo "ERROR: '$kickstartDir' does not exist. Please check the 'kickstartDir' value in this script file."
	echo "This script will exit now."
	exit
fi

prompt "Do you want to continue with the above directory?"
response "$?" "$kickstartDirExit" #  $? is the return status from 'prompt' function


### Verifying the Bitbucket private key
echo "Now attempting to access the private key for Bitbucket..."
echo "Using private key: $bitbucketPrivateKey" 
echo ""
if [ -e "$bitbucketPrivateKey" ] && [ -n "$(find $bitbucketPrivateKey -type f -perm -o=r)" ] # checking if world-readable
then
	echo -n "WARNING: The private key is currently world-readable. "
	echo -n "Expecting original private key with appropriate permission. "
	echo -n "You may will receive explicit warning after the 'ssh-add' command. "
	echo "Please modify the 'bitbucketPrivateKey' value in this script file later if necessary. "
	echo ""
elif [ ! -e "$bitbucketPrivateKey" ]
then
	echo -n "ERROR: The private key does not exist. "
	echo "Please modify the 'bitbucketPrivateKey' value in this script file if necessary. "
	exit
else
	prompt "Do you want to continue with the above private key?"
	response "$?" "$bitbucketPrivateKeyExit" 
fi


### Attempt to set up ssh-agent and make a copy of the key
eval "$(/usr/bin/ssh-agent)"
ssh-add $bitbucketPrivateKey
last_exit_status=$?

if [ "$last_exit_status" != "0" ] # Exit if private key is mangled
then
	echo ""
	echo -n "ERROR: There appeared to be a problem with your private key. Unable to make a copy of it. "
	echo "This script will exit now."
	exit
else
	echo ""
	echo "Copying your private key to the working directory: $kickstartDir"
	cp $bitbucketPrivateKey $kickstartDir/bitbucket_key
	echo "Making the copied key world-readable for the web server."
	chmod o+r $kickstartDir/bitbucket_key
	echo ""
fi


### Download the kickstart file, script file, and variable files along with './preboot' directory.
if [ ! "$(grep ^bitbucket.org ~/.ssh/known_hosts)" ]
then
        ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts
fi

echo "Now attempting to download files to: '$kickstartDir/preboot' directory."
echo ""

if [ -e "$kickstartDir/preboot/physicalhost-ks.cfg" ] 
then
	echo "WARNING: physicalhost-ks.cfg file in './preboot' directory already existed"
	prompt "Do you want to continue and overwrite the above file?"
	response "$?" "$existingFilesExit"
fi
if [ -e "$kickstartDir/preboot/custom-variables-fb.var" ]
then
	echo "WARNING: custom-variables-fb.var file in './preboot' directory already existed"
	prompt "Do you want to continue and overwrite the above file?"
	response "$?" "$existingFilesExit"
fi

git init
git fetch git@bitbucket.org:$bitbucketRepo
git checkout FETCH_HEAD 'preboot/physicalhost-ks.cfg'
git checkout FETCH_HEAD 'preboot/custom-variables-fb.var'
git checkout FETCH_HEAD 'preboot/kickstart-modifier.sh'
git_success=$? # track exit status of git command
rm -rf .git
ssh-agent -k


### Perform the modification to the downloaded kickstart file
if [ "$git_success" == "0" ]
then
	echo ""
	prompt "Would you like us to run the 'kickstart-modifier.sh' script for you?"
	if [ "$?" == "1" ] 
	then
		echo ""
		echo "Executing 'kickstart-modifier.sh' script..." 
		chmod +x $kickstartDir/preboot/kickstart-modifier.sh
		$kickstartDir/preboot/kickstart-modifier.sh
	fi
fi

echo ""
echo "This script is now complete. Exiting the interactive script."


# ------------------------ END OF INTERACTIVE SCRIPT --------------------------#

