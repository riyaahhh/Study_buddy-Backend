package com.studybuddy.studybuddy_backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class CreateSessionRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String subject;
    private String description;

    private BigDecimal latitude;
    private BigDecimal longitude;
    private String locationName;
    private Integer maxMembers;

    @NotNull(message = "Scheduled time is required")
    private LocalDateTime scheduledAt;
}