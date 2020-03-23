echo "This script will fill memory to 90% with zeros."
# disable swap, only use RAM
sudo swapoff -a

# find current system memory
mem=$(sudo grep -i memtotal /proc/meminfo | awk '{print $2}')

# calculate 90% of current memory, using 100% will cause instability
fillmem=$(expr $mem / 100 \* 90)

# tmpfs is mounted as 50% by default, remount with our 90% number
echo " ..remounting /dev/shm to use 90% of MemTotal"
sudo mount -o remount,size=$fillmem"k" /dev/shm

# show the current size of tmpfs
df -h | grep tmpfs

# fill that space with 1k block zeros
echo " ..starting memory fill process."
dd if=/dev/zero of=/dev/shm/fill bs=1k
