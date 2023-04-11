drop function if exists postgisftw.mvt_from_point_data; 


CREATE OR REPLACE
FUNCTION postgisftw.mvt_from_tax( z integer, x integer, y integer,
									tbl_name_proj varchar default 'postgisftw.gic_geo_role_eval_cleaned_pc_adm_da_proj' , 					
									geom_col_name varchar default  'geom_transformed')
RETURNS bytea
AS $$
DECLARE
  res bytea;
BEGIN
	WITH 
	mvtgeom AS ( 
	  SELECT st_asmvtgeom(geom_tbl_point.geom, ST_TileEnvelope(z, x, y)), *
		from 
		postgisftw.mvt_geom_from_tax(
			 	z, x, y,
				tbl_name_proj,
			 	geom_col_name
		) as geom_tbl_point
	) 
	SELECT ST_AsMVT(mvtgeom.*)
	INTO RES
	FROM mvtgeom;

	RETURN res;
END;
$$
LANGUAGE 'plpgsql'
STABLE
PARALLEL SAFE;
									
COMMENT ON FUNCTION postgisftw.mvt_from_tax IS E'From based on the zoom level, return a mvt with either all features (geometry) in a given tile enveloppe or a random subset of these FOR POINT DATA.'