package com.studybuddy.studybuddy_backend.repository;

import com.studybuddy.studybuddy_backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByCollegeIgnoreCaseOrderByXpDesc(String college);

    // Haversine formula — finds users within radius km
@Query(value = """
    SELECT * FROM (
        SELECT *, (
            6371 * acos(
                LEAST(1.0, GREATEST(-1.0,
                    cos(radians(:lat)) *
                    cos(radians(latitude)) *
                    cos(radians(longitude) - radians(:lng)) +
                    sin(radians(:lat)) *
                    sin(radians(latitude))
                ))
            )
        ) AS distance
        FROM users
        WHERE CAST(id AS text) != CAST(:userId AS text)
        AND latitude IS NOT NULL
        AND longitude IS NOT NULL
    ) AS users_with_distance
    WHERE distance < :radius
    ORDER BY distance
    """, nativeQuery = true)
List<User> findNearbyUsers(
        @Param("lat") double lat,
        @Param("lng") double lng,
        @Param("radius") double radius,
        @Param("userId") UUID userId
);
}
