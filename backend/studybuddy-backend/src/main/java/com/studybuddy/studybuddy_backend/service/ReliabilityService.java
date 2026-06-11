package com.studybuddy.studybuddy_backend.service;

import com.studybuddy.studybuddy_backend.exception.AppException;
import com.studybuddy.studybuddy_backend.model.SessionParticipant;
import com.studybuddy.studybuddy_backend.model.User;
import com.studybuddy.studybuddy_backend.repository.ParticipantRepository;
import com.studybuddy.studybuddy_backend.repository.SessionRepository;
import com.studybuddy.studybuddy_backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ReliabilityService {

    private final ParticipantRepository participantRepository;
    private final UserRepository userRepository;
    private final SessionRepository sessionRepository;
    private final GamificationService gamificationService;

    // called when user checks into a session
    public String checkIn(UUID sessionId, UUID userId) {

        SessionParticipant participant = participantRepository
                .findBySessionIdAndUserId(sessionId, userId)
                .orElseThrow(() -> new AppException(
                        "You must join the session first", HttpStatus.BAD_REQUEST));

        if (participant.getCheckedInAt() != null) {
            throw new AppException("Already checked in", HttpStatus.CONFLICT);
        }

        participant.setCheckedInAt(LocalDateTime.now());
        participantRepository.save(participant);
        gamificationService.awardCheckInXp(participant.getUser(), participant.getSession());

        return "Checked in successfully!";
    }

    // called when user marks session as completed
    public String completeSession(UUID sessionId, UUID userId) {

        SessionParticipant participant = participantRepository
                .findBySessionIdAndUserId(sessionId, userId)
                .orElseThrow(() -> new AppException(
                        "You are not a participant", HttpStatus.BAD_REQUEST));

        if (Boolean.TRUE.equals(participant.getCompleted())) {
            throw new AppException("Session already marked as completed", HttpStatus.CONFLICT);
        }

        // mark as completed
        participant.setCompleted(true);
        participantRepository.save(participant);

        // recalculate reliability score
        recalculateReliability(userId);
        gamificationService.awardCompletionXp(
                participant.getUser(),
                participant.getSession()
        );

        return "Session marked as completed!";
    }

    // recalculate and save reliability score
    public void recalculateReliability(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException("User not found", HttpStatus.NOT_FOUND));

        int totalJoined = participantRepository.countByUserId(userId);
        int totalCompleted = participantRepository.countByUserIdAndCompleted(userId, true);

        // calculate score — avoid division by zero
        BigDecimal score = BigDecimal.ZERO;
        if (totalJoined > 0) {
            score = BigDecimal.valueOf(totalCompleted)
                    .divide(BigDecimal.valueOf(totalJoined), 4, RoundingMode.HALF_UP)
                    .multiply(BigDecimal.valueOf(100))
                    .setScale(1, RoundingMode.HALF_UP);
        }

        user.setTotalJoined(totalJoined);
        user.setTotalCompleted(totalCompleted);
        user.setReliabilityScore(score);
        userRepository.save(user);
    }
}
