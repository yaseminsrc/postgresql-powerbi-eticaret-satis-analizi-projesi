CREATE TABLE musteriler (
    musteri_id SERIAL PRIMARY KEY,
    ad VARCHAR(50),
    soyad VARCHAR(50),
    email VARCHAR(100),
    sehir VARCHAR(50),
    ulke VARCHAR(50),
    kayit_tarihi DATE
);

CREATE TABLE urunler (
    urun_id SERIAL PRIMARY KEY,
    urun_adi VARCHAR(100),
    kategori_id INT,
    alis_fiyati DECIMAL(10,2),
    satis_fiyati DECIMAL(10,2),
    stok INT
);

CREATE TABLE siparisler (
    siparis_id SERIAL PRIMARY KEY,
    musteri_id INT REFERENCES musteriler(musteri_id),
    siparis_tarihi DATE,
    kargo_firmasi VARCHAR(50),
    durum VARCHAR(20)
);

CREATE TABLE siparis_detay (
    detay_id SERIAL PRIMARY KEY,
    siparis_id INT REFERENCES siparisler(siparis_id),
    urun_id INT REFERENCES urunler(urun_id),
    miktar INT,
    birim_fiyat DECIMAL(10,2),
    indirim DECIMAL(5,2)
);


INSERT INTO musteriler (ad, soyad, email, sehir, ulke, kayit_tarihi)
SELECT
    'Musteri_' || i,
    'Soyad_' || i,
    'musteri' || i || '@mail.com',

    CASE
        WHEN ulke = 'Türkiye' THEN 'İstanbul'
        WHEN ulke = 'Almanya' THEN 'Berlin'
        WHEN ulke = 'Fransa' THEN 'Paris'
        WHEN ulke = 'Hollanda' THEN 'Amsterdam'
        ELSE 'Londra'
    END AS sehir,

    ulke,

    DATE '2022-01-01' + (random() * 900)::INT

FROM (
    SELECT
        i,
        CASE
            WHEN r < 0.40 THEN 'Türkiye'
            WHEN r < 0.65 THEN 'Almanya'
            WHEN r < 0.80 THEN 'Fransa'
            WHEN r < 0.90 THEN 'Hollanda'
            ELSE 'İngiltere'
        END AS ulke
    FROM (
        SELECT i, random() AS r
        FROM generate_series(1,100) i
    ) t
) x;

/*
-- kontrol et
SELECT ulke, COUNT(*) 
FROM musteriler
GROUP BY ulke
ORDER BY COUNT(*) DESC;

select * from musteriler
*/
UPDATE musteriler
SET ad = CASE
    WHEN ulke = 'Türkiye' THEN
        (ARRAY['Ahmet','Mehmet','Ayşe','Fatma','Ali','Zeynep','Deniz','Ömer'])
        [(musteri_id % 8) + 1]
    WHEN ulke = 'Almanya' THEN
        (ARRAY['Hans','Anna','Peter','Julia','Lukas','Laura','Karl','Elke'])
        [(musteri_id % 8) + 1]
    WHEN ulke = 'Fransa' THEN
        (ARRAY['Jean','Marie','Pierre','Sophie','Luc','Camille','Séphora','Raphaël'])
        [(musteri_id % 8) + 1]
    WHEN ulke = 'Hollanda' THEN
        (ARRAY['Jan','Emma','Lucas','Mila','Noah','Eva','Olivia','Sem'])
        [(musteri_id % 8) + 1]
    ELSE
        (ARRAY['John','Emily','Michael','Sarah','David','Olivia','Jamie','Bella'])
        [(musteri_id % 8) + 1]
END;


