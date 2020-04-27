#!/bin/bash

# Attempt to reproduce a git bug I discovered
# may not be successful

set -e

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))
WORKDIR=$THIS_SCRIPT_DIR/lrn_work

echo "Cleaning work directory"
rm -rf $WORKDIR

# Warning: We start using custom home directory!
# This is so we can simulate git's behavior of opening multiple config files
# without having any effect with the user's actual config file
# or having to recompile git with custom $(prefix).
echo "Setting up custom home directory"
HOME=$WORKDIR/home/irving

echo "Setting up other directories"
mkdir -p $HOME
mkdir -p $WORKDIR/media/archives/src/github.com
ln -s -T $WORKDIR/media/archives/src/           $HOME/src

echo "Setting up alternate git config files"
cat << EOF > $HOME/.gitconfig
[core]
	pager = ""
[user]
	useConfigOnly = true
[includeIf "gitdir:src/github.com/"]
	path = $HOME/.cfg-github
EOF

cat << EOF > $HOME/.cfg-github
[user]
	email = custom-email@users.noreply.github.com
	name = github-username
[core]
	sshCommand = ssh -i ~/.ssh/id_rsa
EOF

echo ""
echo "Overview of directory structure"
cd $WORKDIR
tree -a

echo ""
echo "Check out a sample repository"
cd $WORKDIR/media/archives/src/github.com
#cd $HOME/src/github.com
git clone --depth 1 https://github.com/latchset/clevis.git

echo ""
echo "Current directory: $(pwd)"
echo "Git configuration at repository root directory:"
cd $HOME/src/github.com/clevis
git config -l | cat

echo ""
echo "Current directory: $(pwd)"
echo "Git configuration at repository subdirectory:"
cd $HOME/src/github.com/clevis/src
git config -l | cat
