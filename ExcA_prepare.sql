drop table if exists author;

CREATE TABLE IF NOT EXISTS author(
   id SERIAL PRIMARY KEY,
   surname varchar(50) NOT NULL,
   name varchar(50) NOT NULL,
   patronymic varchar(50) NOT NULL
);

DO $$
DECLARE i INT;
BEGIN
  FOR i IN 1..10 LOOP
    INSERT INTO author (surname, name, patronymic) 
    VALUES ('Русов','Вадим','Викторович'); 
  END LOOP;

  FOR i IN 1..9 LOOP
    INSERT INTO author (surname, name, patronymic) 
    VALUES ('Иванов','Виктор','Вадимович'); 
  END LOOP;

  FOR i IN 1..8 LOOP
    INSERT INTO author (surname, name, patronymic) 
    VALUES ('Сидоров','Сергей','Петрович'); 
  END LOOP;

  INSERT INTO author (surname, name, patronymic) 
  VALUES ('Битков','Петр','Сергеевич'); 

  INSERT INTO author (surname, name, patronymic) 
  VALUES ('Бетков','Петр','Сергеевич'); 

  INSERT INTO author (surname, name, patronymic) 
  VALUES ('Бидков','Петр','Сергеевич'); 

  INSERT INTO author (surname, name, patronymic) 
  VALUES ('Биткоф','Петр','Сергеевич'); 

END$$;
