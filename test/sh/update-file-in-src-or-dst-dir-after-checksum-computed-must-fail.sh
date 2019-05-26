rm -r src
rm -r dst

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

chmod +x ./checksum-comparator.sh
bash ./checksum-comparator.sh --debug src dst


echo "one update" > dst/subdir/file1
echo "IT MUST FAIL"
exit 1
# it must detect that an update is occurred and must recompute the checksum
bash ./checksum-comparator.sh --debug src dst
if [ $? = 0 ]; then
  exit 1
fi
exit 1
exit 0