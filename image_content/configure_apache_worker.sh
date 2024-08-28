sed -i 's/.*KeepAliveTimeout.*/KeepAliveTimeout 3/'  /etc/httpd/conf/httpd.conf

# Configure worker mpm
sed -i '/<IfModule worker.c>/,/<\/IfModule>/c\
<IfModule worker.c>\
      ThreadLimit         32\
      ServerLimit         8\
      StartServers        8\
      MinSpareThreads     256\
      MaxSpareThreads     256\
      MaxRequestWorkers   256\
      ThreadsPerChild     32\
      MaxRequestsPerChild 0\
</IfModule>' /etc/httpd/conf/httpd.conf



