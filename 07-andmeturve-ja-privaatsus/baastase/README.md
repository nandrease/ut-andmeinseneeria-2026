# Praktikum 7: Andmeturve ja privaatsus (baastase)

## Sisukord

- [Praktikumi eesmärk](#praktikumi-eesmärk)
- [Õpiväljundid](#õpiväljundid)
- [Hinnanguline ajakulu](#hinnanguline-ajakulu)
- [Eeldused](#eeldused)
- [Enne alustamist](#enne-alustamist)
- [Praktikumi failid](#praktikumi-failid)
- [Kus praktikumi failid asuvad?](#kus-praktikumi-failid-asuvad)
- [Miks see teema on oluline?](#miks-see-teema-on-oluline)
- [Uued mõisted](#uued-mõisted)
- [Soovitatud töötee](#soovitatud-töötee)
- [1. Ava õige kaust](#1-ava-õige-kaust)
- [2. Vaata üle praktikumi failid](#2-vaata-üle-praktikumi-failid)
- [3. Loo `.env` fail ja kontrolli `.gitignore` reeglit](#3-loo-env-fail-ja-kontrolli-gitignore-reeglit)
- [4. Käivita andmebaas](#4-käivita-andmebaas)
- [5. Ava `psql` ja kontrolli ühendust](#5-ava-psql-ja-kontrolli-ühendust)
- [6. Loo skeemid ja toortabel](#6-loo-skeemid-ja-toortabel)
- [7. Laadi sünteetilised osalejaandmed](#7-laadi-sünteetilised-osalejaandmed)
- [8. Koosta PII register](#8-koosta-pii-register)
- [9. Loo rollid, vaated ja õigused](#9-loo-rollid-vaated-ja-õigused)
- [10. Kontrolli rolle ühe skriptiga](#10-kontrolli-rolle-ühe-skriptiga)
- [11. Proovi keelatud päringut](#11-proovi-keelatud-päringut)
- [12. Tee õiguste kokkuvõte](#12-tee-õiguste-kokkuvõte)
- [Kontrollpunktid](#kontrollpunktid)
- [Levinud vead ja lahendused](#levinud-vead-ja-lahendused)
- [Kokkuvõte](#kokkuvõte)
- [Valikuline lisaharjutus](#valikuline-lisaharjutus)
- [Koristamine](#koristamine)

## Praktikumi eesmärk

Selle praktikumi eesmärk on harjutada tundlike andmete turvalist käsitlemist väikeses PostgreSQL andmebaasis.

Praktikumi lõpuks näed läbi ühe lihtsa, aga tööelus väga tavalise olukorra:

- ühes toortabelis on nii analüüsiks vajalikud väljad kui ka isikuandmed;
- kõik rollid ei tohi näha samu veerge ega samu andmekihte;
- saladused, näiteks andmebaasi parool, ei kuulu git reposse;
- andmebaasi õigused peavad järgima minimaalõiguste põhimõtet.

Me ei tee siin õigusnõustamist ega käsitle andmekaitse teemat juriidilise juhendina. Keskendume tehnilisele poolele: kuidas andmeinsener saab andmestiku, rollid ja ligipääsud arusaadavalt ning kontrollitavalt üles seada.

## Õpiväljundid

Praktikumi lõpuks oskad:

- selgitada, mida tähendab `PII` ehk isikut tuvastada võimaldav info;
- eristada otsest PII-d, kaudset PII-d ja mitte-PII välju;
- hoida andmebaasi parooli `.env` failis nii, et see ei läheks git reposse;
- luua lihtsad PostgreSQL rollid;
- anda rollidele ligipääsu vaadetele, mitte otse toortabelile;
- kontrollida `SET ROLE` abil, mida eri rollid näevad;
- tõlgendada `permission denied` veateadet turvakontrolli osana.

## Hinnanguline ajakulu

Arvesta umbes 2 tunniga.

See aeg jaguneb ligikaudu nii:

- 20 min keskkonna ja failidega tutvumiseks;
- 15 min `.env` ja `.gitignore` kontrolliks;
- 20 min andmebaasi, skeemide ja toortabeli loomiseks;
- 25 min PII registri ja tundlike väljade aruteluks;
- 30 min rollide, vaadete ja õiguste kontrolliks;
- 10 min kokkuvõtteks ja lisaülesande alustamiseks.

## Eeldused

Sul on vaja:

- `VS Code`-i või GitHub Codespacesit;
- terminali;
- töötavat Dockeri keskkonda;
- selle repositooriumi faile.

Kasuks tuleb, kui eelmiste baastaseme praktikumide põhjal on tuttavad järgmised töövõtted:

- oskad avada õige praktikumi kausta;
- oskad luua `.env` faili `.env.example` põhjal;
- oskad käivitada käsu `docker compose up -d`;
- oskad avada `psql` kliendi käsuga `docker compose exec db psql ...`;
- tead, et osa käske käib hosti terminalis ja osa käske käib `psql` sees.

Kui mõni neist sammudest on veel ebakindel, vaata vajadusel üle:

- [Praktikum 1: PostgreSQL-iga ühenduse loomine ja esimese CSV-faili laadimine](../../01-andmeinseneeria-alused/baastase/README.md)
- [Praktikum 2: Lihtne faktitabel ja kaks dimensiooni](../../02-andmemudelid-ja-baasid/baastase/README.md)
- [Praktikum 3: Andmete integreerimine API ja CSV abil](../../03-andmete-integreerimine/baastase/README.md)

## Enne alustamist

### Soovitatud keskkond

Selle praktikumi jaoks sobib hästi järgmine tööviis:

- ava kaust `07-andmeturve-ja-privaatsus/baastase` `VS Code`-is;
- kasuta `VS Code`-i sisseehitatud terminali;
- hoia korraga lahti `README.md`, `compose.yml` ja `scripts/04_create_roles_and_views.sql`;
- käivita käsud hosti terminalist, kui juhendis ei ole öeldud teisiti.

Host tähendab sinu arvutit või Codespace'i tööruumi. Konteiner tähendab Dockeri sees töötavat teenust. Selles praktikumis on üks konteiner: PostgreSQL andmebaas nimega `db`.

Kui töötad GitHub Codespacesis, siis on praktikumi kaust tavaliselt siin:

```text
/workspaces/ut-andmeinseneeria-2026/07-andmeturve-ja-privaatsus/baastase
```

### Puhas algus

See praktikum kasutab hosti porti `5437`.

Kui see port on mõne muu teenuse poolt hõivatud, muuda failis `.env` väärtust `DB_PORT_HOST` või peata konfliktne teenus.

Kui oled seda praktikumi varem käivitanud ja tahad täiesti puhast andmebaasi, kasuta juhendi lõpus käsku:

```bash
docker compose down -v
```

See kustutab ka Dockeri andmemahu. Järgmisel käivitamisel luuakse andmebaas uuesti.

## Praktikumi failid

Kõik allpool toodud suhtelised failiteed eeldavad, et asud kaustas `07-andmeturve-ja-privaatsus/baastase`.

- [`compose.yml`](./compose.yml) kirjeldab PostgreSQL andmebaasi konteinerit
- [`.env.example`](./.env.example) sisaldab näidisväärtusi andmebaasi kasutaja, parooli ja pordi jaoks
- [`.gitignore`](./.gitignore) ütleb gitile, et `.env` faili ei jälgita
- [`data/osalejad.csv`](./data/osalejad.csv) sisaldab väljamõeldud osalejaandmeid
- [`scripts/01_create_objects.sql`](./scripts/01_create_objects.sql) loob skeemid ja toortabeli
- [`scripts/02_load_data.sql`](./scripts/02_load_data.sql) laadib `CSV` faili toortabelisse
- [`scripts/03_create_pii_register.sql`](./scripts/03_create_pii_register.sql) loob PII registri
- [`scripts/04_create_roles_and_views.sql`](./scripts/04_create_roles_and_views.sql) loob rollid, maskeeritud vaated ja õigused
- [`scripts/05_check_results.sql`](./scripts/05_check_results.sql) kontrollib ridade arvu, rolle ja nähtavaid andmeid
- [`scripts/99_reset.sql`](./scripts/99_reset.sql) eemaldab praktikumi skeemid ja rollid

## Kus praktikumi failid asuvad?

Selles praktikumis on korraga kaks kohta:

- host ehk sinu arvuti või Codespace;
- andmebaasi konteiner `db`.

Sama fail võib nende jaoks olla eri teega.

Näited:

- hostis on fail `data/osalejad.csv`;
- andmebaasi konteineris on sama fail `/data/osalejad.csv`;
- hostis on fail `scripts/02_load_data.sql`;
- andmebaasi konteineris on sama fail `/scripts/02_load_data.sql`.

See on oluline, sest käsk:

```bash
docker compose exec db psql -U praktikum -d praktikum -f /scripts/02_load_data.sql
```

käivitab `psql` kliendi konteineri sees. Seepärast kasutame skripti teena `/scripts/02_load_data.sql`, mitte hosti teed `scripts/02_load_data.sql`.

## Miks see teema on oluline?

Andmeinseneri töö ei lõpe sellega, et andmed jõuavad tabelisse.

Sageli on vaja vastata ka järgmistele küsimustele:

- kas tabelis on isikuandmeid;
- millised veerud on kõige tundlikumad;
- kes tohib näha toorandmeid;
- kes tohib näha ainult maskeeritud andmeid;
- kas paroolid ja võtmed on kogemata reposse sattunud;
- kas kasutajale on antud rohkem õigusi, kui tema töö vajab.

Kui samas tabelis on nimi, e-post, telefon, kursus ja staatus, siis ei ole see lihtsalt tehniline tabel. See on andmestik, millele ligipääs peab olema põhjendatud.

Selles praktikumis teeme selle põhimõtte nähtavaks kolme rolliga:

- `analyytik` näeb maskeeritud reataseme andmeid;
- `aruandlus` näeb ainult koondandmeid;
- `auditor` näeb toorandmeid.

## Uued mõisted

### PII

Probleem on selles, et mõni andmeväli võib inimest tuvastada.

`PII` tähendab inglise keeles `Personally Identifiable Information`. Eesti keeles kasutame siin selgitust: isikut tuvastada võimaldav info.

Näide:

- e-posti aadress `maarja.kask@example.test` võib inimest otse tuvastada;
- linn üksi ei pruugi inimest tuvastada, aga koos kursuse, staatuse ja kuupäevaga võib risk suureneda.

Tehniliselt ei ole PII ainult üks kindel veergude nimekiri. Oluline on ka kontekst: kui palju andmeid on koos ja kes neid näeb.

### Otsene PII

Otsene PII on info, mis võib inimese üsna otse tuvastada.

Näited:

- eesnimi ja perenimi;
- e-posti aadress;
- telefoninumber.

Selles praktikumis maskeerime need väljad analyytiku vaates.

### Kaudne PII

Kaudne PII ei pruugi üksi inimest tuvastada, kuid võib seda teha koos teiste väljadega.

Näited:

- linn;
- maakond;
- registreerumise kuupäev;
- sisemine osaleja tunnus.

Kaudne PII ei tähenda, et välja ei tohi kunagi kasutada. See tähendab, et pead mõtlema, kellele ja milleks seda näitad.

### RBAC

Probleem on selles, et iga kasutaja ei vaja samu õigusi.

`RBAC` tähendab inglise keeles `Role-Based Access Control`. Eesti keeles: rollipõhine ligipääsukontroll.

Näide:

- `analyytik` vajab andmeid mustrite uurimiseks;
- `aruandlus` vajab ainult koondtulemusi;
- `auditor` vajab kontrolli jaoks täielikku ligipääsu.

Tehniliselt loome PostgreSQL rollid ja anname igale rollile `SELECT` õiguse ainult neile objektidele, mida ta vajab.

### Minimaalõigused

Minimaalõiguste põhimõte tähendab, et roll saab ainult need õigused, mida tal tööks vaja on.

Näide:

Kui aruandluse roll vajab osalejate arvu kursuse ja maakonna lõikes, siis ta ei vaja e-posti aadresse ega telefoninumbreid.

Selles praktikumis ei anna me `aruandlus` rollile ligipääsu toortabelile. Ta saab lugeda ainult koondvaadet.

### Saladus

Saladus on väärtus, mida ei tohi avalikult repos hoida.

Näited:

- andmebaasi parool;
- `API` võti;
- privaatvõti;
- teenuse ligipääsutoken.

Selles praktikumis on parool õppekeskkonna lihtne näidisväärtus, kuid töövõte on sama: parool on `.env` failis, mitte koodis.

### `.env`

`.env` on tekstifail, kus hoitakse keskkonnamuutujaid.

Probleem, mida `.env` lahendab: sama kood saab töötada eri keskkondades eri paroolide, portide ja andmebaasinimedega.

Näide:

```text
POSTGRES_USER=praktikum
POSTGRES_PASSWORD=praktikum
POSTGRES_DB=praktikum
DB_PORT_HOST=5437
```

Päris tööelus ei tohiks tootmise parool olla nii lihtne ega repos nähtav.

### `.gitignore`

`.gitignore` ütleb gitile, milliseid faile ei jälgita.

Probleem, mida `.gitignore` lahendab: arendaja võib vajada kohalikku `.env` faili, aga seda ei tohi kogemata commit'ida.

Selles praktikumis sisaldab `.gitignore` rida:

```text
.env
```

### Vaade ja maskeerimine

Vaade on salvestatud päring, mida saab kasutada nagu tabelit.

Probleem, mida vaade lahendab: me saame peita toortabeli ja näidata rollile ainult sobivat kuju samadest andmetest.

Maskeerimine tähendab, et tundlik väärtus asendatakse osaliselt varjatud kujuga.

Näide:

```text
maarja.kask.naidis@example.test -> m***@example.test
```

## Soovitatud töötee

Tee praktikum läbi selles järjekorras:

1. käivita andmebaas;
2. loo toortabel ja laadi andmed;
3. märgi PII veerud registris;
4. loo rollid ja vaated;
5. kontrolli iga rolli vaadet;
6. proovi üht keelatud päringut.

Ära alusta rollide loomisest enne andmete laadimist. Vaated sõltuvad toortabelist.

## 1. Ava õige kaust

See samm tehakse hosti terminalis.

Kui alustad repo juurkaustast, liigu praktikumi kausta:

```bash
cd 07-andmeturve-ja-privaatsus/baastase
```

Kontrolli, et oled õiges kaustas.

macOS-is, Linuxis ja Codespacesis:

```bash
pwd
```

Windows PowerShellis:

```powershell
Get-Location
```

Oodatav tulemus: tee lõpus on `07-andmeturve-ja-privaatsus/baastase`.

## 2. Vaata üle praktikumi failid

See samm tehakse hosti terminalis.

Vaata, millised failid selles kaustas on:

```bash
ls
```

Kui kasutad PowerShelli, töötab sama käsk tavaliselt samuti. Võid kasutada ka:

```powershell
Get-ChildItem
```

Oluline on näha vähemalt neid:

```text
README.md
compose.yml
data
scripts
```

Vaata korraks ka skriptide nimekirja:

```bash
ls scripts
```

Oodatav tulemus: näed skripte `01_create_objects.sql` kuni `05_check_results.sql` ja `99_reset.sql`.

## 3. Loo `.env` fail ja kontrolli `.gitignore` reeglit

See samm tehakse hosti terminalis.

Loo `.env` fail näidisfaili põhjal.

macOS-is, Linuxis ja Codespacesis:

```bash
cp .env.example .env
```

Windows PowerShellis:

```powershell
Copy-Item .env.example .env
```

`.env` fail sisaldab andmebaasi kasutajat, parooli, andmebaasi nime ja hosti porti. Selles praktikumis on väärtused õppekeskkonna jaoks lihtsad.

Kontrolli, et git ignoreerib `.env` faili:

```bash
git check-ignore -v .env
```

Oodatav tulemus on midagi sarnast:

```text
.gitignore:1:.env	.env
```

Kui käsk ei väljasta midagi, siis git ei ignoreeri `.env` faili. Kontrolli, et failis `.gitignore` oleks rida `.env`.

## 4. Käivita andmebaas

See samm tehakse hosti terminalis.

Käivita PostgreSQL konteiner:

```bash
docker compose up -d
```

Käsk teeb kaks asja:

- loeb seadistuse failist `compose.yml`;
- käivitab andmebaasi taustal.

Kontrolli konteineri seisu:

```bash
docker compose ps
```

Oodatav tulemus: teenus `db` on olekus `running` või `healthy`.

Kui näed veateadet pordi kohta, näiteks `port is already allocated`, on port `5437` juba kasutusel. Vaata lahendust jaotisest [Levinud vead ja lahendused](#levinud-vead-ja-lahendused).

## 5. Ava `psql` ja kontrolli ühendust

See samm avab `psql` kliendi andmebaasi konteineri sees.

Käivita hosti terminalis:

```bash
docker compose exec db psql -U praktikum -d praktikum
```

Kui ühendus õnnestub, näed prompti:

```text
praktikum=#
```

Nüüd oled `psql` sees, mitte enam tavalises terminalis.

Kontrolli ühendust:

```sql
\conninfo
```

Oodatav tulemus: `psql` ütleb, et oled ühendatud andmebaasiga `praktikum`.

Välju `psql`-ist:

```sql
\q
```

Kui näed jälle tavalist terminali prompti, oled tagasi hosti terminalis.

## 6. Loo skeemid ja toortabel

See samm tehakse hosti terminalis.

Käivita esimene SQL-skript:

```bash
docker compose exec db psql -U praktikum -d praktikum -f /scripts/01_create_objects.sql
```

Skript loob kolm skeemi:

- `staging` toorandmete jaoks;
- `governance` PII registri jaoks;
- `secured` turvatud vaadete jaoks.

Samuti loob skript tabeli `staging.osalejad_raw`.

Kontrolli, et tabel on olemas:

```bash
docker compose exec db psql -U praktikum -d praktikum -c '\dt staging.*'
```

Oodatav tulemus: nimekirjas on tabel `staging.osalejad_raw`.

## 7. Laadi sünteetilised osalejaandmed

See samm tehakse hosti terminalis.

Laadi andmed failist `data/osalejad.csv`:

```bash
docker compose exec db psql -U praktikum -d praktikum -f /scripts/02_load_data.sql
```

Skript kasutab `\copy` käsku. See loeb `CSV` faili konteineri teelt `/data/osalejad.csv` ja lisab read tabelisse `staging.osalejad_raw`.

Oodatav tulemus:

```text
COPY 12
 laaditud_ridu
---------------
            12
```

Vaata esimesi ridu:

```bash
docker compose exec db psql -U praktikum -d praktikum -c 'SELECT osaleja_id, eesnimi, perenimi, email, linn, kursus FROM staging.osalejad_raw ORDER BY osaleja_id LIMIT 5;'
```

Selles tabelis on ainult väljamõeldud õppeandmed. Me käsitleme neid siiski nagu päris isikuandmeid, sest töövõte peab olema sama.

## 8. Koosta PII register

See samm tehakse hosti terminalis.

Loo PII register:

```bash
docker compose exec db psql -U praktikum -d praktikum -f /scripts/03_create_pii_register.sql
```

PII register on väike tabel, mis kirjeldab toortabeli veerge.

Vaata registrit:

```bash
docker compose exec db psql -U praktikum -d praktikum -c 'SELECT column_name, pii_category, handling_note FROM governance.pii_register ORDER BY sort_order;'
```

Oodatav tulemus: näed iga veeru juures kategooriat `otsene PII`, `kaudne PII` või `ei ole PII`.

Peatu korraks ja mõtle:

- miks `email` on otsene PII;
- miks `linn` on kaudne PII;
- miks `kursus` ei ole üksi PII, aga võib koos nimega muutuda tundlikumaks.

See on andmeturbe oluline osa. Enne õiguste seadmist peab olema selge, mida me üldse kaitseme.

## 9. Loo rollid, vaated ja õigused

See samm tehakse hosti terminalis.

Käivita turvaseadistuse skript:

```bash
docker compose exec db psql -U praktikum -d praktikum -f /scripts/04_create_roles_and_views.sql
```

Skript teeb neli asja:

- loob rollid `analyytik`, `aruandlus` ja `auditor`;
- loob maskeeritud vaate `secured.v_osalejad_analyytik`;
- loob koondvaate `secured.v_osalejad_aruandlus`;
- annab igale rollile ainult vajaliku `SELECT` õiguse.

Kontrolli turvatud vaateid:

```bash
docker compose exec db psql -U praktikum -d praktikum -c '\dv secured.*'
```

Oodatav tulemus: näed vaateid `v_osalejad_analyytik` ja `v_osalejad_aruandlus`.

Vaata õiguste kokkuvõtet:

```bash
docker compose exec db psql -U praktikum -d praktikum -c '\z secured.*'
```

Oodatav tulemus: `analyytik` on seotud analyytiku vaatega ja `aruandlus` aruandluse vaatega.

## 10. Kontrolli rolle ühe skriptiga

See samm tehakse hosti terminalis.

Käivita kontrollskript:

```bash
docker compose exec db psql -U praktikum -d praktikum -f /scripts/05_check_results.sql
```

Skript kontrollib:

- mitu rida on toortabelis;
- millised veerud on PII registris;
- millistel rollidel on `SELECT` õigus;
- mida näeb `analyytik`;
- mida näeb `aruandlus`;
- mida näeb `auditor`.

Olulised oodatavad tulemused:

- `analyytik` ei saa `SELECT` õigust tabelile `staging.osalejad_raw`;
- `analyytik` saab lugeda vaadet `secured.v_osalejad_analyytik`;
- `aruandlus` saab lugeda ainult koondvaadet;
- `auditor` saab lugeda toortabelit.

Analyytiku väljundis peavad nimi, e-post ja telefon olema maskeeritud. Näiteks e-post kuvatakse kujul `m***@example.test`.

## 11. Proovi keelatud päringut

See samm tehakse `psql` sees.

Ava `psql`:

```bash
docker compose exec db psql -U praktikum -d praktikum
```

Võta analyytiku roll:

```sql
SET ROLE analyytik;
```

Kontrolli, et analyytiku vaade töötab:

```sql
SELECT osaleja_id, email_maskitud, telefon_maskitud
FROM secured.v_osalejad_analyytik
ORDER BY osaleja_id
LIMIT 3;
```

Oodatav tulemus: näed maskeeritud e-posti ja telefoni.

Proovi nüüd sama rolliga lugeda toortabelit:

```sql
SELECT osaleja_id, email, telefon
FROM staging.osalejad_raw
LIMIT 3;
```

Oodatav tulemus on viga:

```text
ERROR:  permission denied for schema staging
```

See viga on siin hea märk. See näitab, et `analyytik` ei pääse toortabelini.

Lülita roll tagasi:

```sql
RESET ROLE;
```

Välju `psql`-ist:

```sql
\q
```

## 12. Tee õiguste kokkuvõte

See samm tehakse hosti terminalis.

Vaata õigusi süsteemikataloogide asemel lihtsa kontrollpäringuga:

```bash
docker compose exec db psql -U praktikum -d praktikum -c "SELECT * FROM (VALUES ('analyytik', 'staging.osalejad_raw', has_table_privilege('analyytik', 'staging.osalejad_raw', 'SELECT')), ('analyytik', 'secured.v_osalejad_analyytik', has_table_privilege('analyytik', 'secured.v_osalejad_analyytik', 'SELECT')), ('aruandlus', 'secured.v_osalejad_aruandlus', has_table_privilege('aruandlus', 'secured.v_osalejad_aruandlus', 'SELECT')), ('auditor', 'staging.osalejad_raw', has_table_privilege('auditor', 'staging.osalejad_raw', 'SELECT'))) AS t(role_name, object_name, can_select);"
```

Oodatav mõte:

- `analyytik` toortabeli juures on `false`;
- `analyytik` maskeeritud vaate juures on `true`;
- `aruandlus` koondvaate juures on `true`;
- `auditor` toortabeli juures on `true`.

See ongi minimaalõiguste põhimõte praktilisel kujul.

## Kontrollpunktid

Praktikumi lõpuks peaksid saama kinnitada järgmised väited:

- `.env` fail on loodud, aga git ignoreerib seda.
- Andmebaasi konteiner `db` töötab.
- Tabelis `staging.osalejad_raw` on 12 rida.
- Tabel `governance.pii_register` kirjeldab kõiki toortabeli olulisi veerge.
- Roll `analyytik` näeb maskeeritud vaadet, kuid mitte toortabelit.
- Roll `aruandlus` näeb koondandmeid, kuid mitte reataseme isikuandmeid.
- Roll `auditor` näeb toortabelit.
- Keelatud päring annab `permission denied` vea.

## Levinud vead ja lahendused

### `.env` fail puudub

**Sümptom:** `docker compose up -d` annab vea, et `.env` faili ei leita või mõni muutuja on tühi.

**Tõenäoline põhjus:** `.env.example` põhjal ei ole veel loodud `.env` faili.

**Lahendus:** loo fail uuesti.

```bash
cp .env.example .env
```

PowerShellis:

```powershell
Copy-Item .env.example .env
```

### Port `5437` on juba kasutusel

**Sümptom:** `docker compose up -d` annab vea `port is already allocated` või `bind: address already in use`.

**Tõenäoline põhjus:** mõni teine PostgreSQL või varasem praktikumi konteiner kasutab sama porti.

**Lahendus:** muuda `.env` failis rida:

```text
DB_PORT_HOST=5438
```

Seejärel käivita konteiner uuesti:

```bash
docker compose up -d
```

### `relation "staging.osalejad_raw" does not exist`

**Sümptom:** andmete laadimine või PII registri kontroll annab vea, et tabelit ei ole olemas.

**Tõenäoline põhjus:** skript `01_create_objects.sql` jäi käivitamata või andmebaas loodi uuesti.

**Lahendus:** käivita esimene skript uuesti:

```bash
docker compose exec db psql -U praktikum -d praktikum -f /scripts/01_create_objects.sql
```

### `permission denied for schema staging`

**Sümptom:** `SET ROLE analyytik` järel annab toortabeli päring vea `permission denied`.

**Tõenäoline põhjus:** selles praktikumis on see oodatud tulemus. `analyytik` ei tohi toortabelit lugeda.

**Lahendus:** kasuta analyytiku rolliga maskeeritud vaadet:

```sql
SELECT *
FROM secured.v_osalejad_analyytik
LIMIT 3;
```

### Käsud lähevad valesse kohta

**Sümptom:** terminal ütleb `syntax error`, `command not found` või `invalid command`.

**Tõenäoline põhjus:** SQL käsk sisestati hosti terminali või terminalikäsk sisestati `psql` sisse.

**Lahendus:** kontrolli prompti.

- Kui näed midagi nagu `praktikum=#`, oled `psql` sees ja sinna käivad SQL-käsud.
- Kui näed kaustateed või `$`, oled hosti terminalis ja sinna käivad `docker compose ...` käsud.

`psql`-ist väljumiseks kasuta:

```sql
\q
```

## Kokkuvõte

Selles praktikumis tegid läbi väikese andmeturbe töövoo.

Sa lõid toortabeli, laadisid sinna sünteetilised andmed, kirjeldasid PII veerud registris ja seadsid üles kolm rolli. Oluline mõte on see, et roll ei pea nägema toortabelit ainult sellepärast, et tal on vaja andmetega tööd teha. Sageli piisab maskeeritud vaatest või koondvaatest.

Tööelus on sama põhimõte suurem ja rangem, aga tuum on sama:

- tea, millised andmed on tundlikud;
- hoia saladused koodist väljas;
- anna rollile ainult vajalik ligipääs;
- kontrolli õigusi päriselt, mitte ainult eelda, et need töötavad.

## Valikuline lisaharjutus

Loo uus roll `juhendaja`.

`juhendaja` peab nägema osaleja linna, maakonda, kursust ja staatust, kuid mitte nime, e-posti ega telefoni.

Soovitatud töö:

1. loo roll `juhendaja`;
2. loo vaade `secured.v_osalejad_juhendaja`;
3. anna rollile `USAGE` õigus skeemile `secured`;
4. anna rollile `SELECT` õigus ainult sellele vaatele;
5. testi tulemust käsuga `SET ROLE juhendaja`.

Vihje vaate alguseks:

```sql
CREATE OR REPLACE VIEW secured.v_osalejad_juhendaja AS
SELECT
    osaleja_id,
    linn,
    maakond,
    kursus,
    staatus
FROM staging.osalejad_raw;
```

Kontrollküsimus: kas `osaleja_id` peaks selles vaates olema? Põhjenda oma otsust PII registri põhjal.

## Koristamine

Kui tahad eemaldada ainult praktikumi andmebaasi objektid, jäta konteiner tööle ja käivita:

```bash
docker compose exec db psql -U praktikum -d praktikum -f /scripts/99_reset.sql
```

Kui tahad peatada konteineri, aga andmemahu alles jätta:

```bash
docker compose down
```

Kui tahad täiesti puhast algust ja kustutada ka andmemahu:

```bash
docker compose down -v
```
