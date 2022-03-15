# install/load the busybox-httpd
tce-load -wi busyboxy-httpd

# Write a basic web page that includes the systems IP address
echo '<center><h1>Test Web Server</h1></center> <p> <center><h2>IP Address: ' | sudo tee /usr/local/httpd/bin/index.html
ifconfig eth0 | grep 'inet addr' | awk -F ":" '{print $2}' | awk -F ' ' '{print $1}' | sudo tee -a /usr/local/httpd/bin/index.html
echo '</center></h2>' | sudo tee -a /usr/local/httpd/bin/index.html

# Start the busybox httpd service on port 80 to server up the above page
sudo /usr/local/httpd/bin/busybox httpd -p 80 -h /usr/local/httpd/bin
