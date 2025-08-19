--JSON со структурой [{"person": ..., "parameters": [{"parameter": ..., "modf_time": "...", "value": "..."},...]},...]


WITH t as (
select id,pers_id,param_id,param_date, param_txt
from test_params
where pers_id between 121 and 151
      and param_date = (select MAX(a.param_date) from test_params a where a.pers_id=test_params.pers_id and a.param_id=test_params.param_id )
order by pers_id,param_id,param_date
), t1 as (
SELECT pers_id,
       json_agg(json_build_object(
         'parameter',param_id,
         'modf_time',param_date,
         'value',param_txt)
       ) as s
from t
group by pers_id
)
SELECT json_agg(
         json_build_object(
         'person',pers_id,
         'parameters',s
         )
       )  
FROM t1;
