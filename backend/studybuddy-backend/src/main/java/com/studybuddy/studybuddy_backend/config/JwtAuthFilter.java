package com.studybuddy.studybuddy_backend.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.UUID;
import io.jsonwebtoken.JwtException;

@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        // 1. get Authorization header
        String authHeader = request.getHeader("Authorization");

        // 2. check if header exists and starts with "Bearer "
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // 3. extract token (remove "Bearer " prefix)
        String token = authHeader.substring(7);

        // 4. validate token
        if (!jwtUtil.isTokenValid(token)) {
            filterChain.doFilter(request, response);
            return;
        }

        // 5. extract userId from token
        UUID userId;
        try {
            userId = jwtUtil.extractUserId(token);
        } catch (IllegalArgumentException | JwtException ex) {
            filterChain.doFilter(request, response);
            return;
        }

        // 6. tell Spring Security this user is authenticated
        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        userId,      // principal — who they are
                        null,        // credentials — not needed
                        new ArrayList<>() // authorities — roles (empty for now)
                );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        // 7. continue to the controller
        filterChain.doFilter(request, response);
    }
}
