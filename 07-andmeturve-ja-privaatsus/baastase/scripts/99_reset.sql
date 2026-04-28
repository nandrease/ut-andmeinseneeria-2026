\echo 'Eemaldan praktikumi skeemid ja rollid.'

DROP SCHEMA IF EXISTS secured CASCADE;
DROP SCHEMA IF EXISTS governance CASCADE;
DROP SCHEMA IF EXISTS staging CASCADE;

DROP ROLE IF EXISTS juhendaja;
DROP ROLE IF EXISTS analyytik;
DROP ROLE IF EXISTS aruandlus;
DROP ROLE IF EXISTS auditor;

\echo 'Praktikumi andmebaasi objektid on eemaldatud.'
