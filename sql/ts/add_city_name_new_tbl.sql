 
 
create table public.gic_geo_role_eval_cleaned_pc_adm_da_city as
(
	WITH transformed as (
		select st_transform( geom, 3347) as geom_transf, mus_nm_mun
		from public.gic_geo_muni 
	) ,
	subset as (
		SELECT *
		FROM public.gic_geo_role_eval_cleaned_pc_adm_da
		LIMIT 1000
	)
	SELECT poly.mus_nm_mun as city,  pts.*
	FROM subset as pts
	JOIN transformed as poly
	ON ST_Contains(poly.geom_transf, pts.geom) 

);


 