package com.studybuddy.studybuddy_backend.service;

import com.studybuddy.studybuddy_backend.dto.CreateSessionRequest;
import com.studybuddy.studybuddy_backend.dto.ParticipantResponse;
import com.studybuddy.studybuddy_backend.dto.SessionResponse;
import com.studybuddy.studybuddy_backend.exception.AppException;
import com.studybuddy.studybuddy_backend.model.SessionParticipant;
import com.studybuddy.studybuddy_backend.model.StudySession;
import com.studybuddy.studybuddy_backend.model.User;
import com.studybuddy.studybuddy_backend.repository.ParticipantRepository;
import com.studybuddy.studybuddy_backend.repository.SessionRepository;
import com.studybuddy.studybuddy_backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
@RequiredArgsConstructor
public class SessionService {

    private final SessionRepository sessionRepository;
    private final UserRepository userRepository;
    private final ParticipantRepository participantRepository;
    private final GamificationService gamificationService;

    public SessionResponse createSession(UUID hostId, CreateSessionRequest request) {
        User host = userRepository.findById(hostId)
                .orElseThrow(() -> new AppException("User not found", HttpStatus.NOT_FOUND));

        StudySession session = StudySession.builder()
                .title(request.getTitle())
                .subject(request.getSubject())
                .description(request.getDescription())
                .host(host)
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .locationName(request.getLocationName())
                .maxMembers(request.getMaxMembers() != null ? request.getMaxMembers() : 10)
                .status("upcoming")
                .scheduledAt(request.getScheduledAt())
                .build();

        StudySession saved = sessionRepository.save(session);
        return mapToResponse(saved);
    }

    public List<SessionResponse> getAllSessions() {
        return sessionRepository.findByStatus("upcoming")
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public SessionResponse getSessionById(UUID sessionId) {
        StudySession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new AppException("Session not found", HttpStatus.NOT_FOUND));
        return mapToResponse(session);
    }

    public String joinSession(UUID sessionId, UUID userId) {
        StudySession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new AppException("Session not found", HttpStatus.NOT_FOUND));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException("User not found", HttpStatus.NOT_FOUND));

        if (participantRepository.existsBySessionIdAndUserId(sessionId, userId)) {
            throw new AppException("You have already joined this session", HttpStatus.CONFLICT);
        }

        int currentCount = participantRepository.countBySessionId(sessionId);
        if (currentCount >= session.getMaxMembers()) {
            throw new AppException("Session is full", HttpStatus.BAD_REQUEST);
        }

        SessionParticipant participant = SessionParticipant.builder()
                .session(session)
                .user(user)
                .role("member")
                .build();

        participantRepository.save(participant);
        gamificationService.awardJoinXp(user, session);
        return "Successfully joined the session";
    }

    public String leaveSession(UUID sessionId, UUID userId) {
        SessionParticipant participant = participantRepository
                .findBySessionIdAndUserId(sessionId, userId)
                .orElseThrow(() -> new AppException("You are not a participant of this session", HttpStatus.BAD_REQUEST));

        participantRepository.delete(participant);
        return "Successfully left the session";
    }

    public List<ParticipantResponse> getParticipants(UUID sessionId) {
        sessionRepository.findById(sessionId)
                .orElseThrow(() -> new AppException("Session not found", HttpStatus.NOT_FOUND));

        return participantRepository.findBySessionId(sessionId)
                .stream()
                .map(p -> ParticipantResponse.builder()
                        .userId(p.getUser().getId())
                        .name(p.getUser().getName())
                        .email(p.getUser().getEmail())
                        .role(p.getRole())
                        .joinedAt(p.getJoinedAt())
                        .build())
                .collect(Collectors.toList());
    }

    public List<SessionResponse> getMySessions(UUID userId) {
        List<StudySession> hosted = sessionRepository.findByHostId(userId);

        List<StudySession> joined = participantRepository.findByUserId(userId)
                .stream()
                .map(SessionParticipant::getSession)
                .collect(Collectors.toList());

        return Stream.concat(hosted.stream(), joined.stream())
                .distinct()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private SessionResponse mapToResponse(StudySession session) {
        return SessionResponse.builder()
                .id(session.getId())
                .title(session.getTitle())
                .subject(session.getSubject())
                .description(session.getDescription())
                .hostId(session.getHost().getId())
                .hostName(session.getHost().getName())
                .latitude(session.getLatitude())
                .longitude(session.getLongitude())
                .locationName(session.getLocationName())
                .maxMembers(session.getMaxMembers())
                .status(session.getStatus())
                .scheduledAt(session.getScheduledAt())
                .createdAt(session.getCreatedAt())
                .build();
    }
}
