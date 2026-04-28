\echo 'Puhastan toortabeli ja laen CSV-andmed uuesti.'

TRUNCATE TABLE staging.osalejad_raw;

\copy staging.osalejad_raw (osaleja_id, eesnimi, perenimi, email, telefon, linn, maakond, kursus, staatus, registreerumise_kuupaev) FROM '/data/osalejad.csv' WITH (FORMAT csv, HEADER true);

\echo 'Kontrollin, mitu rida laaditi.'

SELECT COUNT(*) AS laaditud_ridu
FROM staging.osalejad_raw;
