<!-- ABOUT THE PROJECT -->
## Bitwarden Mail Settings

Mail settings for bitwarden self hosted service.

### Configuration

Open global.override.env
```sh
vi ~/bwdata/env/global.override.env
```
Paste this at the end of the file (Don't forget to modify!)
```sh
globalSettings__mail__replyToEmail=no-reply@YOUR-DOMAIN
globalSettings__mail__smtp__host=YOUR-DOMAIN
globalSettings__mail__smtp__username=VALID-USERNAME
globalSettings__mail__smtp__password=VALID-PASSWORD
globalSettings__mail__smtp__ssl=false
globalSettings__mail__smtp__port=587
globalSettings__mail__smtp__useDefaultCredentials=false
globalSettings__mail__smtp__authType=Negotiate
globalSettings__mail__smtp__trustServer=true
```


