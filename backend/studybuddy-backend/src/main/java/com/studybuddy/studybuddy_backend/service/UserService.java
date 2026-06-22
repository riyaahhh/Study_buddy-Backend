package com.studybuddy.studybuddy_backend.service;

import com.studybuddy.studybuddy_backend.dto.UpdateProfileRequest;
import com.studybuddy.studybuddy_backend.dto.UserResponse;
import com.studybuddy.studybuddy_backend.exception.AppException;
import com.studybuddy.studybuddy_backend.model.User;
import com.studybuddy.studybuddy_backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public UserResponse getMyProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(
                        "Your session is no longer valid. Please sign in again.",
                        HttpStatus.UNAUTHORIZED));
        return mapToResponse(user);
    }

    public UserResponse updateMyProfile(UUID userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(
                        "Your session is no longer valid. Please sign in again.",
                        HttpStatus.UNAUTHORIZED));

        if (request.getName() != null) user.setName(request.getName());
        if (request.getBio() != null) user.setBio(request.getBio());
        if (request.getSubjects() != null) user.setSubjects(request.getSubjects());
        if (request.getLatitude() != null) user.setLatitude(request.getLatitude());
        if (request.getLongitude() != null) user.setLongitude(request.getLongitude());
        if (request.getAvatarUrl() != null) user.setAvatarUrl(request.getAvatarUrl());
        if (request.getCollege() != null) {
            user.setCollege(request.getCollege().trim());
        }

        User saved = userRepository.save(user);
        return mapToResponse(saved);
    }

    public List<UserResponse> getNearbyUsers(UUID userId, double lat, double lng, double radius) {
        return userRepository.findNearbyUsers(lat, lng, radius, userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private UserResponse mapToResponse(User user) {
    return UserResponse.builder()
            .id(user.getId())
            .name(user.getName())
            .email(user.getEmail())
            .bio(user.getBio())
            .subjects(user.getSubjects())
            .latitude(user.getLatitude())
            .longitude(user.getLongitude())
            .avatarUrl(user.getAvatarUrl())
            .reliabilityScore(user.getReliabilityScore())
            .totalJoined(user.getTotalJoined())
            .totalCompleted(user.getTotalCompleted())
            .college(user.getCollege())
            .xp(user.getXp())
            .currentStreak(user.getCurrentStreak())
            .longestStreak(user.getLongestStreak())
            .lastStudyDate(user.getLastStudyDate())
            .build();
}
}
