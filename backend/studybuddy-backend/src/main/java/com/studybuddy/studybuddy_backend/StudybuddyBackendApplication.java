package com.studybuddy.studybuddy_backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = "com.studybuddy.studybuddy_backend")
public class StudybuddyBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(StudybuddyBackendApplication.class, args);
	}

}