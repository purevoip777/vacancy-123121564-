CREATE OR REPLACE FUNCTION t1()
RETURNS TEXT AS $$
declare ttt TEXT;
BEGIN
ttt := '"     Тридцать три коpовы,    Тридцать 3   коpовы, 30 три коpовы, /    Свежая стpока. /  33 коpовы, / Стих pодился новый, /    Как стакан паpного молока.    "';
ttt := REGEXP_REPLACE(ttt, '\ +', ' ', 'g');
ttt := REGEXP_REPLACE(ttt, '\s+', ' ', 'g');
ttt := initcap(ttt);
RETURN ttt;

END;
$$ LANGUAGE plpgsql;

select t1();
