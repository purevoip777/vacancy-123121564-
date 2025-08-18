--в) отображение актуального (последнего по времени изменения) значения каждого параметра для заданного диапазона идентификаторов людей; 
--в1)0.711s
select id,pers_id,param_id,param_date, param_txt
from test_params
where pers_id between 121 and 151
      and param_date = (select MAX(a.param_date) from test_params a where a.pers_id=test_params.pers_id and a.param_id=test_params.param_id )
order by pers_id,param_id,param_date;

EXPLAIN:
"Incremental Sort  (cost=5257.74..725514.61 rows=148 width=57)"
"  Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"  Presorted Key: test_params.pers_id"
"  ->  Index Scan using tparams_pers_id_index on test_params  (cost=0.42..725508.30 rows=148 width=57)"
"        Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"
"        Filter: (param_date = (SubPlan 1))"
"        SubPlan 1"
"          ->  Aggregate  (cost=24.40..24.41 rows=1 width=8)"
"                ->  Index Scan using tparams_pers_id_param_id_index on test_params a  (cost=0.42..24.38 rows=10 width=8)"
"                      Index Cond: ((pers_id = test_params.pers_id) AND (param_id = test_params.param_id))"
--в2)0.711s
select id,pers_id,param_id,param_date, param_txt
from test_params
where pers_id between 121 and 151
      and param_date = (select a.param_date from test_params a where a.pers_id=test_params.pers_id and a.param_id=test_params.param_id order by a.param_date desc limit 1 )
order by pers_id,param_id,param_date;

EXPLAIN:
"Incremental Sort  (cost=5261.50..726033.94 rows=148 width=57)"
"  Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"  Presorted Key: test_params.pers_id"
"  ->  Index Scan using tparams_pers_id_index on test_params  (cost=0.42..726027.63 rows=148 width=57)"
"        Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"
"        Filter: (param_date = (SubPlan 1))"
"        SubPlan 1"
"          ->  Limit  (cost=24.43..24.43 rows=1 width=8)"
"                ->  Sort  (cost=24.43..24.45 rows=10 width=8)"
"                      Sort Key: a.param_date DESC"
"                      ->  Index Scan using tparams_pers_id_param_id_index on test_params a  (cost=0.42..24.38 rows=10 width=8)"
"                            Index Cond: ((pers_id = test_params.pers_id) AND (param_id = test_params.param_id))"

--в3)0.747s
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
         and test_params.param_date = pdate)
order by pers_id,param_id,param_date;

EXPLAIN:
"Gather Merge  (cost=22052.93..22054.10 rows=10 width=57)"
"  Workers Planned: 2"
"  ->  Sort  (cost=21052.90..21052.92 rows=5 width=57)"
"        Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"        ->  Hash Join  (cost=2240.93..21052.85 rows=5 width=57)"
"              Hash Cond: ((test_params.pers_id = test_params_1.pers_id) AND (test_params.param_id = test_params_1.param_id) AND (test_params.param_date = (max(test_params_1.param_date))))"
"              ->  Parallel Seq Scan on test_params  (cost=0.00..15530.67 rows=416667 width=57)"
"              ->  Hash  (cost=1785.74..1785.74 rows=26011 width=16)"
"                    ->  HashAggregate  (cost=1265.51..1525.62 rows=26011 width=16)"
"                          Group Key: test_params_1.pers_id, test_params_1.param_id"
"                          ->  Index Scan using tparams_pers_id_index on test_params test_params_1  (cost=0.42..1042.94 rows=29676 width=16)"
"                                Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"

--в4)0.870s
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
         and test_params.param_date = t2.pdate)
order by pers_id,param_id,param_date;

EXPLAIN:
"Gather Merge  (cost=22052.93..22054.10 rows=10 width=57)"
"  Workers Planned: 2"
"  ->  Sort  (cost=21052.90..21052.92 rows=5 width=57)"
"        Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"        ->  Hash Join  (cost=2240.93..21052.85 rows=5 width=57)"
"              Hash Cond: ((test_params.pers_id = test_params_1.pers_id) AND (test_params.param_id = test_params_1.param_id) AND (test_params.param_date = (max(test_params_1.param_date))))"
"              ->  Parallel Seq Scan on test_params  (cost=0.00..15530.67 rows=416667 width=57)"
"              ->  Hash  (cost=1785.74..1785.74 rows=26011 width=16)"
"                    ->  HashAggregate  (cost=1265.51..1525.62 rows=26011 width=16)"
"                          Group Key: test_params_1.pers_id, test_params_1.param_id"
"                          ->  Index Scan using tparams_pers_id_index on test_params test_params_1  (cost=0.42..1042.94 rows=29676 width=16)"
"                                Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"
--в5)0.758s
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
         and test_params.param_date = t1.pdate)
