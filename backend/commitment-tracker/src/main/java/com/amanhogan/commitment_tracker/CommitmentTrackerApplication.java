package com.amanhogan.commitment_tracker;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
public class CommitmentTrackerApplication {

	public static void main(String[] args) {
		SpringApplication.run(CommitmentTrackerApplication.class, args);
	}

	@GetMapping("/")
	String defaultHomePage(){
		return "Hello World";
	}
}
