CREATE OR REPLACE FUNCTION try_cast_int(p_in text, p_default int default null)
   returns int
as
$$
begin
  begin
    return $1::int;
  exception 
    when others then
       return p_default;
  end;
end;
$$
language plpgsql;

CREATE OR REPLACE FUNCTION text_to_chars(IN text) RETURNS SETOF varchar AS
$BODY$
DECLARE
  _text  ALIAS FOR $1;
  _i  int4;
BEGIN
  FOR _i IN 1 .. length(_text)
LOOP
    RETURN NEXT substring(_text from _i for 1);
END LOOP;
END;
$BODY$
LANGUAGE plpgsql;


select sum(try_cast_int(s,0))
from text_to_chars('"     Тридцать три коpовы,    Тридцать 3   коpовы, 30 три коpовы, /    Свежая стpока. /  33 коpовы, / Стих pодился новый, /    Как стакан паpного молока.    "') as s

