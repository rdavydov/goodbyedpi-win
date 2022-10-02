### HTTP

HTTP could be circumvented with `hoSt` header.

### HTTPS

HTTPS could be circumvented by adding dot at the end of SNI or by sending fake SNI. Connections without SNI to filtered IP addresses are getting analyzed by active DPI and get blocked after **Server**Hello.

Changing case in SNI does not help.