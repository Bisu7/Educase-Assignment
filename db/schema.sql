-- ============================================================
-- GitHub Profile Analyzer — Database Schema
-- Run: mysql -u root -p github_analyzer < db/schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS github_analyzer
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE github_analyzer;

-- ------------------------------------------------------------
-- Main table: one row per analyzed GitHub user
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS github_profiles (
  -- Primary key
  id                              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

  -- Identity
  login                           VARCHAR(39)      NOT NULL,           -- GH max username = 39 chars
  github_id                       BIGINT UNSIGNED  NOT NULL,           -- GitHub's own stable numeric ID

  -- Raw profile fields (from GET /users/:username)
  name                            VARCHAR(255),
  bio                             TEXT,
  avatar_url                      VARCHAR(512),
  location                        VARCHAR(255),
  company                         VARCHAR(255),
  blog                            VARCHAR(512),
  public_repos                    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  followers                       INT UNSIGNED      NOT NULL DEFAULT 0,
  following                       INT UNSIGNED      NOT NULL DEFAULT 0,
  github_created_at               DATETIME          NOT NULL,          -- account creation date on GH

  -- Computed insights (all nullable; populated after /repos fetch)
  account_age_days                INT UNSIGNED,
  followers_to_following_ratio    DECIMAL(10, 4),                      -- NULL if following = 0
  avg_stars_per_repo              DECIMAL(10, 4),
  total_stars                     INT UNSIGNED,
  total_forks_received            INT UNSIGNED,
  most_starred_repo_name          VARCHAR(255),
  most_starred_repo_stars         INT UNSIGNED,
  top_language_1                  VARCHAR(100),
  top_language_2                  VARCHAR(100),
  top_language_3                  VARCHAR(100),
  original_repo_count             SMALLINT UNSIGNED,
  forked_repo_count               SMALLINT UNSIGNED,
  repo_creation_freq              DECIMAL(8, 2),                       -- repos per year
  has_readme_profile              TINYINT(1)        NOT NULL DEFAULT 0, -- username/username repo exists

  -- Cache control
  last_analyzed_at                DATETIME          NOT NULL,
  created_at                      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at                      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  -- Constraints & Indexes
  UNIQUE KEY uq_login             (login),
  UNIQUE KEY uq_github_id         (github_id),
  INDEX      idx_last_analyzed    (last_analyzed_at),
  INDEX      idx_total_stars      (total_stars)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
