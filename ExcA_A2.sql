delete 
from author d
using ( 
select b.surname, b.name, b.patronymic, min(b.id) as minid
from author b
inner join (select surname, name, patronymic, count(id) as cnt
from author
group by surname, name, patronymic
having count(id)>1) a
on (b.surname=a.surname and
    b.name=a.name and
    b.patronymic=a.patronymic) 
group by b.surname, b.name, b.patronymic ) c
where d.id > c.minid and
      d.surname=c.surname and
      d.name=c.name and
      d.patronymic=c.patronymic;