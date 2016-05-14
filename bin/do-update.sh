echo "Run this script from /etc/puppet (top-level) if you see an error."
echo "--------------- devopera modules ---"
cwd=`pwd`
for i in `ls -1 modules | grep ^do`
do
  cd "modules/"$i
  echo 'Updating '$i
  git pull
  cd $cwd
done
echo "--------------- manual modules ---"
manuals=( 'ssh' 'vmwaretools' 'mysql' 'dns' )
for i in "${manuals[@]}"
do
  cd "modules/"$i
  echo 'Updating '$i
  git pull
  cd $cwd
done

