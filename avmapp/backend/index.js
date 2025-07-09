const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'avmapp_db',
  password: '14291313',
  port: 5432,
});

pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Veritabanı bağlantı hatası:', err);
  } else {
    console.log('Veritabanı bağlantısı başarılı:', res.rows[0]);
  }
});

// --- Şehir ve İlçeler ---
app.get('/cities', async (req, res) => {
  const result = await pool.query('SELECT * FROM cities');
  res.json(result.rows);
});

app.get('/districts', async (req, res) => {
  const cityId = req.query.city_id;
  if (cityId) {
    const result = await pool.query('SELECT * FROM districts WHERE city_id = $1', [cityId]);
    res.json(result.rows);
  } else {
    const result = await pool.query('SELECT * FROM districts');
    res.json(result.rows);
  }
});

// --- Sıralı veya Tüm AVM'ler ---
app.get('/malls', async (req, res) => {
  const { sort_by, order } = req.query;

  const allowedSorts = ['name', 'rating', 'comment_count'];
  const sortBy = allowedSorts.includes(sort_by) ? sort_by : 'name';
  const sortOrder = order === 'desc' ? 'DESC' : 'ASC';

  try {
    const result = await pool.query(`
      SELECT sm.*, c.name AS city, d.name AS district,
        (SELECT COUNT(*) FROM comments WHERE mall_id = sm.id) AS comment_count
      FROM shopping_malls sm
      LEFT JOIN cities c ON sm.city_id = c.id
      LEFT JOIN districts d ON sm.district_id = d.id
      ORDER BY ${sortBy} ${sortOrder}
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Sıralama hatası' });
  }
});

// --- AVM Filtreleme ---
app.get('/filter-malls', async (req, res) => {
  const { cityId, districtId, brandIds, facilityIds } = req.query;

  let query = `
    SELECT sm.*, c.name AS city, d.name AS district,
      (SELECT COUNT(*) FROM comments cm WHERE cm.mall_id = sm.id) AS comment_count
    FROM shopping_malls sm
    LEFT JOIN cities c ON sm.city_id = c.id
    LEFT JOIN districts d ON sm.district_id = d.id
  `;
  const conditions = [];
  const values = [];

  if (cityId) {
    values.push(cityId);
    conditions.push(`sm.city_id = $${values.length}`);
  }

  if (districtId) {
    values.push(districtId);
    conditions.push(`sm.district_id = $${values.length}`);
  }

if (brandIds) {
  const brandArray = brandIds.split(',').map(Number);
  conditions.push(`
    sm.id IN (
      SELECT mall_id
      FROM mall_brands
      WHERE brand_id = ANY($${values.length + 1}::int[])
      GROUP BY mall_id
      HAVING COUNT(DISTINCT brand_id) = ${brandArray.length}
    )
  `);
  values.push(brandArray);
}

if (facilityIds) {
  const facilityArray = facilityIds.split(',').map(Number);
  conditions.push(`
    sm.id IN (
      SELECT mall_id
      FROM mall_facilities
      WHERE facility_id = ANY($${values.length + 1}::int[])
      GROUP BY mall_id
      HAVING COUNT(DISTINCT facility_id) = ${facilityArray.length}
    )
  `);
  values.push(facilityArray);
}


  if (conditions.length > 0) {
    query += ' WHERE ' + conditions.join(' AND ');
  }

  try {
    const result = await pool.query(query, values);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Filtreleme hatası' });
  }
});

// --- AVM detay ---
app.get('/malls/:id', async (req, res) => {
  const id = req.params.id;
  const result = await pool.query('SELECT * FROM shopping_malls WHERE id = $1', [id]);
  res.json(result.rows[0]);
});

// --- Tüm markalar ---
app.get('/brands', async (req, res) => {
  const result = await pool.query('SELECT * FROM brands');
  res.json(result.rows);
});

// --- AVM'nin markaları ---
app.get('/malls/:id/brands', async (req, res) => {
  const id = req.params.id;
  const result = await pool.query(`
    SELECT b.* FROM brands b
    JOIN mall_brands mb ON b.id = mb.brand_id
    WHERE mb.mall_id = $1
  `, [id]);
  res.json(result.rows);
});

// --- Tüm olanaklar ---
app.get('/facilities', async (req, res) => {
  const result = await pool.query('SELECT * FROM facilities');
  res.json(result.rows);
});

// --- AVM'nin olanakları ---
app.get('/malls/:id/facilities', async (req, res) => {
  const id = req.params.id;
  const result = await pool.query(`
    SELECT f.* FROM facilities f
    JOIN mall_facilities mf ON f.id = mf.facility_id
    WHERE mf.mall_id = $1
  `, [id]);
  res.json(result.rows);
});

// --- Tüm aktiviteler ---
app.get('/activities', async (req, res) => {
  const result = await pool.query('SELECT * FROM random_activities');
  res.json(result.rows);
});

// --- AVM'deki aktiviteler ---
app.get('/malls/:id/activities', async (req, res) => {
  const id = req.params.id;
  const result = await pool.query(`
    SELECT ra.* FROM random_activities ra
    JOIN mall_activities ma ON ra.id = ma.activity_id
    WHERE ma.mall_id = $1
  `, [id]);
  res.json(result.rows);
});

// --- Etkinlik kategorilerine göre AVM getir
// --- Etkinlik + Konuma göre AVM getir ---
app.get('/malls-by-activities', async (req, res) => {
  const ids = req.query.ids;
  const cityId = req.query.city_id;
  const districtId = req.query.district_id;

  if (!ids || !cityId) {
    return res.status(400).json({ error: 'ids ve city_id gereklidir. Örn: ?ids=1,2,3&city_id=1' });
  }

  const idArray = ids.split(',').map(id => parseInt(id.trim()));
  const values = [idArray, idArray.length, parseInt(cityId)];
  let query = `
    SELECT sm.*, 
           c.name AS city, 
           d.name AS district,
           (SELECT COUNT(*) FROM comments WHERE mall_id = sm.id) AS comment_count
    FROM shopping_malls sm
    JOIN mall_activities ma ON sm.id = ma.mall_id
    LEFT JOIN cities c ON sm.city_id = c.id
    LEFT JOIN districts d ON sm.district_id = d.id
    WHERE ma.activity_id = ANY($1::int[])
      AND sm.city_id = $3
  `;

  if (districtId) {
    query += ' AND sm.district_id = $4';
    values.push(parseInt(districtId));
  }

  query += `
    GROUP BY sm.id, c.name, d.name
    HAVING COUNT(DISTINCT ma.activity_id) = $2
  `;

  try {
    const result = await pool.query(query, values);
    res.json(result.rows);
  } catch (err) {
    console.error('Etkinlikli AVM alma hatası:', err);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});


// --- AVM yorumlarını getir
app.get('/comments', async (req, res) => {
  const mallId = req.query.mallId;
  if (mallId) {
    const result = await pool.query('SELECT * FROM comments WHERE mall_id = $1', [mallId]);
    return res.json(result.rows);
  } else {
    const result = await pool.query('SELECT * FROM comments');
    return res.json(result.rows);
  }
});

// --- Yorum ekle + puan güncelle
app.post('/comments', async (req, res) => {
  const { name, email, comment, rating, mall_id } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO comments (name, email, comment, rating, mall_id) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [name, email, comment, rating, mall_id]
    );

    await pool.query(`
      UPDATE shopping_malls
      SET rating_count = rating_count + 1,
          rating = ((rating * (rating_count) + $1) / (rating_count + 1))
      WHERE id = $2
    `, [rating, mall_id]);

    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// --- Sunucu başlat ---
app.listen(3000, '0.0.0.0', () => {
  console.log('🚀 Sunucu çalışıyor: http://localhost:3000');
});