UPDATE musteriler
SET soyad = CASE
    WHEN ulke = 'Türkiye' THEN
        (ARRAY['Yılmaz','Kaya','Demir','Çelik','Şahin','Aydın','Koç','Arslan'])
        [(musteri_id % 8) + 1]

    WHEN ulke = 'Almanya' THEN
        (ARRAY['Müller','Schmidt','Schneider','Fischer','Weber','Meyer','Klein','Wolf'])
        [(musteri_id % 8) + 1]

    WHEN ulke = 'Fransa' THEN
        (ARRAY['Dubois','Moreau','Lefevre','Garcia','Martin','Bernard','Roux','Petit'])
        [(musteri_id % 8) + 1]

    WHEN ulke = 'Hollanda' THEN
        (ARRAY['de Jong','Jansen','Bakker','Visser','Smit','Mulder','Bos','Meijer'])
        [(musteri_id % 8) + 1]

    ELSE
        (ARRAY['Smith','Johnson','Brown','Taylor','Anderson','Wilson','Moore','Clark'])
        [(musteri_id % 8) + 1]
END;

UPDATE musteriler
SET email = lower(
    ad || '.' || soyad || musteri_id || '@' ||
    CASE
        WHEN musteri_id % 3 = 0 THEN 'gmail.com'
        WHEN musteri_id % 3 = 1 THEN 'outlook.com'
        ELSE 'yahoo.com'
    END
);

/*
SELECT email, COUNT(*)
FROM musteriler
GROUP BY email
HAVING COUNT(*) > 1;


SELECT
    split_part(email, '@', 2) AS domain,
    COUNT(*) AS adet
FROM musteriler
GROUP BY domain;

*/

INSERT INTO urunler (
    urun_adi,
    kategori_id,
    alis_fiyati,
    satis_fiyati,
    stok
)
SELECT
    'Ürün ' || gs AS urun_adi,

    CASE
        WHEN gs BETWEEN 1 AND 10 THEN 1   -- Elektronik
        WHEN gs BETWEEN 11 AND 20 THEN 2  -- Giyim
        WHEN gs BETWEEN 21 AND 30 THEN 3  -- Ev & Yaşam
        ELSE 4                            -- Spor
    END AS kategori_id,

    CASE
        WHEN gs BETWEEN 1 AND 10 THEN 700 + (gs * 40)     -- alış
        WHEN gs BETWEEN 11 AND 20 THEN 80 + (gs * 6)
        WHEN gs BETWEEN 21 AND 30 THEN 180 + (gs * 12)
        ELSE 120 + (gs * 8)
    END AS alis_fiyati,

    CASE
        WHEN gs BETWEEN 1 AND 10 THEN 1000 + (gs * 75)    -- satış
        WHEN gs BETWEEN 11 AND 20 THEN 150 + (gs * 12)
        WHEN gs BETWEEN 21 AND 30 THEN 300 + (gs * 20)
        ELSE 200 + (gs * 15)
    END AS satis_fiyati,

    CASE
        WHEN gs BETWEEN 1 AND 10 THEN 50 + (gs * 2)
        WHEN gs BETWEEN 11 AND 20 THEN 100 + (gs * 5)
        WHEN gs BETWEEN 21 AND 30 THEN 80 + (gs * 3)
        ELSE 60 + (gs * 4)
    END AS stok
FROM generate_series(1,40) gs;


SELECT COUNT(*) FROM urunler;

SELECT *
FROM urunler
WHERE satis_fiyati <= alis_fiyati;

SELECT MIN(stok), MAX(stok) FROM urunler;

SELECT kategori_id, COUNT(*)
FROM urunler
GROUP BY kategori_id;

/*TRUNCATE TABLE urunler RESTART IDENTITY;

TRUNCATE TABLE siparis_detay RESTART IDENTITY;
TRUNCATE TABLE urunler RESTART IDENTITY;*/

TRUNCATE TABLE siparis_detay, urunler RESTART IDENTITY;

SELECT COUNT(*) FROM siparis_detay;
SELECT COUNT(*) FROM urunler;

