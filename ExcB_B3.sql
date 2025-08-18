select id,x,y
from test_data
inner join (
select mins,count(id)
from (
SELECT id,x,y,
MIN(y) OVER (ORDER BY id 
ROWS BETWEEN 0 PRECEDING AND 65 FOLLOWING) as mins
FROM test_data) a
group by mins
having count(id)>10) b
on (y=mins);


select id,x,y
from test_data
inner join (
select maxs,count(id)
from (
SELECT id,x,y,
MAX(y) OVER (ORDER BY id 
ROWS BETWEEN 0 PRECEDING AND 65 FOLLOWING) as maxs
FROM test_data) a
group by maxs
having count(id)>10) b
on (y=maxs);
