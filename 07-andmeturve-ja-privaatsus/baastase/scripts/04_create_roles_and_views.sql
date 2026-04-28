\echo 'Loon rollid analyytik, aruandlus ja auditor, kui neid veel ei ole.'

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'analyytik') THEN
        CREATE ROLE analyytik NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'aruandlus') THEN
        CREATE ROLE aruandlus NOLOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'auditor') THEN
        CREATE ROLE auditor NOLOGIN;
    END IF;
END
$$;

\echo 'Loon maskeeritud analyytiku vaate.'

CREATE OR REPLACE VIEW secured.v_osalejad_analyytik AS
SELECT
    osaleja_id,
    left(eesnimi, 1) || repeat('*', greatest(char_length(eesnimi) - 1, 0)) AS eesnimi_maskitud,
    left(perenimi, 1) || repeat('*', greatest(char_length(perenimi) - 1, 0)) AS perenimi_maskitud,
    CASE
        WHEN position('@' IN email) > 1
            THEN left(email, 1) || '***@' || split_part(email, '@', 2)
        ELSE '***'
    END AS email_maskitud,
    left(telefon, 4) || ' *** ' || right(telefon, 2) AS telefon_maskitud,
    linn,
    maakond,
    kursus,
    staatus,
    registreerumise_kuupaev
FROM staging.osalejad_raw;

COMMENT ON VIEW secured.v_osalejad_analyytik IS
    'Analyytiku vaade. Nimi, e-post ja telefon on maskeeritud.';

\echo 'Loon aruandluse koondvaate.'

CREATE OR REPLACE VIEW secured.v_osalejad_aruandlus AS
SELECT
    kursus,
    maakond,
    staatus,
    COUNT(*)::INTEGER AS osalejate_arv,
    MIN(registreerumise_kuupaev) AS esimene_registreerumine,
    MAX(registreerumise_kuupaev) AS viimane_registreerumine
FROM staging.osalejad_raw
GROUP BY kursus, maakond, staatus;

COMMENT ON VIEW secured.v_osalejad_aruandlus IS
    'Aruandluse koondvaade. Reataseme isikuandmeid ei ole.';

\echo 'Eemaldan vaikimisi avalikud õigused ja annan rollidele ainult vajaliku.'

REVOKE ALL ON SCHEMA staging FROM PUBLIC;
REVOKE ALL ON SCHEMA governance FROM PUBLIC;
REVOKE ALL ON SCHEMA secured FROM PUBLIC;

REVOKE ALL ON ALL TABLES IN SCHEMA staging FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA governance FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA secured FROM PUBLIC;

REVOKE ALL ON ALL TABLES IN SCHEMA staging FROM analyytik, aruandlus, auditor;
REVOKE ALL ON ALL TABLES IN SCHEMA governance FROM analyytik, aruandlus, auditor;
REVOKE ALL ON ALL TABLES IN SCHEMA secured FROM analyytik, aruandlus, auditor;

GRANT USAGE ON SCHEMA governance TO analyytik, aruandlus, auditor;
GRANT SELECT ON governance.pii_register TO analyytik, aruandlus, auditor;

GRANT USAGE ON SCHEMA secured TO analyytik, aruandlus;
GRANT SELECT ON secured.v_osalejad_analyytik TO analyytik;
GRANT SELECT ON secured.v_osalejad_aruandlus TO aruandlus;

GRANT USAGE ON SCHEMA staging TO auditor;
GRANT SELECT ON staging.osalejad_raw TO auditor;

\echo 'Rollid, vaated ja õigused on valmis.'
