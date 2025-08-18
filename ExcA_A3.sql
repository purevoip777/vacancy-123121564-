CREATE EXTENSION IF NOT EXISTS pg_trgm;
SELECT * FROM author WHERE surname % 'Битков';