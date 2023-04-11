 

alter table public.gic_geo_role_eval_cleaned_pc_adm_da add city varchar;

WITH transformed as (
	select st_transform( geom, 3347) as geom_transf, mus_nm_mun
	from public.gic_geo_muni 
), 
join_query AS (
  SELECT poly.geom_transf, pts.geom, pts.id_provinc, poly.mus_nm_mun as city
  FROM public.gic_geo_role_eval_cleaned_pc_adm_da as pts
  JOIN transformed as poly
  ON ST_Contains(poly.geom_transf, pts.geom)
)
UPDATE public.gic_geo_role_eval_cleaned_pc_adm_da as m
  SET city = join_query.city
  FROM join_query
  WHERE m.id_provinc = join_query.id_provinc