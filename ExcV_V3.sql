--а) отображения истории изменений для заданного диапазона идентификаторов людей; 
CREATE INDEX tparams_pers_id_index ON test_params (pers_id);

--б) отображения истории изменений для заданного диапазона идентификаторов людей и даты и времени изменения значения; 
CREATE INDEX tparams_pers_id_param_date_index ON test_params (pers_id,param_date);

--в) отображение актуального (последнего по времени изменения) значения каждого параметра для заданного диапазона идентификаторов людей; 
CREATE INDEX tparams_pers_id_param_id_index ON test_params (pers_id,param_id);

--г) отображения самого изменяемого параметра; 
CREATE INDEX tparams_param_id_param_date_index ON test_params (param_id,param_date);

--д) отображения изменений, выполненных в определенный день. 
CREATE INDEX tparams_param_date_index ON test_params (param_date);



--Индексирование столбца, по которому производится сортировка, существенно помогает увеличить скорость выполнения запроса.
