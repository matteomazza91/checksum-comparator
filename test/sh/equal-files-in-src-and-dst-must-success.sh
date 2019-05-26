mkdir src
mkdir dst

mkdir src/subdir
mkdir dst/subdir

touch src/file1
touch dst/file1

echo "test" > src/file2
echo "test" > dst/file2


echo "yet another test" > src/subdir/file1
echo "yet another test" > dst/subdir/file1
echo "yet another line" >> src/subdir/file1
echo "yet another line" >> dst/subdir/file1

if [ ./checksum-comparator --debug src dst ]; then
  exit 0
fi

exit 1