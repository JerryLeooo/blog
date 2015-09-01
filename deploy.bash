#! /bin/bash


git add .
git commit -m "`curl -s http://whatthecommit.com | perl -p0e '($_)=m{<p>(.+?)</p>}s'`"
git push origin master

gitbook build --output=~/pages
cd ~/pages
git init
git add .
git commit -m "curl -s http://whatthecommit.com | perl -p0e '($_)=m{<p>(.+?)</p>}s'"
git push https://jerryleooo:$GITHUB_PASS@github.com/JerryLeooo/jerryleooo.github.io.git master -f
rm -rf ~/pages
