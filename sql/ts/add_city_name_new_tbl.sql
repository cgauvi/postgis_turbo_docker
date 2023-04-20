CREATE table if not exists  postgisftw.gic_geo_muni as (
	SELECT * from public.gic_geo_muni
);
-- #
CREATE INDEX if not exists gic_geo_muni_proj_idx 
ON  postgisftw.gic_geo_muni
USING GIST(geom);
-- #
DROP table if exists postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city ;
-- #
ALTER table postgisftw.gic_geo_role_eval_cleaned_pc_adm_da drop column  if exists city;
-- #
CREATE table if not exists  postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city as
(
	SELECT poly.mus_nm_mun as city,  pts.*
	FROM postgisftw.gic_geo_role_eval_cleaned_pc_adm_da as pts
	JOIN postgisftw.gic_geo_muni as poly
	ON ST_Contains(poly.geom, pts.geom) 
);
-- #
GRANT select on postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city to generic_ro_user;
-- #
GRANT select on postgisftw.gic_geo_muni to generic_ro_user;