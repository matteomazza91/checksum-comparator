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

# simulate the user doing something
# note: depending on the precision of the stored modify date, 
#       this test can fail without this sleep command because too fast during execution phase
sleep 1


rm src/subdir/file1.md5sum
if [ $? != 0 ]; then
  echo "invalid test. this test must replace the generated checksum"
  exit 1
fi
touch src/subdir/file1.md5sum

bash ./checksum-comparator.sh --debug src dst
if [ $? = 0 ]; then
  # if a checksum file is empty, it must be ignored.
  # because if a SIG-INT arrives during a checksum computation, the checksum file is already created but empty.
  exit 0
fi

exit 1