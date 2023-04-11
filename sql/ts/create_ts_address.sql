ALTER TABLE public.gic_geo_role_eval_cleaned_pc_adm_da ADD COLUMN ts tsvector;

UPDATE public.gic_geo_role_eval_cleaned_pc_adm_da SET ts = 
    to_tsvector('addressing_fr',
        concat_ws(', ', full_address,  city));