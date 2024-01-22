## POSTFIX SMTP RELAYHOST

Open your postfix configuration file using your favorite vi editor.

```sh
vi /etc/postfix/main.cf
```

Paste following code at the end of file.

```sh
smtp-amavis_destination_recipient_limit = 1
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = ***
smtp_sasl_security_options = noanonymous
smtp_tls_security_level = may
header_size_limit = 4096000
relayhost = [smtp.socketlabs.com]:2525
relay_destination_concurrency_limit = 10
```

#### References
* https://docs.iredmail.org/relayhost.html
* https://www.linuxbabe.com/mail-server/debian-10-buster-iredmail-email-server