order by pers_id,param_id,param_date;

EXPLAIN:
"Gather Merge  (cost=22052.93..22054.10 rows=10 width=57)"
"  Workers Planned: 2"
"  ->  Sort  (cost=21052.90..21052.92 rows=5 width=57)"
"        Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"        ->  Hash Join  (cost=2240.93..21052.85 rows=5 width=57)"
"              Hash Cond: ((test_params.pers_id = test_params_1.pers_id) AND (test_params.param_id = test_params_1.param_id) AND (test_params.param_date = (max(test_params_1.param_date))))"
"              ->  Parallel Seq Scan on test_params  (cost=0.00..15530.67 rows=416667 width=57)"
"              ->  Hash  (cost=1785.74..1785.74 rows=26011 width=16)"
"                    ->  HashAggregate  (cost=1265.51..1525.62 rows=26011 width=16)"
"                          Group Key: test_params_1.pers_id, test_params_1.param_id"
"                          ->  Index Scan using tparams_pers_id_index on test_params test_params_1  (cost=0.42..1042.94 rows=29676 width=16)"
"                                Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"
--в6)0.928s
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
where test_params.pers_id between 121 and 151
order by pers_id,param_id,param_date;

EXPLAIN:
"Sort  (cost=699612.11..699612.12 rows=1 width=57)"
"  Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"  ->  Nested Loop  (cost=0.86..699612.10 rows=1 width=57)"
"        ->  Index Scan using tparams_pers_id_index on test_params  (cost=0.42..1042.94 rows=29676 width=57)"
"              Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"
"        ->  Memoize  (cost=0.43..26.84 rows=1 width=16)"
"              Cache Key: test_params.param_date, test_params.pers_id, test_params.param_id"
"              Cache Mode: logical"
"              ->  Index Scan using tparams_param_id_param_date_index on test_params test_params_1  (cost=0.42..26.83 rows=1 width=16)"
"                    Index Cond: ((param_id = test_params.param_id) AND (param_date = test_params.param_date))"
"                    Filter: ((test_params.pers_id = pers_id) AND (param_date = (SubPlan 1)))"
"                    SubPlan 1"
"                      ->  Limit  (cost=24.43..24.43 rows=1 width=8)"
"                            ->  Sort  (cost=24.43..24.45 rows=10 width=8)"
"                                  Sort Key: a.param_date DESC"
"                                  ->  Index Scan using tparams_pers_id_param_id_index on test_params a  (cost=0.42..24.38 rows=10 width=8)"
"                                        Index Cond: ((pers_id = test_params_1.pers_id) AND (param_id = test_params_1.param_id))"

--в7)1.033s
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
         and test_params.pers_id between 121 and 151)
order by pers_id,param_id,param_date;

EXPLAIN:
"Sort  (cost=699612.11..699612.12 rows=1 width=57)"
"  Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"  ->  Nested Loop  (cost=0.86..699612.10 rows=1 width=57)"
"        ->  Index Scan using tparams_pers_id_index on test_params  (cost=0.42..1042.94 rows=29676 width=57)"
"              Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"
"        ->  Memoize  (cost=0.43..26.84 rows=1 width=16)"
"              Cache Key: test_params.param_date, test_params.pers_id, test_params.param_id"
"              Cache Mode: logical"
"              ->  Index Scan using tparams_param_id_param_date_index on test_params test_params_1  (cost=0.42..26.83 rows=1 width=16)"
"                    Index Cond: ((param_id = test_params.param_id) AND (param_date = test_params.param_date))"
"                    Filter: ((test_params.pers_id = pers_id) AND (param_date = (SubPlan 1)))"
"                    SubPlan 1"
"                      ->  Limit  (cost=24.43..24.43 rows=1 width=8)"
"                            ->  Sort  (cost=24.43..24.45 rows=10 width=8)"
"                                  Sort Key: a.param_date DESC"
"                                  ->  Index Scan using tparams_pers_id_param_id_index on test_params a  (cost=0.42..24.38 rows=10 width=8)"
"                                        Index Cond: ((pers_id = test_params_1.pers_id) AND (param_id = test_params_1.param_id))"

--в8)0.726s
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
         and test_params.param_date = t1.param_date)
