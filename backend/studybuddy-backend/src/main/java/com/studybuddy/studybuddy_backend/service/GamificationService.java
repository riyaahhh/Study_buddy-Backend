package com.studybuddy.studybuddy_backend.service;

import com.studybuddy.studybuddy_backend.dto.GamificationResponse;
import com.studybuddy.studybuddy_backend.dto.LeaderboardEntryResponse;
import com.studybuddy.studybuddy_backend.exception.AppException;
import com.studybuddy.studybuddy_backend.model.StudySession;
import com.studybuddy.studybuddy_backend.model.User;
import com.studybuddy.studybuddy_backend.model.XpTransaction;
import com.studybuddy.studybuddy_backend.repository.UserRepository;
import com.studybuddy.studybuddy_backend.repository.XpTransactionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.TemporalAdjusters;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GamificationService {

    public static final String JOINED = "JOINED";
    public static final String CHECKED_IN = "CHECKED_IN";
    public static final String COMPLETED = "COMPLETED";

    private static final int JOIN_XP = 10;
    private static final int CHECK_IN_XP = 15;
    private static final int COMPLETION_XP = 40;
    private static final int STREAK_XP_PER_DAY = 5;

    private final UserRepository userRepository;
    private final XpTransactionRepository xpTransactionRepository;

    @Transactional
    public void awardJoinXp(User user, StudySession session) {
        awardOnce(user, session, JOINED, JOIN_XP);
    }

    @Transactional
    public void awardCheckInXp(User user, StudySession session) {
        LocalDate today = LocalDate.now();
        LocalDate lastStudyDate = user.getLastStudyDate();

        if (today.equals(lastStudyDate)) {
            awardOnce(user, session, CHECKED_IN, CHECK_IN_XP);
            return;
        }

        int streak = today.minusDays(1).equals(lastStudyDate)
                ? valueOrZero(user.getCurrentStreak()) + 1
                : 1;
        user.setCurrentStreak(streak);
        user.setLongestStreak(Math.max(valueOrZero(user.getLongestStreak()), streak));
        user.setLastStudyDate(today);

        awardOnce(
                user,
                session,
                CHECKED_IN,
                CHECK_IN_XP + (streak * STREAK_XP_PER_DAY)
        );
    }

    @Transactional
    public void awardCompletionXp(User user, StudySession session) {
        awardOnce(user, session, COMPLETED, COMPLETION_XP);
    }

    @Transactional(readOnly = true)
    public GamificationResponse getProfile(UUID userId) {
        User user = getUser(userId);
        List<LeaderboardEntryResponse> leaderboard = getCollegeLeaderboard(userId);
        LeaderboardEntryResponse currentEntry = leaderboard.stream()
                .filter(entry -> entry.getUserId().equals(userId))
                .findFirst()
                .orElse(null);

        return GamificationResponse.builder()
                .xp(valueOrZero(user.getXp()))
                .currentStreak(valueOrZero(user.getCurrentStreak()))
                .longestStreak(valueOrZero(user.getLongestStreak()))
                .badges(badgesFor(user))
                .weeklyXp(currentEntry == null ? 0 : currentEntry.getWeeklyXp())
                .weeklyRank(currentEntry == null ? null : currentEntry.getRank())
                .college(user.getCollege())
                .build();
    }

    @Transactional(readOnly = true)
    public List<LeaderboardEntryResponse> getCollegeLeaderboard(UUID userId) {
        User currentUser = getUser(userId);
        String college = currentUser.getCollege();
        if (college == null || college.isBlank()) {
            return List.of();
        }

        LocalDate monday = LocalDate.now()
                .with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDateTime weekStart = LocalDateTime.of(monday, LocalTime.MIN);

        Map<User, Integer> weeklyXpByUser = xpTransactionRepository
                .findByUserCollegeIgnoreCaseAndCreatedAtGreaterThanEqual(
                        college.trim(),
                        weekStart
                )
                .stream()
                .collect(Collectors.groupingBy(
                        XpTransaction::getUser,
                        Collectors.summingInt(XpTransaction::getAmount)
                ));

        List<User> collegeUsers = userRepository
                .findByCollegeIgnoreCaseOrderByXpDesc(college.trim());

        List<User> rankedUsers = collegeUsers.stream()
                .sorted(Comparator
                        .comparingInt((User user) -> weeklyXpByUser.getOrDefault(user, 0))
                        .reversed()
                        .thenComparing(
                                Comparator.comparingInt(
                                        (User user) -> valueOrZero(user.getXp())
                                ).reversed()
                        )
                        .thenComparing(User::getName, String.CASE_INSENSITIVE_ORDER))
                .toList();

        List<LeaderboardEntryResponse> result = new ArrayList<>();
        for (int index = 0; index < rankedUsers.size(); index++) {
            User user = rankedUsers.get(index);
            result.add(LeaderboardEntryResponse.builder()
                    .userId(user.getId())
                    .name(user.getName())
                    .avatarUrl(user.getAvatarUrl())
                    .college(user.getCollege())
                    .weeklyXp(weeklyXpByUser.getOrDefault(user, 0))
                    .totalXp(valueOrZero(user.getXp()))
                    .rank(index + 1)
                    .badges(badgesFor(user))
                    .build());
        }
        return result;
    }

    public List<String> badgesFor(User user) {
        List<String> badges = new ArrayList<>();
        int xp = valueOrZero(user.getXp());
        int completed = valueOrZero(user.getTotalCompleted());

        if (xp >= 100) badges.add("Bronze Scholar");
        if (xp >= 300) badges.add("Silver Scholar");
        if (completed >= 10) badges.add("Placement Warrior");
        return badges;
    }

    private void awardOnce(
            User user,
            StudySession session,
            String eventType,
            int amount
    ) {
        if (xpTransactionRepository.existsByUserIdAndSessionIdAndEventType(
                user.getId(),
                session.getId(),
                eventType
        )) {
            return;
        }

        user.setXp(valueOrZero(user.getXp()) + amount);
        userRepository.save(user);
        xpTransactionRepository.save(XpTransaction.builder()
                .user(user)
                .session(session)
                .eventType(eventType)
                .amount(amount)
                .build());
    }

    private User getUser(UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new AppException(
                        "User not found",
                        HttpStatus.NOT_FOUND
                ));
    }

    private static int valueOrZero(Integer value) {
        return value == null ? 0 : value;
    }
}
