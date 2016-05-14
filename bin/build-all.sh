echo "Run this script from /etc/puppet (top-level) if you see an error."
echo 'Clearing out old builds'
find `pwd -P` -name 'pkg' -exec rm -rf {} \;
echo "Building devopera modules"
cwd=`pwd`
for i in `ls -1 modules | grep ^do`
do
  cd "modules/"$i
  echo 'Building '$i
  puppet module build
  cd $cwd
done
echo 'Copy modules to lightenn home'
find `pwd -P` -name '*.tar.gz' -exec cp {} ~/ \;
echo 'Done'

