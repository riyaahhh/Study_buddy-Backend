package com.studybuddy.studybuddy_backend.repository;

import com.studybuddy.studybuddy_backend.model.XpTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface XpTransactionRepository extends JpaRepository<XpTransaction, UUID> {

    boolean existsByUserIdAndSessionIdAndEventType(
            UUID userId,
            UUID sessionId,
            String eventType
    );

    List<XpTransaction> findByUserCollegeIgnoreCaseAndCreatedAtGreaterThanEqual(
            String college,
            LocalDateTime start
    );
}
