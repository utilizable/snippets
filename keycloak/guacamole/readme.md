# SSO - Keycloak + Apache Guacamole

Guacamole saml with keycloak idp.

## Table of Contents

1. [Keycloak Configuration](#keycloak)
2. [Guacamole Configuration](#Guacamole)

## Keycloak

Log in to the keycloak administration console and navigate to the clients panel.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_0.png" align="center">

Press create button.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_1.png" align="center">

Download <a href="https://github.com/igor-sadza/JakCo/blob/c3a4afd0867d99b210ea5427b036aac32f1c2880/sso/keycloak_guacamole/client.json"><strong>example client</strong></a> from this repo and press select file.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_2.png" align="center">

Navigate to download dir and select proper json file.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_3.png" align="center">

Press save.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_4.png" align="center">

Check if everything is correct.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_5.png" align="center">

Go to users panel.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_6.png" align="center">

Press add user.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_7.png" align="center">

Create user.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_8.png" align="center">

Go to credentials.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_9.png" align="center">

Setup password and verify it.

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_10.png" align="center">

Set user password and go to attributes panel.

<img src="https://github.com/igor-sadza/JakCo/blob/acf7030ed4f3350e2eb15af4ab93d89c364ab92e/sso/keycloak_guacamole/img/keycloak_guacamole_12.png" align="center">

Add name

| Key | Value |
| ------ | ------ |
saml.persistent.name.id.for.https://guacamole.YOUR-DOMAIN-NAME | YOUR-GUACAMOLE-USER-NAME

<img src="https://github.com/igor-sadza/JakCo/blob/21116c622f45511d75db008e9746c33eec4ba818/sso/keycloak_guacamole/img/keycloak_guacamole_11.png" align="center">


## Guacamole

Log in to your keycloak machine. 

Go to guacamole conf directory.

```sh
    cd /etc/guacamole 
```

Copy metadata link from keycloak admin page.

<img src="https://github.com/igor-sadza/JakCo/blob/74ff3497900190811ee770bfe531c4c0db0b2cec/sso/keycloak_sogo/img/19_ip_metadata.png" align="center">

Download metadata.

```sh
     wget -O metadata.xml https://YOUR-KEYCLOAK-INSTANCE/auth/realms/keycloak_sogo/protocol/saml/descriptor
```

Edit guacamole configuration file.

```sh
     vi /etc/guacamole/guacamole.properties
```

```sh
saml-idp-metadata-url: file:///etc/guacamole/guacamole.xml
saml-entity-id: https://YOUR-GUACAMOLE-INSTANCE
saml-callback-url: https://YOUR-GUACAMOLE-INSTANCE
saml-debug: true
saml-strict: true
```

Restart your Guacamole & Tomcat instances.

```sh
     systemctl restart tomcat9.service && systemctl restart guacd
```

Tomcat9 logs

```sh
     cat /var/log/tomcat9/catalina.out
```

Go to your guacamole webpage and login using keycloak credentials.

<img src="https://github.com/igor-sadza/JakCo/blob/74ff3497900190811ee770bfe531c4c0db0b2cec/sso/keycloak_sogo/img/18_login.png" align="center">




