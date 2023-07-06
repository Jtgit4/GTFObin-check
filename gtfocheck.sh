#!/bin/bash

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -r|--reference)
      reference_file="$2"
      shift
      shift
      ;;
    -t|--type)
      class_types="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z $reference_file ]]; then
  echo "Reference file not specified. Usage: $0 -r <reference_file> [-t <class_types>]"
  exit 1
fi

while IFS= read -r binary_path; do
  binary_name=$(basename "$binary_path")
  formatted_binary_name="${binary_name##*/}"

  url="https://gtfobins.github.io/gtfobins/$formatted_binary_name/"

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

done < "$reference_file"