INSERT INTO urunler (
    urun_adi,
    kategori_id,
    alis_fiyati,
    satis_fiyati,
    stok
)
SELECT
    'Ürün ' || gs,

    CASE
        WHEN gs BETWEEN 1 AND 6 THEN 1        -- Elektronik
        WHEN gs BETWEEN 7 AND 22 THEN 2       -- Giyim
        WHEN gs BETWEEN 23 AND 32 THEN 3      -- Ev & Yaşam
        ELSE 4                                -- Spor
    END AS kategori_id,

    CASE
        WHEN gs BETWEEN 1 AND 6 THEN 900 + (gs * 60)
        WHEN gs BETWEEN 7 AND 22 THEN 90 + (gs * 5)
        WHEN gs BETWEEN 23 AND 32 THEN 200 + (gs * 10)
        ELSE 150 + (gs * 8)
    END AS alis_fiyati,

    CASE
        WHEN gs BETWEEN 1 AND 6 THEN 1400 + (gs * 90)
        WHEN gs BETWEEN 7 AND 22 THEN 150 + (gs * 10)
        WHEN gs BETWEEN 23 AND 32 THEN 320 + (gs * 18)
        ELSE 240 + (gs * 14)
    END AS satis_fiyati,

    CASE
        WHEN gs BETWEEN 1 AND 6 THEN 30 + (gs * 2)
        WHEN gs BETWEEN 7 AND 22 THEN 200 + (gs * 8)
        WHEN gs BETWEEN 23 AND 32 THEN 120 + (gs * 4)
        ELSE 80 + (gs * 5)
    END AS stok
FROM generate_series(1,40) gs;


SELECT COUNT(*) FROM urunler;

SELECT * FROM urunler ORDER BY urun_id LIMIT 10;

SELECT
    k.kategori_adi,
    COUNT(*) AS urun_sayisi
FROM urunler u
JOIN kategoriler k ON u.kategori_id = k.kategori_id
GROUP BY k.kategori_adi
ORDER BY urun_sayisi DESC;


UPDATE urunler
SET urun_adi = CASE
    WHEN kategori_id = 1 THEN
        CASE
            WHEN urun_id % 6 = 1 THEN 'Akıllı Telefon'
            WHEN urun_id % 6 = 2 THEN 'Laptop'
            WHEN urun_id % 6 = 3 THEN 'Bluetooth Kulaklık'
            WHEN urun_id % 6 = 4 THEN 'Tablet'
            WHEN urun_id % 6 = 5 THEN 'Akıllı Saat'
            ELSE 'Powerbank'
        END

    WHEN kategori_id = 2 THEN
        CASE
            WHEN urun_id % 8 = 1 THEN 'Tişört'
            WHEN urun_id % 8 = 2 THEN 'Kot Pantolon'
            WHEN urun_id % 8 = 3 THEN 'Ceket'
            WHEN urun_id % 8 = 4 THEN 'Elbise'
            WHEN urun_id % 8 = 5 THEN 'Sweatshirt'
            WHEN urun_id % 8 = 6 THEN 'Etek'
            WHEN urun_id % 8 = 7 THEN 'Gömlek'
            ELSE 'Mont'
        END

    WHEN kategori_id = 3 THEN
        CASE
            WHEN urun_id % 5 = 1 THEN 'Koltuk'
            WHEN urun_id % 5 = 2 THEN 'Masa'
            WHEN urun_id % 5 = 3 THEN 'Sandalye'
            WHEN urun_id % 5 = 4 THEN 'Halı'
            ELSE 'Lamba'
        END

    ELSE
        CASE
            WHEN urun_id % 5 = 1 THEN 'Koşu Ayakkabısı'
            WHEN urun_id % 5 = 2 THEN 'Dambıl'
            WHEN urun_id % 5 = 3 THEN 'Yoga Matı'
            WHEN urun_id % 5 = 4 THEN 'Spor Çanta'
            ELSE 'Bisiklet Kaskı'
        END
END;


