DROP FUNCTION IF EXISTS postgisftw.to_tsquery_partial;
CREATE OR REPLACE FUNCTION postgisftw.to_tsquery_partial(text)
RETURNS tsquery 
AS $$
BEGIN
  RETURN to_tsquery('simple',
             array_to_string(
               regexp_split_to_array(
                 trim($1),E'\\s+'),' & ') 
             || CASE WHEN $1 ~ ' $' THEN '' ELSE ':*' END
           );
END;
$$ 
LANGUAGE 'plpgsql'
PARALLEL SAFE
IMMUTABLE
STRICT;
 

DROP FUNCTION IF EXISTS postgisftw.address_query;


CREATE OR REPLACE FUNCTION postgisftw.address_query(
    partialstr text DEFAULT '' )
RETURNS TABLE(gid varchar, value text, rank real,  no_civi varchar, no_civi_frac varchar, geom geometry)
AS $$
BEGIN
    RETURN QUERY
        SELECT
          p.id_provinc::varchar AS gid,
          initcap(concat_ws(', ', p.full_address, p.city))::text AS value,
          ts_rank_cd(p.ts, query)::real AS rank,
		  coalesce(no_civi_inf::varchar, no_civi_sup::varchar, '')::varchar as no_civi,
		  coalesce(no_civi_frac_inf::varchar, no_civi_frac_sup::varchar, apt_number::varchar, '')::varchar as no_civi_frac,
          p.geom::geometry
        FROM postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city  p,
             postgisftw.to_tsquery_partial(partialstr) AS query
        WHERE  ts @@ query 
		ORDER BY rank DESC , no_civi ASC ;
END;
$$
LANGUAGE 'plpgsql'
PARALLEL SAFE
STABLE
STRICT;
