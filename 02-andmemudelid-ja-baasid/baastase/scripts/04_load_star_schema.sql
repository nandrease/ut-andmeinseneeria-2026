TRUNCATE TABLE fact_muuk, dim_toode, dim_klient, dim_kuupaev RESTART IDENTITY;

INSERT INTO dim_klient (kliendi_id, kliendi_nimi, kliendityyp)
SELECT DISTINCT
    kliendi_id,
    kliendi_nimi,
    kliendityyp
FROM source_muuk
ORDER BY kliendi_id;

INSERT INTO dim_toode (toote_kood, toote_nimi, kategooria)
SELECT DISTINCT
    toote_kood,
    toote_nimi,
    kategooria
FROM source_muuk
ORDER BY toote_kood;

INSERT INTO dim_kuupaev (kuupaev, kuupaev_aasta, kuupaev_kuu, kuupaev_paev, kuupaev_nadalapaev, kuupaev_nadal, kuupaev_toopaev, kuupaev_riigipuha)
SELECT DISTINCT
    kuupaev,
    EXTRACT(YEAR FROM kuupaev) AS kuupaev_aasta,
    EXTRACT(MONTH FROM kuupaev) AS kuupaev_kuu,
    EXTRACT(DAY FROM kuupaev) AS kuupaev_paev,
    CASE
        WHEN (EXTRACT(ISODOW FROM kuupaev) - 1) = 0 THEN 'Esmaspäev'
        WHEN (EXTRACT(ISODOW FROM kuupaev) - 1) = 1 THEN 'Teisipäev'
        WHEN (EXTRACT(ISODOW FROM kuupaev) - 1) = 2 THEN 'Kolmapäev'
        WHEN (EXTRACT(ISODOW FROM kuupaev) - 1) = 3 THEN 'Neljapäev'
        WHEN (EXTRACT(ISODOW FROM kuupaev) - 1) = 4 THEN 'Reede'
        WHEN (EXTRACT(ISODOW FROM kuupaev) - 1) = 5 THEN 'Laupäev'
        WHEN (EXTRACT(ISODOW FROM kuupaev) - 1) = 6 THEN 'Pühapäev'
    END AS kuupaev_nadalapaev,
    EXTRACT(WEEK FROM kuupaev) AS kuupaev_nadal,
    CASE WHEN (EXTRACT(ISODOW FROM kuupaev) - 1) IN (5, 6) THEN TRUE ELSE FALSE END AS kuupaev_toopaev,
    FALSE AS kuupaev_riigipuha
FROM source_muuk
ORDER BY kuupaev;

INSERT INTO fact_muuk (
    kuupaev_key,
    tellimuse_nr,
    klient_key,
    toode_key,
    kogus,
    muugisumma
)
SELECT
    d.kuupaev_key,
    s.tellimuse_nr,
    k.klient_key,
    t.toode_key,
    s.kogus,
    ROUND((s.kogus * s.uhikuhind)::NUMERIC, 2) AS muugisumma
FROM source_muuk s
JOIN dim_klient k
    ON s.kliendi_id = k.kliendi_id
JOIN dim_toode t
    ON s.toote_kood = t.toote_kood
JOIN dim_kuupaev d
    ON s.kuupaev = d.kuupaev
ORDER BY d.kuupaev, s.tellimuse_nr, s.toote_kood;
