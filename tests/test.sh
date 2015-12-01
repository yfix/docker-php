#!/bin/bash

name="yfix_test_php"
local_port=39001

docker build -t $name .
docker run -p $local_port:9000 $name -d

apt-get install -y libfcgi0ldbl
SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.1:$local_port

#docker run -it $name bash