cpus=$(grep -ci processor /proc/cpuinfo)
echo "System has $cpus CPUs, starting thread for each."

for i in $( seq 1 $cpus )
do
  echo " ..starting background process #$i to consume CPU."
  sha1sum /dev/zero &
done

echo "You can check processes with 'top' sorting by CPU with 'P'."
echo "To end all processes run 'killall sha1sum'"
