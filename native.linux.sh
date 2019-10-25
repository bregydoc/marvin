if ! [ -x "$(command -v native-image)" ]; then
  echo 'Installing native-image' >&2
  gu install native-image
fi

native-image -jar target/bin/marvin.jar