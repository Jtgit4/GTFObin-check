#!/bin/bash

reference_file=""
target_binaries=""

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -r|--reference)
      reference_file="$2"
      shift
      shift
      ;;
    -b|--binary)
      target_binaries="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z $reference_file && -z $target_binaries ]]; then
  echo "No reference file or target binaries specified. Usage: $0 [-r <reference_file>] [-b <target_binaries>]"
  exit 1
fi

if [[ -n $reference_file && ! -f $reference_file ]]; then
  echo "Reference file '$reference_file' does not exist or is not a regular file."
  exit 1
fi

if [[ -n $target_binaries ]]; then
  IFS=',' read -ra binaries <<< "$target_binaries"
else
  mapfile -t binaries < "$reference_file"
fi

for binary in "${binaries[@]}"; do
  binary_path="/usr/bin/$binary"

  url="https://gtfobins.github.io/gtfobins/$binary/"

  if curl --head --silent --fail "$url" >/dev/null; then
    echo "$binary_path ===> ENTRY FOUND $url"

    h2_classes=$(curl -s "$url" | grep -oP '(?<=<h2 id=")[^"]+' | sed 's/-/_/g')

    if [[ -n $class_types ]]; then
      filtered_classes=""
      for class_type in $(echo "$class_types" | sed 's/,/ /g'); do
        filtered_classes+=$(echo -e "$h2_classes" | grep -w "$class_type" | sed 's/^/\t===> Class: /')
        filtered_classes+="\n"
      done
      echo -e "$filtered_classes"
    else
      echo -e "\t===> Classes:\n$(echo -e "$h2_classes" | sed 's/^/\t===> Class: /')"
    fi

  else
    echo "$binary_path ===> NO ENTRY FOUND"
  fi

done
