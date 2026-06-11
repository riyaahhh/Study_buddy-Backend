package com.studybuddy.studybuddy_backend.controller;

import com.studybuddy.studybuddy_backend.dto.GamificationResponse;
import com.studybuddy.studybuddy_backend.dto.LeaderboardEntryResponse;
import com.studybuddy.studybuddy_backend.service.GamificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/gamification")
@RequiredArgsConstructor
public class GamificationController {

    private final GamificationService gamificationService;

    @GetMapping("/me")
    public ResponseEntity<GamificationResponse> getMyGamification(
            Authentication authentication
    ) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(gamificationService.getProfile(userId));
    }

    @GetMapping("/leaderboard")
    public ResponseEntity<List<LeaderboardEntryResponse>> getLeaderboard(
            Authentication authentication
    ) {
        UUID userId = (UUID) authentication.getPrincipal();
        return ResponseEntity.ok(
                gamificationService.getCollegeLeaderboard(userId)
        );
    }
}
