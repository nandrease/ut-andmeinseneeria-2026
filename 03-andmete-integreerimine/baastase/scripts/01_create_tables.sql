CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS intermediate;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS staging.user_status (
    email TEXT PRIMARY KEY,
    account_status TEXT NOT NULL,
    source_system TEXT NOT NULL,
    updated_at DATE
);

CREATE TABLE IF NOT EXISTS staging.api_users (
    user_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    city TEXT,
    company_name TEXT,
    loaded_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE staging.api_users
ADD COLUMN IF NOT EXISTS phone TEXT;

-- Tabel luuakse uuesti, et `phone` oleks füüsiliselt `email` järel (PostgreSQL
-- ei luba olemasolevat veergu ümber järjestada).
DROP TABLE IF EXISTS analytics.user_profile CASCADE;

CREATE TABLE analytics.user_profile (
    user_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    city TEXT,
    company_name TEXT,
    account_status TEXT,
    source_system TEXT,
    newsletter_opt_in BOOLEAN,
    preferred_channel TEXT,
    has_missing_additional_data BOOLEAN,
    loaded_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE VIEW intermediate.api_users_normalized AS
SELECT
    user_id,
    full_name,
    username,
    email AS source_email,
    LOWER(TRIM(email)) AS email_key,
    city,
    company_name,
    phone
FROM staging.api_users;

CREATE OR REPLACE VIEW intermediate.user_status_normalized AS
SELECT
    email AS source_email,
    LOWER(TRIM(email)) AS email_key,
    account_status,
    source_system,
    updated_at
FROM staging.user_status;

-- Eemalda vaade enne uuesti loomist: `CREATE OR REPLACE VIEW` ei saa eemaldada
-- veerge (nt pärast `lisa_01_prepare_preferences.sql` laiemat vaadet).
DROP VIEW IF EXISTS intermediate.user_profile_enriched;

CREATE VIEW intermediate.user_profile_enriched AS
SELECT
    a.user_id,
    a.full_name,
    a.username,
    a.email_key AS email,
    a.phone,
    a.city,
    a.company_name,
    s.account_status,
    s.source_system
FROM intermediate.api_users_normalized AS a
LEFT JOIN intermediate.user_status_normalized AS s
    ON a.email_key = s.email_key;
