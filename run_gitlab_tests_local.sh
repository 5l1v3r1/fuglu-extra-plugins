#!/bin/bash

display_help(){
   echo ""
   echo "----------------------------------#"
   echo "- Local gitlab testing framework -#"
   echo "----------------------------------#"
   echo ""
   echo " Hosting this repo on gitlab, automatic testing can be defined .gitlab-ci.yml"
   echo " in the main directory. It is also possible to run these test locally (which"
   echo " I would recommend before submitting)."
   echo ""
   echo " This scripts runs all the tests which will also run on gitlab. Plesae note"
   echo " changes have to be commited to be tested."
   echo ""
   echo " Requirements:"
   echo " 1) docker installation"
   echo " 2) install gitlab-runner (https://docs.gitlab.com/runner/install/linux-repository.html)"
   echo ""
}

# no arguments needed, print help if there are any...
if [ $# -ne 0 ]; then
   display_help
   exit 0
fi

maindir=$(cd "$(dirname "$0")"; pwd)

echo "maindir: $maindir"
cd $maindir

curbranch=`git rev-parse --abbrev-ref HEAD`
echo "Current git branch: $curbranch"
if [ "$curbranch" == "master" ]; then
   echo "-> use default fuglu docker image"
   alljobs=(unittests_py3 unittests_py2)
elif [ "$curbranch" == "develop" ]; then
   echo "-> use develop fuglu docker image"
   alljobs=(unittests_dev_py3 unittests_dev_py2)
else
   echo "-> use default fuglu docker image"
   alljobs=(unittests_py3 unittests_py2)
fi

for job in "${alljobs[@]}"
do
   echo ""
   echo ""
   echo "--------------------------------"
   echo "Running job $job"
   echo "--------------------------------"
   echo ""
   gitlab-runner exec docker $job
   # check return
   rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
done

cd -
exit 0
