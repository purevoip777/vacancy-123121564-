select surname, name, patronymic, count(id) as cnt
from author
group by surname, name, patronymic
having count(id)>1;