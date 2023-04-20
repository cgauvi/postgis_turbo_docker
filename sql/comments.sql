COMMENT ON TABLE postgisftw.building_footprints_open_data IS 'Building footprints created by Sim Lemay Lauziere @ inno. Sources: Msft, OSM, open data';
-- #
COMMENT ON TABLE postgisftw.gic_geo_muni IS 'Quebec Municipalities. Source: decoupage administratifs qc - open data';
-- #
COMMENT ON TABLE postgisftw.gic_geo_pc_no_dups IS 'Approx postal codes created from voronoi tesselation on postal code centroids (duplicate geocodes removed). Created by LaCapitale/fsaldu.voronoi from : M_data_science.feature_store.FS_STG_GEO_CANAD_POSTL_CODE';
-- #
COMMENT ON TABLE  postgisftw.gic_geo_role_eval_cleaned_pc_adm_da IS '2022 Tax assessment data for Quebec (Role evaluation)  Source: LaCapitale/GIC_VEXCEl from open data';
-- #
COMMENT ON TABLE postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city IS '2022 Tax assessment data for Quebec (Role evaluation) WITH Municipality. Source: LaCapitale/GIC_VEXCEl from open data';
