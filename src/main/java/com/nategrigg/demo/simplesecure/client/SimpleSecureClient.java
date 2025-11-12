package com.nategrigg.demo.simplesecure.client;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.http.HttpClient;
import java.security.NoSuchAlgorithmException;
import javax.net.ssl.SSLContext;

public class SimpleSecureClient {
  public static void main(String[] args)
  throws NoSuchAlgorithmException, URISyntaxException, IOException, InterruptedException {
    System.out.println("Hello, World!");
    var sslContext = SSLContext.getDefault();
    System.out.println("Default SSL Context: " + sslContext.getProtocol());

    try (var client = HttpClient.newHttpClient()) {
      var response = client.send(
          java.net.http.HttpRequest.newBuilder()
              .uri(new URI("https://localhost:8443/echo?message=HelloWorld"))
              .GET()
              .build(),
          java.net.http.HttpResponse.BodyHandlers.ofString()
      );

      System.out.println("Response status code: " + response.statusCode());
      System.out.println("Response body: " + response.body());
    }
  }
}