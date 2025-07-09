// backend/index.js
// Main entry point for Mall Finder API
// Updates: moved DB credentials to .env, separated pool in config/db.js

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const pool = require('../../config/db'); // centralised PG pool

const app = express();
app.use(cors());
app.use(express.json());

// Test DB connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Database connection error:', err);
  } else {
    console.log('✅ Database connected at:', res.rows[0].now);
  }
});

/* --------------------------- Helper Endpoints --------------------------- */

// Cities
app.get('/cities', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM cities');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'City fetch error' });
  }
});

// Districts (optionally filter by city)
app.get('/districts', async (req, res) => {
  try {
    const { city_id } = req.query;
    const query = city_id
      ? pool.query('SELECT * FROM districts WHERE city_id = $1', [city_id])
      : pool.query('SELECT * FROM districts');
    const result = await query;
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'District fetch error' });
  }
});

/* --------------------------- Mall Endpoints --------------------------- */

// Malls list with optional sorting
app.get('/malls', async (req, res) => {
  const { sort_by, order } = req.query;
  const allowedSorts = ['name', 'rating', 'comment_count'];
  const sortBy = allowedSorts.includes(sort_by) ? sort_by : 'name';
  const sortOrder = order === 'desc' ? 'DESC' : 'ASC';

  try {
    const query = `
      SELECT sm.*, c.name AS city, d.name AS district,
             (SELECT COUNT(*) FROM comments WHERE mall_id = sm.id) AS comment_count
      FROM shopping_malls sm
      LEFT JOIN cities c ON sm.city_id = c.id
      LEFT JOIN districts d ON sm.district_id = d.id
      ORDER BY ${sortBy} ${sortOrder}`;

    const result = await pool.query(query);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Sorting error' });
  }
});

// Filter malls by city/district/brands/facilities
app.get('/filter-malls', async (req, res) => {
  try {
    const { cityId, districtId, brandIds, facilityIds } = req.query;
    let query = `
      SELECT sm.*, c.name AS city, d.name AS district,
        (SELECT COUNT(*) FROM comments cm WHERE cm.mall_id = sm.id) AS comment_count
      FROM shopping_malls sm
      LEFT JOIN cities c ON sm.city_id = c.id
      LEFT JOIN districts d ON sm.district_id = d.id`;

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
      conditions.push(`sm.id IN (
        SELECT mall_id FROM mall_brands
        WHERE brand_id = ANY($${values.length + 1}::int[])
        GROUP BY mall_id HAVING COUNT(DISTINCT brand_id) = ${brandArray.length})`);
      values.push(brandArray);
    }

    if (facilityIds) {
      const facilityArray = facilityIds.split(',').map(Number);
      conditions.push(`sm.id IN (
        SELECT mall_id FROM mall_facilities
        WHERE facility_id = ANY($${values.length + 1}::int[])
        GROUP BY mall_id HAVING COUNT(DISTINCT facility_id) = ${facilityArray.length})`);
      values.push(facilityArray);
    }

    if (conditions.length) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    const result = await pool.query(query, values);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Filter error' });
  }
});

// Mall details
app.get('/malls/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { rows } = await pool.query('SELECT * FROM shopping_malls WHERE id = $1', [id]);
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Mall detail error' });
  }
});

/* --------------------------- Brand & Facility Endpoints --------------------------- */

app.get('/brands', async (_, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM brands');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Brand fetch error' });
  }
});

app.get('/malls/:id/brands', async (req, res) => {
  try {
    const { id } = req.params;
    const { rows } = await pool.query(
      `SELECT b.* FROM brands b JOIN mall_brands mb ON b.id = mb.brand_id WHERE mb.mall_id = $1`,
      [id]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Mall-brand fetch error' });
  }
});

app.get('/facilities', async (_, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM facilities');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Facility fetch error' });
  }
});

app.get('/malls/:id/facilities', async (req, res) => {
  try {
    const { id } = req.params;
    const { rows } = await pool.query(
      `SELECT f.* FROM facilities f JOIN mall_facilities mf ON f.id = mf.facility_id WHERE mf.mall_id = $1`,
      [id]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Mall-facility fetch error' });
  }
});

/* --------------------------- Activity Endpoints --------------------------- */

app.get('/activities', async (_, res) => {
  try {
    const { rows } = await pool.query('SELECT * FROM random_activities');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Activity fetch error' });
  }
});

app.get('/malls/:id/activities', async (req, res) => {
  try {
    const { id } = req.params;
    const { rows } = await pool.query(
      `SELECT ra.* FROM random_activities ra JOIN mall_activities ma ON ra.id = ma.activity_id WHERE ma.mall_id = $1`,
      [id]
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Mall-activities fetch error' });
  }
});

app.get('/malls-by-activities', async (req, res) => {
  const { ids, city_id, district_id } = req.query;
  if (!ids || !city_id) {
    return res.status(400).json({ error: 'ids and city_id are required' });
  }
  try {
    const idArray = ids.split(',').map(Number);
    const values = [idArray, idArray.length, parseInt(city_id)];
    let query = `
      SELECT sm.*, c.name AS city, d.name AS district,
             (SELECT COUNT(*) FROM comments WHERE mall_id = sm.id) AS comment_count
      FROM shopping_malls sm
      JOIN mall_activities ma ON sm.id = ma.mall_id
      LEFT JOIN cities c ON sm.city_id = c.id
      LEFT JOIN districts d ON sm.district_id = d.id
      WHERE ma.activity_id = ANY($1::int[]) AND sm.city_id = $3`;

    if (district_id) {
      query += ' AND sm.district_id = $4';
      values.push(parseInt(district_id));
    }

    query += ' GROUP BY sm.id, c.name, d.name HAVING COUNT(DISTINCT ma.activity_id) = $2';

    const { rows } = await pool.query(query, values);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Mall-activities filter error' });
  }
});

/* --------------------------- Comment Endpoints --------------------------- */

app.get('/comments', async (req, res) => {
  try {
    const { mallId } = req.query;
    const { rows } = mallId
      ? await pool.query('SELECT * FROM comments WHERE mall_id = $1', [mallId])
      : await pool.query('SELECT * FROM comments');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Comment fetch error' });
  }
});

app.post('/comments', async (req, res) => {
  try {
    const { name, email, comment, rating, mall_id } = req.body;
    const {
      rows: [newComment],
    } = await pool.query(
      'INSERT INTO comments (name, email, comment, rating, mall_id) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [name, email, comment, rating, mall_id]
    );

    await pool.query(
      `UPDATE shopping_malls
       SET rating_count = rating_count + 1,
           rating = ((rating * (rating_count) + $1) / (rating_count + 1))
       WHERE id = $2`,
      [rating, mall_id]
    );

    res.status(201).json(newComment);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

/* --------------------------- Start Server --------------------------- */

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
