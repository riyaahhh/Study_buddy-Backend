package com.studybuddy.studybuddy_backend.controller;

import com.studybuddy.studybuddy_backend.dto.UpdateProfileRequest;
import com.studybuddy.studybuddy_backend.dto.UserResponse;
import com.studybuddy.studybuddy_backend.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.RequestParam;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getMyProfile(Authentication authentication) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(userService.getMyProfile(userId));
    }

    @PutMapping("/me")
    public ResponseEntity<UserResponse> updateMyProfile(
            Authentication authentication,
            @RequestBody UpdateProfileRequest request) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(userService.updateMyProfile(userId, request));
    }
    @GetMapping("/nearby")
public ResponseEntity<List<UserResponse>> getNearbyUsers(
        Authentication authentication,
        @RequestParam double lat,
        @RequestParam double lng,
        @RequestParam(defaultValue = "5") double radius) {
    UUID userId = (UUID) authentication.getPrincipal();
    return ResponseEntity.ok(userService.getNearbyUsers(userId, lat, lng, radius));
}
}