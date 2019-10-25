ballerina build -o marvin.jar main.bal

docker run -v $PWD:/root/ oracle/graalvm-ce:19.2.1 bash /root/native.linux.sh