--а) отображения истории изменений для заданного диапазона идентификаторов людей; 
select id,pers_id,param_id,param_date, param_txt
from test_params
where pers_id between 121 and 151
order by pers_id,param_id,param_date;

--б) отображения истории изменений для заданного диапазона идентификаторов людей и даты и времени изменения значения; 
select id,pers_id,param_id,param_date, param_txt
from test_params
where pers_id between 121 and 151
      and param_date between '2025-08-17 08:01:10' and '2025-08-17 09:00:20'
order by pers_id,param_id,param_date;

--в) отображение актуального (последнего по времени изменения) значения каждого параметра для заданного диапазона идентификаторов людей; 
--в1)0.750
select id,pers_id,param_id,param_date, param_txt
from test_params
where pers_id between 121 and 151
      and param_date = (select MAX(a.param_date) from test_params a where a.pers_id=test_params.pers_id and a.param_id=test_params.param_id )
order by pers_id,param_id,param_date;

--в2)0.730
select id,pers_id,param_id,param_date, param_txt
from test_params
where pers_id between 121 and 151
      and param_date = (select a.param_date from test_params a where a.pers_id=test_params.pers_id and a.param_id=test_params.param_id order by a.param_date desc limit 1 )
order by pers_id,param_id,param_date;

--в3)0.718
with t1 as (
     select pers_id,param_id,param_date 
     from test_params
     where pers_id between 121 and 151
     ), t2 as (
     select pers_id,param_id,MAX(param_date) as pdate 
     from t1
     group by pers_id,param_id
     )
select test_params.id,test_params.pers_id,test_params.param_id,test_params.param_date, test_params.param_txt
from test_params
     inner join t2
     on (test_params.pers_id=t2.pers_id
         and test_params.param_id=t2.param_id
         and test_params.param_date = pdate);

--в4)0.720
with t1 as (
     select pers_id,param_id,MAX(param_date) as pdate 
     from test_params
     group by pers_id,param_id
     ), t2 as (
     select pers_id,param_id,pdate 
     from t1
     where pers_id between 121 and 151
     )
select test_params.id,test_params.pers_id,test_params.param_id,test_params.param_date, test_params.param_txt
from test_params
     inner join t2
     on (test_params.pers_id=t2.pers_id
         and test_params.param_id=t2.param_id
         and test_params.param_date = t2.pdate);

--в5)0.717
with t1 as (
     select pers_id,param_id,MAX(param_date) as pdate 
     from test_params
     where pers_id between 121 and 151
     group by pers_id,param_id
     )
select test_params.id,test_params.pers_id,test_params.param_id,test_params.param_date, test_params.param_txt
from test_params
     inner join t1
     on (test_params.pers_id=t1.pers_id
         and test_params.param_id=t1.param_id
         and test_params.param_date = t1.pdate);

--в6)0.882
with t1 as (
     select pers_id,param_id,param_date 
     from test_params
     where param_date = (select a.param_date from test_params a where a.pers_id=test_params.pers_id and a.param_id=test_params.param_id order by a.param_date desc limit 1 ) 
     )
select test_params.id,test_params.pers_id,test_params.param_id,test_params.param_date, test_params.param_txt
from test_params
     inner join t1
     on (test_params.pers_id=t1.pers_id
         and test_params.param_id=t1.param_id
         and test_params.param_date = t1.param_date)
where test_params.pers_id between 121 and 151;

--в7)1.047
with t1 as (
     select pers_id,param_id,param_date 
     from test_params
     where param_date = (select a.param_date from test_params a where a.pers_id=test_params.pers_id and a.param_id=test_params.param_id order by a.param_date desc limit 1 ) 
     )
select test_params.id,test_params.pers_id,test_params.param_id,test_params.param_date, test_params.param_txt
from test_params
     inner join t1
     on (test_params.pers_id=t1.pers_id
         and test_params.param_id=t1.param_id
         and test_params.param_date = t1.param_date
         and test_params.pers_id between 121 and 151);

--в8)0.756
with t1 as (
     select pers_id,param_id,param_date 
     from test_params
     where pers_id between 121 and 151
           and param_date = (select a.param_date from test_params a where a.pers_id=test_params.pers_id and a.param_id=test_params.param_id order by a.param_date desc limit 1 ) 
     )
select test_params.id,test_params.pers_id,test_params.param_id,test_params.param_date, test_params.param_txt
from test_params
     inner join t1
     on (test_params.pers_id=t1.pers_id
         and test_params.param_id=t1.param_id
         and test_params.param_date = t1.param_date);

--в9)0.765
with t1 as (
     select pers_id,param_id,param_date,ROW_NUMBER() OVER(PARTITION BY pers_id, param_id ORDER BY param_date DESC) as rn 
     from test_params
     where pers_id between 121 and 151
     )
select test_params.id,test_params.pers_id,test_params.param_id,test_params.param_date, test_params.param_txt
from test_params
     inner join t1
     on (t1.rn=1
         and test_params.pers_id=t1.pers_id
         and test_params.param_id=t1.param_id
         and test_params.param_date = t1.param_date);

--в10)0.766
with t1 as (
     select pers_id, param_id,param_date 
     from test_params
     where pers_id between 121 and 151
     ), t2 as (
     select pers_id, param_id, param_date, ROW_NUMBER() OVER(PARTITION BY pers_id, param_id ORDER BY param_date DESC) as rn
     from t1
     )
select test_params.id,test_params.pers_id,test_params.param_id,test_params.param_date, test_params.param_txt
from test_params
     inner join t2
     on (t2.rn = 1
         and test_params.pers_id=t2.pers_id
         and test_params.param_id=t2.param_id
         and test_params.param_date = t2.param_date);



--г) отображения самого изменяемого параметра; 
select param_id, count(param_date) 
from test_params
group by param_id
order by count(param_date) desc;

--д) отображения изменений, выполненных в определенный день. 
select id,pers_id,param_id,param_date, param_txt
from test_params
where date_trunc('day',param_date) = '2025-08-17'
order by pers_id,param_id,param_date;



--Индексирование столбца, по которому производится сортировка, существенно помогает увеличить скорость выполнения запроса.
