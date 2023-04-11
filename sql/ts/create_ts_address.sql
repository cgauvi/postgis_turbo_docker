ALTER TABLE postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city ADD COLUMN if not exists ts tsvector;

UPDATE postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city SET ts = 
    to_tsvector('addressing_fr',
        concat_ws(', ', full_address,  city));