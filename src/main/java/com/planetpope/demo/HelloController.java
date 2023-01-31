/*
 * Copyright (c) 2023 This Is a Fake Company, Inc.
 *
 * This is our custom license.
 */

package com.planetpope.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

	@GetMapping("/")
	public String index() {
		return "Hello World stingers!";
	}

}