INSERT INTO siparisler (
    musteri_id,
    siparis_tarihi,
    kargo_firmasi,
    durum
)
SELECT
    m.musteri_id,
    DATE '2023-01-01' + (gs % 365),

    CASE
        WHEN m.ulke = 'Türkiye' THEN
            CASE
                WHEN gs % 100 < 30 THEN 'HepsiJET'
                WHEN gs % 100 < 55 THEN 'Trendyol Express'
                WHEN gs % 100 < 70 THEN 'Aras Kargo'
                WHEN gs % 100 < 82 THEN 'MNG Kargo'
                WHEN gs % 100 < 92 THEN 'Yurtiçi Kargo'
                ELSE 'Sürat Kargo'
            END
        ELSE
            CASE
                WHEN gs % 100 < 70 THEN 'UPS'
                ELSE 'PTT'
            END
    END,

    CASE
        WHEN gs % 10 < 6 THEN 'Teslim Edildi'
        WHEN gs % 10 < 8 THEN 'Kargoda'
        WHEN gs % 10 = 8 THEN 'İade Edildi'
        ELSE 'İptal Edildi'
    END

FROM generate_series(1, 300) gs
JOIN musteriler m
  ON m.musteri_id = ((gs % 50) + 1);


select * from siparisler


INSERT INTO siparis_detay (
    siparis_id,
    urun_id,
    miktar,
    birim_fiyat,
    indirim
)
SELECT
    s.siparis_id,

    /* ÜRÜN SEÇİMİ — KATEGORİ AĞIRLIKLI */
    CASE
        WHEN s.siparis_id % 100 < 45 THEN ((s.siparis_id % 16) + 7)     -- Giyim
        WHEN s.siparis_id % 100 < 70 THEN ((s.siparis_id % 10) + 23)    -- Ev & Yaşam
        WHEN s.siparis_id % 100 < 85 THEN ((s.siparis_id % 8) + 33)     -- Spor
        ELSE ((s.siparis_id % 6) + 1)                                   -- Elektronik
    END AS urun_id,

    /* MİKTAR */
    CASE
        WHEN s.siparis_id % 100 < 45 THEN 1 + (s.siparis_id % 3)  -- Giyim: 1–3
        WHEN s.siparis_id % 100 < 70 THEN 1 + (s.siparis_id % 2)  -- Ev: 1–2
        ELSE 1
    END AS miktar,

    /* BİRİM FİYAT */
    u.satis_fiyati,

    /* İNDİRİM (HERKESTE YOK) */
    CASE
        WHEN s.siparis_id % 10 = 0 THEN 0.15
        WHEN s.siparis_id % 10 = 1 THEN 0.10
        ELSE 0.00
    END AS indirim

FROM siparisler s
JOIN urunler u
  ON u.urun_id = CASE
        WHEN s.siparis_id % 100 < 45 THEN ((s.siparis_id % 16) + 7)
        WHEN s.siparis_id % 100 < 70 THEN ((s.siparis_id % 10) + 23)
        WHEN s.siparis_id % 100 < 85 THEN ((s.siparis_id % 8) + 33)
        ELSE ((s.siparis_id % 6) + 1)
    END;



INSERT INTO siparis_detay (
    siparis_id,
    urun_id,
    miktar,
    birim_fiyat,
    indirim
)
SELECT
    s.siparis_id,
    ((s.siparis_id * 3) % 40) + 1 AS urun_id,
    1,
    u.satis_fiyati,
    0.00
FROM siparisler s
JOIN urunler u
  ON u.urun_id = ((s.siparis_id * 3) % 40) + 1
WHERE s.siparis_id % 4 = 0;   -- her 4 siparişten biri


select * from siparis_detay

SELECT COUNT(*) FROM siparis_detay;

SELECT siparis_id, COUNT(*) AS urun_sayisi
FROM siparis_detay
GROUP BY siparis_id
ORDER BY urun_sayisi DESC;

SELECT indirim, COUNT(*)
FROM siparis_detay
GROUP BY indirim;


SELECT
    u.urun_adi,
    SUM(sd.miktar * sd.birim_fiyat * (1 - sd.indirim)) AS ciro
FROM siparis_detay sd
JOIN urunler u ON sd.urun_id = u.urun_id
GROUP BY u.urun_adi
ORDER BY ciro DESC;

