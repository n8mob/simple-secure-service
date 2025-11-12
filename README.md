SIMPLE SECURE SERVICE (AND CLIENT)
=================================================

A simple application for testing certificates in Spring Java services.

A simple web service is implemented directly in [EchoController.java](src/main/java/com/nategrigg/demo/simplesecure/service/EchoController.java) that
returns the first few parameters sent to it.
To verify liveness, it sets the "Cache-Control" HTTP header to "no-cache" and also returns `java.time.Instant.now()` in a property named "timestamp".

## Running the Service
The primary configuration option is under server.ssl.key-*

You can see the default configuration in [application.yaml](src/main/resources/application.yaml):

For testing, I override `server.ssl.key-store` in application-local.yaml.
I set it to the fully qualified path of a keystore file so I can change out that file
and simply restart the service without any rebuild step.

```yaml
server:
  port: 8443
  ssl:
    key-store: file:/Users/nategrigg/code/me/simple-secure-service/src/main/scripts/simplesecure/keystore.p12
    key-store-password: changeit
    key-store-type: PKCS12
    key-alias: simplesecure
```

## make-cert-bundle.zsh
A script to generate 3 certificates: root, intermediate, and leaf.
"leaf" is the server certificate, "intermediate" issues/signs the leaf, and "root" issues/signs the intermediate.

This allows testing of certificate chains in various combinations such as the server supplying:
- leaf only
- leaf + intermediate
- leaf + intermediate + root

And then you can build the trust store for the client with:
- root only
- intermediate only
- root + intermediate
- etc.

## setting trust store on client side
In [SimpleSecureClient.java](src/main/java/com/nategrigg/demo/simplesecure/client/SimpleSecureClient.java), rather than messing with application.properties (or .yaml in this case), I set the trust store with -Djavax.net.ssl.trustStore=/path/to/truststore.p12

### IntelliJ Run Configurations
I added two run configurations in IntelliJ for easy testing:
- SimpleSecureService - runs the service
- SimpleSecureClient - runs the client against the service
