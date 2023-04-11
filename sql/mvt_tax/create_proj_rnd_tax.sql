drop table if exists postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_proj;

create table postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_proj as
(
    select ST_MakeValid(ST_Transform( geom ,3857)) as geom_transformed, *
    from public.gic_geo_role_eval_cleaned_pc_adm_da
    order by RANDOM ()
    limit 1000
);