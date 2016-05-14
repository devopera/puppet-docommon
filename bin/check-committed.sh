echo "Run this script from /etc/puppet (top-level) if you see an error."
echo "--------------- devopera modules ---"
for i in `ls -1 modules | grep ^do`
do
  cd "modules/"$i
  echo 'Checking status of '$i
  git status -u .
  cd ../..
done
echo "--------------- manual modules ---"
manuals=( 'ssh' 'vmwaretools' 'mysql' )
for i in "${manuals[@]}"
do
  cd "modules/"$i
  echo 'Checking status of '$i
  git status -u .
  cd ../..
done
