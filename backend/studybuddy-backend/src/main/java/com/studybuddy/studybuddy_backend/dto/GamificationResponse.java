package com.studybuddy.studybuddy_backend.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GamificationResponse {
    private Integer xp;
    private Integer currentStreak;
    private Integer longestStreak;
    private List<String> badges;
    private Integer weeklyXp;
    private Integer weeklyRank;
    private String college;
}
