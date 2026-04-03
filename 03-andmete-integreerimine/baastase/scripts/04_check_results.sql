SELECT COUNT(*) AS rows_in_api_users
FROM staging.api_users;

SELECT COUNT(*) AS rows_in_intermediate_user_profile
FROM intermediate.user_profile_enriched;

SELECT COUNT(*) AS rows_in_user_profile
FROM analytics.user_profile;

SELECT
    user_id,
    full_name,
    email,
    phone,
    account_status,
    source_system
FROM intermediate.user_profile_enriched
ORDER BY user_id;

SELECT
    user_id,
    full_name,
    email,
    phone,
    account_status,
    source_system
FROM analytics.user_profile
ORDER BY user_id;

-- Lisaülesanne 4: kokkuvõttepäringud (eeldab kolme allika voogu ja
-- `analytics.user_profile` täitmist, nt `lisa_03_integrate_users.py` abil).

-- Mitu kasutajat on iga `account_status` väärtuse all (sh `NULL`, kui staatus puudub).
SELECT
    account_status,
    COUNT(*) AS kasutajate_arv
FROM analytics.user_profile
GROUP BY account_status
ORDER BY account_status NULLS LAST;

-- Mitu kasutajat eelistab kanalit `email`, `sms` või `push` (kokku grupeerituna).
SELECT
    preferred_channel,
    COUNT(*) AS kasutajate_arv
FROM analytics.user_profile
WHERE preferred_channel IS NOT NULL AND preferred_channel IN ('email', 'sms', 'push')
GROUP BY preferred_channel
ORDER BY preferred_channel;