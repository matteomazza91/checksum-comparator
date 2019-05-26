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

echo "just one unwanted line" >> dst/subdir/file1
echo "a missing file" > src/missingFile

chmod +x ./checksum-comparator.sh
bash ./checksum-comparator.sh --debug -s src dst > test-silent.output
if [ -s test-silent.output ]; then
  cat test-silent.output
  exit 1
fi

exit 0