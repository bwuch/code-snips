geturl=http://www.example.com/files/tc-160-cli.ova
for i in `seq 1 10`
do
  echo "Downloading ${geturl} for the $i time."
  wget ${geturl} -O /dev/null -q
done
