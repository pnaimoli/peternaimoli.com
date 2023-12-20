#!/usr/local/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to display help information
show_help() {
  cat << EOF
Usage: ${0##*/} [--gitdeploy|--fastdeploy|--help|-h]

Options:
  --gitdeploy    Push to the 'gandi' remote and deploy via ssh.
  --fastdeploy   Use lftp to mirror the build directory to the server.
  --help, -h     Display this help and exit.

This script builds specified modules, combines their requirements,
and deploys the build to a specified server or location.
EOF
}

# Check for help option
for arg in "$@"; do
  if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
    show_help
    exit 0
  fi
done

# Define the list of modules to build
modules=("chordmania" "measure-hider")

# Check if the 'build' directory exists. If not, set it up.
if [ ! -d build ]; then
    echo "Setting up 'build' directory..."

    # Add remote 'gandi' if it doesn't exist
    git remote show gandi || git remote add gandi git+ssh://9361771@git.sd5.gpaas.net/default.git

    # Create 'build' directory and set up a detached worktree
    mkdir build
    git worktree add --detach build

    # Change to the 'build' directory and create a new orphan branch 'deploy'
    cd build
    git checkout --orphan deploy
    cd ..
fi

# Build submodules
for module in "${modules[@]}"; do
    echo "Building ${module}..."
    cd "${module}"
    ./build.sh
    cd ..
done

# Clear the contents of the 'build' directory
rm -rf build/*

# Combine requirements.txt files from all modules
for module in "${modules[@]}"; do
    cat "${module}/build/requirements.txt" >> build/requirements.txt
done

# Copy built files to specific directories within 'build'
for module in "${modules[@]}"; do
    mkdir -p "build/${module}-build"
    cp -rp "${module}/build/"* "build/${module}-build/"
done

# Copy the wsgi.py file to the 'build' directory.  Don't use -p
# so that the wsgi server restats.
cp wsgi.py build/

# Add and commit changes to git, check for any changes before committing
# cd build
# git add -A .
# git diff --quiet && git diff --staged --quiet || git commit -m "Update deploy branch"
# cd ..

# Conditional execution based on script arguments
if [[ " $* " =~ " --gitdeploy " ]]; then
    cd build
    # Push to the 'gandi' remote and deploy via ssh
    git push gandi deploy
    sh 9361771@git.sd5.gpaas.net 'deploy default.git deploy'
    cd ..
elif [[ " $* " =~ " --fastdeploy " ]]; then
    # Use lftp to mirror the build directory to the server
    lftp -e 'mirror -P 10 -R build /vhosts/default' -u '9361771,' sftp://sftp.sd5.gpaas.net
fi
