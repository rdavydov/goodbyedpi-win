To dump network traffic with Wireshark on Windows, do the following steps:

1. Download and install [Wireshark](https://www.wireshark.org/). You need to get full version, portable won't work.
2. Determine IP address of blocked website with `nslookup [site domain]` command. Run it in command prompt.
3. Choose network interface in Wireshark, type into "…using this filter" string in a format:
`host [IP address]`
4. If there's more than one IP address on the domain, join them with "or" word:
`host [IP address 1] or [IP address 2]`
Press enter to start traffic capture process.
5. Go to the blocked website over HTTP and HTTPS.
6. Stop traffic capture using a button with red square picture on top panel. Press file → save as to save data file.
7. Send it to iam@valdikss.org.ru

Perform these steps twice, with GoodbyeDPI and without it.