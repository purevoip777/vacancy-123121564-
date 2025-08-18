CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DO $$
DECLARE i INT;
DECLARE pers_id INT;
DECLARE param_id INT;
DECLARE param_txt TEXT;
DECLARE param_date timestamp;
BEGIN
  FOR pers_id IN 1..1000 LOOP
    FOR param_id IN 1..100 LOOP
      FOR i IN 1..10 LOOP
        param_txt := uuid_generate_v4();
        param_date := now() - Cast(floor(RANDOM()*10000)+1 || ' seconds' as interval);  
        INSERT INTO test_params (pers_id, param_id, param_txt, param_date ) 
        SELECT pers_id, param_id, param_txt, param_date;   
      END LOOP;
    END LOOP;
  END LOOP;
END$$;
