#!/usr/bin/env python3

import requests
from bs4 import BeautifulSoup
import argparse
import sys
import os

def display_help():
    print("Usage: script.py [-r <reference_file>] [-b <target_binaries>] [-t <target_classes>] [-n] [-h]")
    print("Options:")
    print("  -r, --reference    Specify the reference file of binaries to check individually")
    print("  -b, --binary       Define a binary or binaries separated by a comma")
    print("  -t, --type         Specify the type of exploit(s) you are looking for e.g. sudo")
    print("  -n, --no-output    Suppress detailed output, only show binary name and whether an entry was found")
    print("  -h, --help         Display this help message")
    sys.exit(0)

def get_page(url):
    response = requests.get(url)
    if response.status_code == 404:
        return None
    return BeautifulSoup(response.text, 'html.parser')

def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('-r', '--reference')
    parser.add_argument('-b', '--binary')
    parser.add_argument('-t', '--type')
    parser.add_argument('-n', '--no-output', action='store_true')
    parser.add_argument('-h', '--help', action='store_true')
    args = parser.parse_args()

    if args.help:
        display_help()

    if not args.reference and not args.binary:
        display_help()

    if args.reference and not os.path.isfile(args.reference):
        print(f"Reference file '{args.reference}' does not exist or is not a regular file.")
        sys.exit(1)

    binaries = args.binary.split(',') if args.binary else open(args.reference).read().splitlines()

    for binary in binaries:
        url = f"https://gtfobins.github.io/gtfobins/{binary}/"

        try:
            soup = get_page(url)
            if soup is None:
                print(f"\033[31m========================================")
                print(f"Binary: {binary}")
                print(f"NO BINARY ENTRY FOUND")
                print(f"========================================\033[0m")
                continue

            print(f"\033[34m========================================")
            print(f"Binary: {binary}")
            print(f"URL: {url}")
            print(f"========================================\033[0m")

            if args.no_output:
                h2_classes = [h2.get('id') for h2 in soup.find_all('h2')]
                if h2_classes:
                    print("        ===> Classes:")
                    for class_name in h2_classes:
                        print(f"        ===> Class: {class_name}")
                continue

            for h2 in soup.find_all('h2'):
                class_name = h2.get('id')
                description = h2.find_next_sibling('p').text
                code_example_element = h2.find_next('pre')
                code_example = code_example_element.text if code_example_element else "No code example found"

                if args.type and class_name not in args.type.split(','):
                    continue

                print(f"\033[1m\033[32mClass: {class_name}\033[0m")
                print(f"\033[0m----------------------------------------")
                print(f"\033[1mDescription:\033[0m\n\n{description}\n")
                print(f"\033[1m\033[31mCODE EXECUTION EXAMPLE:\033[0m\n\n{code_example}")
                print(f"----------------------------------------\033[0m")

        except requests.exceptions.RequestException:
            print(f"{binary} ===> NO ENTRY FOUND")

if __name__ == "__main__":
    main()
