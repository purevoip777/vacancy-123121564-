CREATE OR REPLACE FUNCTION t1()
RETURNS TEXT AS $$
declare ttt TEXT;
BEGIN
ttt := '"     Тридцать три коpовы,    Тридцать 3   коpовы, 30 три коpовы, /    Свежая стpока. /  33 коpовы, / Стих pодился новый, /    Как стакан паpного молока.    "';
ttt := REGEXP_REPLACE(ttt, '\ +', '', 'g');
ttt := REGEXP_REPLACE(ttt, '\s+', '', 'g');
ttt := REGEXP_REPLACE(ttt, '[а-я,/.0-9p]', '', 'g');
--ttt := array_to_string(regexp_split_to_array(ttt, E'\\s+'), ' ');
RETURN ttt;

END;
$$ LANGUAGE plpgsql;

select t1();
