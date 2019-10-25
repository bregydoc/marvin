export GRAALVM_HOME=/Users/bregy/Downloads/graalvm-ce-19.2.1/Contents/Home

$GRAALVM_HOME/bin/native-image -H:+ReportExceptionStackTraces -jar target/bin/marvin.jar
