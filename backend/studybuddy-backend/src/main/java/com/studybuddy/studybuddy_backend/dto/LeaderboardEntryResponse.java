package com.studybuddy.studybuddy_backend.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.UUID;

@Data
@Builder
public class LeaderboardEntryResponse {
    private UUID userId;
    private String name;
    private String avatarUrl;
    private String college;
    private Integer weeklyXp;
    private Integer totalXp;
    private Integer rank;
    private List<String> badges;
}
