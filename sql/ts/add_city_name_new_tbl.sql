 
drop table if exists postgisftw.gic_geo_muni_proj ;

create table if not exists postgisftw.gic_geo_muni_proj as
(
	select st_transform( geom, 3857) as geom_transformed, mus_nm_mun
	from public.gic_geo_muni 
);


create INDEX if not exists gic_geo_muni_proj_idx 
ON  postgisftw.gic_geo_muni_proj
USING GIST(geom_transformed);

drop table if exists postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city ;
create table if not exists  postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city as
(
	SELECT poly.mus_nm_mun as city,  pts.*
	FROM postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_proj as pts
	JOIN postgisftw.gic_geo_muni_proj as poly
	ON ST_Contains(poly.geom_transformed, pts.geom_transformed) 
	--LIMIT 1000
);


grant select on postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city to generic_ro_user;