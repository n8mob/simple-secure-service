package com.nategrigg.demo.simplesecure.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
public class EchoController {

    @Value("${app.echo.max-params:10}")
    private int maxParams;

    @GetMapping("/echo")
    public ResponseEntity<Map<String, Object>> echo(@RequestParam Map<String, String> params) {
        Map<String, Object> response = new LinkedHashMap<>();
        int count = 0;
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (count >= maxParams) break;
            response.put(entry.getKey(), entry.getValue());
            count++;
        }
        response.put("timestamp", Instant.now().toString());

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CACHE_CONTROL, "no-cache");

        return ResponseEntity.ok().headers(headers).body(response);
    }
}
