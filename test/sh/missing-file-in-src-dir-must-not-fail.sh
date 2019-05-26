rm -r src
rm -r dst

mkdir src
mkdir dst

mkdir src/subdir
mkdir dst/subdir

touch dst/file1

echo "test" > src/file2
echo "test" > dst/file2


echo "yet another test" > src/subdir/file1
echo "yet another test" > dst/subdir/file1
echo "yet another line" >> src/subdir/file1
echo "yet another line" >> dst/subdir/file1

chmod +x ./checksum-comparator.sh
bash ./checksum-comparator.sh --debug src dst
if [ $? = 0 ]; then
  exit 0
fi

exit 1