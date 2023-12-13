#!/usr/local/bin/bash

set -e

cd measure-hider
./build.sh
cd ..

mkdir -p build

git remote show gandi || git remote add gandi git+ssh://9361771@git.sd5.gpaas.net/default.git
git worktree add build deploy

#cd client && npm run build; cd ..
#mkdir -p build/client
#rm -rf build/client/*
#cp -r client/build/* build/client/
#cp -p server/{measure_hider_modeler.py,model.pt,requirements.txt,wsgi.py} build/

#cd build
#git add -A .
#git commit -m "Update deploy branch"
###git push gandi deploy
###ssh 9361771@git.sd5.gpaas.net 'deploy default.git deploy'
#cd ..
#lftp -e 'mirror -P 10 -R build /vhosts/default' -u '9361771,' sftp://sftp.sd5.gpaas.net
