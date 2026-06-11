package com.studybuddy.studybuddy_backend.repository;

import com.studybuddy.studybuddy_backend.model.SessionParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ParticipantRepository extends JpaRepository<SessionParticipant, UUID> {

    // check if user already joined this session
    boolean existsBySessionIdAndUserId(UUID sessionId, UUID userId);

    // get all participants of a session
    List<SessionParticipant> findBySessionId(UUID sessionId);

    // find specific participant record (for leaving)
    Optional<SessionParticipant> findBySessionIdAndUserId(UUID sessionId, UUID userId);

    // count participants in a session
    int countBySessionId(UUID sessionId);
    List<SessionParticipant> findByUserId(UUID userId);
    // count sessions user has completed
int countByUserIdAndCompleted(UUID userId, Boolean completed);

// count all sessions user has joined
int countByUserId(UUID userId);
}