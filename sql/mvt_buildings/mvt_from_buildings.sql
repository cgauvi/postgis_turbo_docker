drop function if exists postgisftw.mvt_from_buildings; 


CREATE OR REPLACE
FUNCTION postgisftw.mvt_from_buildings( z integer, x integer, y integer,
								tbl_name_proj varchar default 'public.building_footprints_open_data_proj' , 
								geom_col_name varchar default  'geom')
RETURNS bytea
AS $$
DECLARE
  res bytea;
BEGIN
	WITH 
	mvtgeom AS ( 
	  SELECT st_asmvtgeom(geom_tbl_point.geom, ST_TileEnvelope(z, x, y)), table_orig, num_buildings
		from 
		postgisftw.mvt_geom_from_buildings(
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
									
COMMENT ON FUNCTION postgisftw.mvt_from_buildings IS E'From based on the zoom level, return a mvt with either all features (geometry) in a given tile enveloppe or a random subset of these.'