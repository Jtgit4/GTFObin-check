# GTFObin-check
A simple script to automate checking binaries against GTFObins for exploits.

When this script is run it will check the input binaries against GTFObins and return a response of **ENTRY FOUND** or **NO ENTRY FOUND**.

Example Output

```
└─$ ./gtfocheck.sh -r ref.txt            
/usr/bin/yelp ===> ENTRY FOUND https://gtfobins.github.io/gtfobins/yelp/
        ===> Classes:
        ===> Class: file_read
/usr/bin/dmf ===> NO ENTRY FOUND
/usr/bin/whois ===> ENTRY FOUND https://gtfobins.github.io/gtfobins/whois/
        ===> Classes:
        ===> Class: file_upload
        ===> Class: file_download
/usr/bin/rlogin ===> ENTRY FOUND https://gtfobins.github.io/gtfobins/rlogin/
        ===> Classes:
        ===> Class: file_upload
/usr/bin/pkexec ===> ENTRY FOUND https://gtfobins.github.io/gtfobins/pkexec/
        ===> Classes:
        ===> Class: sudo
/usr/bin/mtr ===> ENTRY FOUND https://gtfobins.github.io/gtfobins/mtr/
        ===> Classes:
        ===> Class: file_read
        ===> Class: sudo
/usr/bin/finger ===> ENTRY FOUND https://gtfobins.github.io/gtfobins/finger/
        ===> Classes:
        ===> Class: file_upload
        ===> Class: file_download
/usr/bin/time ===> ENTRY FOUND https://gtfobins.github.io/gtfobins/time/
        ===> Classes:
        ===> Class: shell
        ===> Class: suid
        ===> Class: sudo
/usr/bin/cancel ===> ENTRY FOUND https://gtfobins.github.io/gtfobins/cancel/
        ===> Classes:
        ===> Class: file_upload
```

**Useage**

**-b or --binary** : Used to define a binary or binaries seperated by a comma.

```
./gtfocheck.sh -b time 
```

**-r** : Takes a reference file of binaries and checks each one individually for an entry on GTFObins

```
./gtfocheck.sh -r {reference_file}
```

**-t or --type** : This can be used to specify a type of exploit or exploits your looking for E.g. sudo or file_download

```
./gtfocheck.sh --type sudo,file_download
```
