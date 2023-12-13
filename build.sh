#!/usr/local/bin/bash

set -e

# Set up the "deploy" branch in the build directory if it's not already there.
if [ ! -d build ]; then
    echo "Setting up 'build' directory..."
    git remote show gandi || git remote add gandi git+ssh://9361771@git.sd5.gpaas.net/default.git
    mkdir build
    git worktree add --detach build
    cd build
    git checkout --orphan deploy
fi

# Build our submodules
cd measure-hider
./build.sh
cd ..

rm -rf build/*
cp -p wsgi.py build/
cp -p measure-hider/build/requirements.txt build/
mkdir -p build/measure-hider
cp -rp measure-hider/build build/measure-hider/

cd build
git add -A .
git diff --quiet && git diff --staged --quiet || git commit -m "Update deploy branch"
#git push gandi deploy
#ssh 9361771@git.sd5.gpaas.net 'deploy default.git deploy'
cd ..
lftp -e 'mirror -P 10 -R build /vhosts/default' -u '9361771,' sftp://sftp.sd5.gpaas.net
