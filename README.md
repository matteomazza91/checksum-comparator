# checksum-comparator
perform the comparison of 2 directories creating a checksum of each file and store them for future incremental checks.   
If a file had changed since the last execution, the change will be detected and the checksum will be computed again.

#### build status
[![Build Status](https://dev.azure.com/matteomazza/matteomazza/_apis/build/status/matteomazza91.checksum-comparator?branchName=master)](https://dev.azure.com/matteomazza/matteomazza/_build/latest?definitionId=1&branchName=master)

## Usage

```
USAGE: ./checksum-comparator.sh [options] <src_dir> <dst_dir>

options:
  -s | --silent: don't print anything
  --error: [default] print only errors found. ex: missing files, different files
  --info: print information about the computed files
  --debug: print debug information
  --trace: print all the possible information

./checksum-comparator.sh compares src and dst directories performing checksums of all the files
It can be interrupted at any time and restarted later
exit value:
  0: the 2 directories contains the same files
  not 0: the 2 directories have at least one difference or an error occurred
```
