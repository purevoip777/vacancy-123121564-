drop table if exists test_params;

CREATE TABLE test_params (
    id SERIAL PRIMARY KEY,
    pers_id INT NOT NULL,
    param_id INT NOT NULL,
    param_txt TEXT,
    param_date timestamp default now()
);
