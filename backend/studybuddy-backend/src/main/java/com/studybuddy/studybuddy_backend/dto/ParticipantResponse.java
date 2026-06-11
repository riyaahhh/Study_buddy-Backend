package com.studybuddy.studybuddy_backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@AllArgsConstructor
public class ParticipantResponse {
    private UUID userId;
    private String name;
    private String email;
    private String role;
    private LocalDateTime joinedAt;
}