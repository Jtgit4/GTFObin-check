#!/bin/bash

display_help() {
  echo "Usage: $0 [-r <reference_file>] [-b <target_binaries>] [-t <target_classes>] [-h]"
  echo "Options:"
  echo "  -r, --reference    Specify the reference file of binaries to check individually"
  echo "  -b, --binary       Define a binary or binaries separated by a comma"
  echo "  -t, --type         Specify the type of exploit(s) you are looking for e.g. sudo"
  echo "  -h, --help         Display this help message"
  exit 0
}

reference_file=""
target_binaries=""
target_classes=""

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
    -t|--type)
      target_classes="$2"
      shift
      shift
      ;;
    -h|--help)
      display_help
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z $reference_file && -z $target_binaries ]]; then
  display_help
fi

if [[ -z $reference_file && -z $target_binaries ]]; then
  echo "No reference file or target binaries specified. Usage: $0 [-r <reference_file>] [-b <target_binaries>] [-t <target_classes>]"
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

  if [[ -z $reference_file && -z $target_binaries ]]; then
    if [[ ! -x $binary_path ]]; then
      echo "Binary '$binary' does not exist or is not executable."
      continue
    fi
  fi

  url="https://gtfobins.github.io/gtfobins/$binary/"

  if curl --head --silent --fail "$url" >/dev/null; then
    echo "$binary_path ===> ENTRY FOUND $url"

    if [[ -n $target_classes ]]; then
      h2_classes=$(curl -s "$url" | grep -oP '(?<=<h2 id=")[^"]+' | sed 's/-/_/g')
      filtered_classes=""
      for class_type in $(echo "$target_classes" | sed 's/,/ /g'); do
        filtered_classes+=$(echo -e "$h2_classes" | grep -w "$class_type" | sed 's/^/\t===> Class: /')
        filtered_classes+="\n"
      done
      if [[ -n $filtered_classes ]]; then
        echo -e "$filtered_classes"
      fi
    else
      h2_classes=$(curl -s "$url" | grep -oP '(?<=<h2 id=")[^"]+' | sed 's/-/_/g')
      if [[ -n $h2_classes ]]; then
        echo -e "\t===> Classes:\n$(echo -e "$h2_classes" | sed 's/^/\t===> Class: /')"
      fi
    fi

  else
    echo "$binary_path ===> NO ENTRY FOUND"
  fi

done
