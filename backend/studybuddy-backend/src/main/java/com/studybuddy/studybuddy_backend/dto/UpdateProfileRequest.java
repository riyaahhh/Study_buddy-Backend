package com.studybuddy.studybuddy_backend.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class UpdateProfileRequest {
    private String name;
    private String bio;
    private List<String> subjects;
    private BigDecimal latitude;
    private BigDecimal longitude;
    private String avatarUrl;
    private String college;
}
