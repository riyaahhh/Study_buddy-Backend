package com.studybuddy.studybuddy_backend.repository;

import com.studybuddy.studybuddy_backend.model.StudySession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SessionRepository extends JpaRepository<StudySession, UUID> {

    // find all sessions by status
    List<StudySession> findByStatus(String status);

    // find all sessions created by a specific user
    List<StudySession> findByHostId(UUID hostId);
}