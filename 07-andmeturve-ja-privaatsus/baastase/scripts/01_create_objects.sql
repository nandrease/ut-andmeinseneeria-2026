\echo 'Loon skeemid staging, governance ja secured.'

CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS governance;
CREATE SCHEMA IF NOT EXISTS secured;

\echo 'Loon toorandmete tabeli staging.osalejad_raw.'

CREATE TABLE IF NOT EXISTS staging.osalejad_raw (
    osaleja_id TEXT PRIMARY KEY,
    eesnimi TEXT NOT NULL,
    perenimi TEXT NOT NULL,
    email TEXT NOT NULL,
    telefon TEXT NOT NULL,
    linn TEXT NOT NULL,
    maakond TEXT NOT NULL,
    kursus TEXT NOT NULL,
    staatus TEXT NOT NULL,
    registreerumise_kuupaev DATE NOT NULL
);

COMMENT ON TABLE staging.osalejad_raw IS
    'Sünteetiline praktikumi toortabel. Sisaldab PII-laadseid, kuid väljamõeldud andmeid.';

COMMENT ON COLUMN staging.osalejad_raw.email IS
    'Väljamõeldud e-posti aadress. Praktikumis käsitleme seda otsese PII-na.';

\echo 'Valmis. Kontrolli tabelit käsuga: \dt staging.*'
