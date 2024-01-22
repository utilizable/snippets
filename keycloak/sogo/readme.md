# SSO - Keycloak + SOGo

I am preparing this HOW-TO for all those who want to use saml with SOGo.

## Table of Contents

1. [Keycloak Configuration](#keycloak)
2. [SOGo Configuration](#sogo)

## Keycloak

Log in to the keycloak administration console and navigate to the clients panel.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/0_clients.png" align="center">

Press create button.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/1_create_client.png" align="center">

Open a web browser, navigate to the sogo metadata page and save it.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/4_metadata.png" align="center">

Go back to keycloak page and press select file.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/2_import.png" align="center">

Apply your sogo xml.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/5_select.png" align="center">

Save your imported client.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/6_save.png" align="center">

Go to the client mappers tab.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/7_mappers.png" align="center">

Press create.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/8_create_mapper.png" align="center">

Create the mail mapper.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/9_email_mapper.png" align="center">

Create a username mapper.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/10_username_mapper.png" align="center">

Go to users tab.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/11_users.png" align="center">

Press add user

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/12_add_user.png" align="center">

Save the newly created user.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/13_save_created_user.png" align="center">.

Navigate to user attributes.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/14_user_attributes.png" align="center">.

Create an email attribute, remeber to use valid sogo account mail!

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/15_save_attributes.png" align="center">

Navigate to the user's credentials.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/16_user_credentials.png" align="center">

Set the user's password.

<img src="https://github.com/igor-sadza/JakCo/blob/5147a7b527df4d6af8e3f277072e4e6d7fc91f44/sso/keycloak_sogo/img/17_set_password.png" align="center">

## SOGo

Log in to your sogo machine. 

Go to sogo conf directory.

```sh
    cd /etc/sogo 
```
Generate ssl certs.

```sh
     openssl req -newkey rsa:3072 -new -x509 -days 3652 -nodes -out saml.crt -keyout saml.pem
```

Copy metadata link from keycloak admin page.

<img src="https://github.com/igor-sadza/JakCo/blob/74ff3497900190811ee770bfe531c4c0db0b2cec/sso/keycloak_sogo/img/19_ip_metadata.png" align="center">

Download metadata.

```sh
     wget -O metadata.xml https://YOUR-KEYCLOAK-INSTANCE/auth/realms/keycloak_sogo/protocol/saml/descriptor
```

Edit sogo configuration file.

```sh
     vi /etc/sogo/sogo.conf
```

```sh
    SOGoAuthenticationType = saml2;
    // Generate by openssl
    SOGoSAML2PrivateKeyLocation = /etc/sogo/test/saml.pem;
    SOGoSAML2CertificateLocation = /etc/sogo/test/saml.crt;
    // Keycloak metadata
    SOGoSAML2IdpMetadataLocation = /etc/sogo/metadata.xml;
    SOGoSAML2LoginAttribute = username;
    SOGoSAML2LogoutEnabled = YES;
    SOGoSAML2LogoutURL = https://YOUR-SOGO-WEBPAGE/;
```

Restart your sogo instance.

```sh
     /etc/init.d/sogo restart
```

Sogo logs

```sh
     cat /var/log/sogo/sogo.log
```

Go to your sogo webpage and login using keycloak credentials.

<img src="https://github.com/igor-sadza/JakCo/blob/74ff3497900190811ee770bfe531c4c0db0b2cec/sso/keycloak_sogo/img/18_login.png" align="center">




