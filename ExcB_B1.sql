drop table if exists test_data;

CREATE TABLE test_data (
    id SERIAL PRIMARY KEY,
    x float8,
    y float8
);

INSERT INTO test_data (x,y)

WITH t AS (
    SELECT 50*random() as x FROM generate_series(1, 500)
  )
SELECT x, cos(x) as y  
FROM t
order by x;

select id, x, y from  test_data;