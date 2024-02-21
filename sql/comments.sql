COMMENT ON TABLE postgisftw.building_footprints_open_data IS 'Building footprints created by Sim Lemay Lauziere @ inno. Sources: Msft, OSM, open data';
-- #
COMMENT ON TABLE postgisftw.gic_geo_muni IS 'Quebec Municipalities. Source: decoupage administratifs qc - open data';
-- #
COMMENT ON TABLE postgisftw.gic_geo_pc_no_dups IS 'Approx postal codes created from voronoi tesselation on postal code centroids (duplicate geocodes removed). Created by LaCapitale/fsaldu.voronoi from : M_data_science.feature_store.FS_STG_GEO_CANAD_POSTL_CODE';
-- #
COMMENT ON TABLE  postgisftw.gic_geo_role_eval_cleaned_pc_adm_da IS '2022 Tax assessment data for Quebec (Role evaluation)  Source: LaCapitale/GIC_VEXCEl from open data';
-- #
COMMENT ON TABLE postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_city IS '2022 Tax assessment data for Quebec (Role evaluation) WITH Municipality. Source: LaCapitale/GIC_VEXCEl from open data';
-- #
comment on function postgisftw.address_query is 'Find an address in the tax assessment dataset using a (partial) string';
-- #
comment on function postgisftw.mvt_geom_from_tax  is 'Based on the zoom level & x y tile coordinates, return features (geometry) from the tax dataset in a given tile enveloppe used to create a mvt. Mostly useful for debugging';
-- #
comment on function  postgisftw.mvt_geom_from_buildings is 'Based on the zoom level & x y tile coordinates, return features (geometry) from thebuilding footprint dataset in a given tile enveloppe used to create a mvt. Mostly useful for debugging';