package com.telmore.hazelcastembedded;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class HazelcastEmbeddedApplication {

	public static void main(String[] args) {
		SpringApplication.run(HazelcastEmbeddedApplication.class, args);
	}

}
