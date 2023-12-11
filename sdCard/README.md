```
# sudo fdisk -lu rawDisk
# sudo mount -o offset=$((512*2048)),uid=1000,user ./rawDisk /mnt
# sudo losetup -o $((512*2048)) /dev/loop1 ./rawDisk
# sudo fsck -fv /dev/loop1
# sudo mkfs.vfat -s 2 -F 32 /dev/loop1

# sudo losetup -d /dev/loop1
```


What's on the disk:
```
# find .
.
./theFile.txt
./theLongFileName.txt
./folder
./folder/first.dat
./folder/second.dat
# cat theFile.txt 
some data here
# cat theLongFileName.txt 
another thing
```
