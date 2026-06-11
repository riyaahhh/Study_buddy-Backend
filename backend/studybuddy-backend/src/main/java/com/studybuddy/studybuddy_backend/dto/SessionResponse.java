package com.studybuddy.studybuddy_backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@AllArgsConstructor
public class SessionResponse {
    private UUID id;
    private String title;
    private String subject;
    private String description;
    private UUID hostId;
    private String hostName;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private String locationName;
    private Integer maxMembers;
    private String status;
    private LocalDateTime scheduledAt;
    private LocalDateTime createdAt;
}