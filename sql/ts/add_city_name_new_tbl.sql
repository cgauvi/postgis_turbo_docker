 
 
create table if not exists postgisftw.gic_geo_muni_proj as
(
	select st_transform( geom, 3347) as geom_transf, mus_nm_mun
	from public.gic_geo_muni 
);

create table if not exists  postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city as
(
	SELECT poly.mus_nm_mun as city,  pts.*
	FROM postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_proj as pts
	JOIN postgisftw.gic_geo_muni_proj as poly
	ON ST_Contains(poly.geom_transf, pts.geom) 
	LIMIT 1000
);


grant select on postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city to generic_ro_user;

 