package com.studybuddy.studybuddy_backend.controller;

import com.studybuddy.studybuddy_backend.service.ReliabilityService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/sessions")
@RequiredArgsConstructor
public class ReliabilityController {

    private final ReliabilityService reliabilityService;

    // check into a session
    @PostMapping("/{id}/checkin")
    public ResponseEntity<String> checkIn(
            Authentication authentication,
            @PathVariable UUID id) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(reliabilityService.checkIn(id, userId));
    }

    // mark session as completed
    @PostMapping("/{id}/complete")
    public ResponseEntity<String> completeSession(
            Authentication authentication,
            @PathVariable UUID id) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(reliabilityService.completeSession(id, userId));
    }
}