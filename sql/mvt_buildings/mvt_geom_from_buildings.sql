drop function if exists postgisftw.mvt_geom_from_buildings; 
-- #
CREATE OR REPLACE
FUNCTION postgisftw.mvt_geom_from_buildings( z integer, x integer, y integer,
				tbl_name_proj varchar default 'postgisftw.building_footprints_open_data_proj' , 					
				geom_col_name varchar default  'geom',
				max_zoom integer default 13,
				min_zoom integer default 4)
RETURNS table (geom geometry, table_orig varchar, num_buildings integer)
AS $$
DECLARE
 	sql_cmd varchar;
	lim integer;
	geohash_prec integer;
BEGIN

	-- Full precision for large zooms
	if z >= max_zoom then

		sql_cmd :=  '
		SELECT 
			 ST_MakeValid( ST_Intersection( ' || geom_col_name || ',
						ST_TileEnvelope( ' || z || ',' || x || ',' || y || ') 
						) ) AS geom, table_orig, 1::integer as num_buildings
		  FROM  
				 '  || tbl_name_proj || '
		  WHERE ST_Intersects(  ' || geom_col_name || ', 
						ST_TileEnvelope( ' || z || ',' || x || ',' || y || ') 
						);'
		;	
	else

		-- 2.9**8 ~ 5000
		lim:= GREATEST(100, POWER(2.9, z));
		
		-- Geohash 
		if  z >= 12 and  z < max_zoom then
			geohash_prec :=  7;
		elsif   z >= 10 and  z < 12 	 then
			geohash_prec := 6;
		elsif   z >= 8 and  z < 10 	 then
			geohash_prec := 5;
		elsif   z >= 6 and  z < 8 	 then
			geohash_prec := 4;
		elsif   z >= min_zoom and  z < 6 	 then
			geohash_prec := 4;
		else
			geohash_prec := 3;
		end if;

		sql_cmd :=  '
			SELECT 
				ST_Intersection( geom,  
							ST_TileEnvelope( ' || z || ',' || x || ',' || y || ') 
							) AS geom, ''NA''::varchar as table_orig , num_buildings::integer
			  FROM  
				' ||	tbl_name_proj || '_geo_' || geohash_prec  || '
			  WHERE ST_Intersects( geom , 
							ST_TileEnvelope( ' || z || ',' || x || ',' || y || ') 
							)
			  LIMIT ' ||  lim || ';'
			;	
	end if;
	
	RAISE NOTICE 'SQL Code: (%)', sql_cmd;
 
	RETURN QUERY EXECUTE sql_cmd;
END;
$$
LANGUAGE 'plpgsql'
Stable
PARALLEL SAFE;
-- #
COMMENT ON FUNCTION postgisftw.mvt_geom_from_buildings IS E'Based on the zoom (z) level + x & y tile coordinates, return the features (geom) that will help create a mapbox vector tile (mvt) for the Buildings data. Mostly for debugging'