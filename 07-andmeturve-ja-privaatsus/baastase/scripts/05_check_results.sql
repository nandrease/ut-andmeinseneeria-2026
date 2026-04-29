\echo '1. Kontrollin toortabeli ridade arvu.'

-- Esimene kontroll näitab, kas andmelaadimine toimis.
SELECT COUNT(*) AS osalejaid
FROM staging.osalejad_raw;

\echo '2. Kontrollin PII registrit.'

-- See päring näitab, kas tundlikud väljad on kirjeldatud.
SELECT column_name, pii_category
FROM governance.pii_register
ORDER BY sort_order;

\echo '3. Kontrollin, millisel rollil on SELECT õigus millisele objektile.'

-- has_table_privilege küsib PostgreSQLilt, kas rollil on valitud objekti lugemisõigus.
-- Oodatav tulemus: analyytik ja aruandlus ei saa toortabelit lugeda.
SELECT *
FROM (
    VALUES
        ('analyytik', 'staging.osalejad_raw', has_table_privilege('analyytik', 'staging.osalejad_raw', 'SELECT')),
        ('analyytik', 'secured.v_osalejad_analyytik', has_table_privilege('analyytik', 'secured.v_osalejad_analyytik', 'SELECT')),
        ('aruandlus', 'staging.osalejad_raw', has_table_privilege('aruandlus', 'staging.osalejad_raw', 'SELECT')),
        ('aruandlus', 'secured.v_osalejad_aruandlus', has_table_privilege('aruandlus', 'secured.v_osalejad_aruandlus', 'SELECT')),
        ('auditor', 'staging.osalejad_raw', has_table_privilege('auditor', 'staging.osalejad_raw', 'SELECT')),
        ('auditor', 'secured.v_osalejad_analyytik', has_table_privilege('auditor', 'secured.v_osalejad_analyytik', 'SELECT'))
) AS privilege_check(role_name, object_name, can_select)
ORDER BY role_name, object_name;

\echo '4. Analyytiku vaade. Kontaktandmed peavad olema maskeeritud.'

-- SET ROLE laseb samas psql sessioonis proovida teise rolli õigusi.
SET ROLE analyytik;

-- Analyytik näeb reataseme andmeid, kuid nimi, e-post ja telefon on varjatud.
SELECT osaleja_id, eesnimi_maskitud, perenimi_maskitud, email_maskitud, telefon_maskitud, linn, kursus
FROM secured.v_osalejad_analyytik
ORDER BY osaleja_id
LIMIT 5;

RESET ROLE;

\echo '5. Aruandluse vaade. Tulemuses ei tohi olla nimesid, e-posti ega telefoni.'

SET ROLE aruandlus;

-- Aruandlus näeb ainult koondit kursuse, maakonna ja staatuse kaupa.
SELECT *
FROM secured.v_osalejad_aruandlus
ORDER BY kursus, maakond, staatus;

RESET ROLE;

\echo '6. Auditori kontroll. Auditoril on toortabeli lugemise õigus.'

SET ROLE auditor;

-- Auditor näeb algseid väärtusi. See roll peab olema piiratud ja põhjendatud.
SELECT osaleja_id, eesnimi, perenimi, email, telefon
FROM staging.osalejad_raw
ORDER BY osaleja_id
LIMIT 3;

RESET ROLE;

\echo 'Kontrollskript lõppes.'