order by pers_id,param_id,param_date;

EXPLAIN:
"Sort  (cost=727267.35..727267.35 rows=1 width=57)"
"  Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"  ->  Nested Loop  (cost=0.85..727267.34 rows=1 width=57)"
"        ->  Index Scan using tparams_pers_id_index on test_params test_params_1  (cost=0.42..726027.63 rows=148 width=16)"
"              Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"
"              Filter: (param_date = (SubPlan 1))"
"              SubPlan 1"
"                ->  Limit  (cost=24.43..24.43 rows=1 width=8)"
"                      ->  Sort  (cost=24.43..24.45 rows=10 width=8)"
"                            Sort Key: a.param_date DESC"
"                            ->  Index Scan using tparams_pers_id_param_id_index on test_params a  (cost=0.42..24.38 rows=10 width=8)"
"                                  Index Cond: ((pers_id = test_params_1.pers_id) AND (param_id = test_params_1.param_id))"
"        ->  Index Scan using tparams_param_id_param_date_index on test_params  (cost=0.42..8.37 rows=1 width=57)"
"              Index Cond: ((param_id = test_params_1.param_id) AND (param_date = test_params_1.param_date))"
"              Filter: (test_params_1.pers_id = pers_id)"


--в9)0.726s
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
         and test_params.param_date = t1.param_date)
order by pers_id,param_id,param_date;

EXPLAIN:
"Sort  (cost=4887.92..4887.93 rows=1 width=57)"
"  Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"  ->  Nested Loop  (cost=3.12..4887.91 rows=1 width=57)"
"        ->  Subquery Scan on t1  (cost=2.69..3654.29 rows=148 width=16)"
"              Filter: (t1.rn = 1)"
"              ->  WindowAgg  (cost=2.69..3283.34 rows=29676 width=24)"
"                    Run Condition: (row_number() OVER (?) <= 1)"
"                    ->  Incremental Sort  (cost=2.69..2689.82 rows=29676 width=16)"
"                          Sort Key: test_params_1.pers_id, test_params_1.param_id, test_params_1.param_date DESC"
"                          Presorted Key: test_params_1.pers_id"
"                          ->  Index Scan using tparams_pers_id_index on test_params test_params_1  (cost=0.42..1042.94 rows=29676 width=16)"
"                                Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"
"        ->  Memoize  (cost=0.43..8.38 rows=1 width=57)"
"              Cache Key: t1.pers_id, t1.param_id, t1.param_date"
"              Cache Mode: logical"
"              ->  Index Scan using tparams_param_id_param_date_index on test_params  (cost=0.42..8.37 rows=1 width=57)"
"                    Index Cond: ((param_id = t1.param_id) AND (param_date = t1.param_date))"
"                    Filter: (t1.pers_id = pers_id)"

--в10)0.721s
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
         and test_params.param_date = t2.param_date)
order by pers_id,param_id,param_date;

EXPLAIN:
"Sort  (cost=4887.92..4887.93 rows=1 width=57)"
"  Sort Key: test_params.pers_id, test_params.param_id, test_params.param_date"
"  ->  Nested Loop  (cost=3.12..4887.91 rows=1 width=57)"
"        ->  Subquery Scan on t2  (cost=2.69..3654.29 rows=148 width=16)"
"              Filter: (t2.rn = 1)"
"              ->  WindowAgg  (cost=2.69..3283.34 rows=29676 width=24)"
"                    Run Condition: (row_number() OVER (?) <= 1)"
"                    ->  Incremental Sort  (cost=2.69..2689.82 rows=29676 width=16)"
"                          Sort Key: test_params_1.pers_id, test_params_1.param_id, test_params_1.param_date DESC"
"                          Presorted Key: test_params_1.pers_id"
"                          ->  Index Scan using tparams_pers_id_index on test_params test_params_1  (cost=0.42..1042.94 rows=29676 width=16)"
"                                Index Cond: ((pers_id >= 121) AND (pers_id <= 151))"
"        ->  Memoize  (cost=0.43..8.38 rows=1 width=57)"
"              Cache Key: t2.pers_id, t2.param_id, t2.param_date"
"              Cache Mode: logical"
"              ->  Index Scan using tparams_param_id_param_date_index on test_params  (cost=0.42..8.37 rows=1 width=57)"
"                    Index Cond: ((param_id = t2.param_id) AND (param_date = t2.param_date))"
"                    Filter: (t2.pers_id = pers_id)"