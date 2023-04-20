drop function if exists postgisftw.mvt_geom_from_tax; 
-- #
CREATE OR REPLACE
FUNCTION postgisftw.mvt_geom_from_tax( z integer, x integer, y integer,
				tbl_name_proj varchar default 'postgisftw.gic_geo_role_eval_cleaned_pc_adm_da' , 					
				geom_col_name varchar default  'geom',
				max_zoom integer default 13)
RETURNS table (geom geometry, full_address varchar, 
			num_storeys integer, year_construction integer, num_dwellings integer, value_total_asset numeric, 
			frontage_m numeric, area_sq_m numeric, floor_area_main_building numeric)
AS $$
DECLARE
 	sql_cmd varchar;
	lim integer;
BEGIN

	if z < max_zoom then
		lim:= GREATEST(100, POWER(2.9, z));
	else
		lim:= 10000000; --no limit
	end if;
	
	sql_cmd :=  '
	SELECT 
		ST_MakeValid( ST_Intersection( t. ' || geom_col_name || ',
						ST_TileEnvelope( ' || z || ',' || x || ',' || y || ') 
						) ) AS geom, 
		full_address::varchar, 
		num_storeys::integer, year_construction::integer, num_dwellings::integer, 
		value_total_asset::numeric,  frontage_m::numeric, area_sq_m::numeric, floor_area_main_building::numeric
		FROM ' ||  tbl_name_proj || ' as t
		WHERE ST_Intersects(  t.' || geom_col_name || ', 
						ST_TileEnvelope( ' || z || ',' || x || ',' || y || ') 
						)
		LIMIT ' || lim || ';'
		;
		
	RAISE NOTICE 'SQL Code: (%)', sql_cmd;
 
	RETURN QUERY EXECUTE sql_cmd;
END;
$$
LANGUAGE 'plpgsql'
Stable
PARALLEL SAFE;
-- #
COMMENT ON FUNCTION postgisftw.mvt_geom_from_tax IS E'based on the zoom level, either return all tax point features (geometry) in a given tile enveloppe or a random subset of these.'