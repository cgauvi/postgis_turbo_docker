drop function if exists public.create_agg_geohash_tbl;
-- #
CREATE OR REPLACE
FUNCTION public.create_agg_geohash_tbl( geohash_prec integer,
									   tbl_name varchar default 'public.building_footprints_open_data' , 	
									   geom_col_name varchar default  'geom'
									  )
RETURNS void 
AS $$
DECLARE
 	sql_cmd varchar;
	lim integer;
BEGIN
 	sql_cmd :=  '
	create table postgisftw.building_footprints_open_data_proj_geo_' || geohash_prec || ' as
	(
		with geohash_tbl as
		(
			SELECT 
			ST_GeoHash(
						st_envelope(
							ST_Transform( ' || geom_col_name || ' ,4326)
						), ' || geohash_prec || ') as geohash,
			 ST_Transform(
				ST_SetSRID(
				ST_GeomFromGeoHash(
					ST_GeoHash(
						st_envelope(
							ST_Transform( ' || geom_col_name || ',4326)
						), ' || geohash_prec || ')
				),4326),
				3857) as geom
			from '  || tbl_name || '
		)
		select count(*) as num_buildings, geom, geohash
		from geohash_tbl
		group by geom, geohash
		order by num_buildings desc
	);';
	RAISE NOTICE 'SQL Code: (%)', sql_cmd;
	EXECUTE sql_cmd;
 
	sql_cmd := 'create INDEX  if not exists postgisftw.building_footprints_open_data_proj_geo_' || geohash_prec || ' _idx 
	ON postgisftw.building_footprints_open_data_proj_geo_' || geohash_prec || '
	USING GIST(geom);';
	EXECUTE sql_cmd;
END;
$$
LANGUAGE 'plpgsql'
VOLATILE
PARALLEL SAFE;
-- #
COMMENT ON FUNCTION public.create_agg_geohash_tbl IS E'Aggregate features at a given geohash level';
-- # 
-- Create the tables in postgisftw
-- Cant revoke select on them, but will not be accesible via pg feature serv if geom type is Geometry Collection.. 
drop table if exists postgisftw.building_footprints_open_data_proj_geo_7;
drop table if exists postgisftw.building_footprints_open_data_proj_geo_6;
drop table if exists postgisftw.building_footprints_open_data_proj_geo_3;
drop table if exists postgisftw.building_footprints_open_data_proj_geo_4;
drop table if exists postgisftw.building_footprints_open_data_proj_geo_5;
-- #
-- These wont be acesible via pg feature serv since they reside in public
select public.create_agg_geohash_tbl(6);
select public.create_agg_geohash_tbl(7);
select public.create_agg_geohash_tbl(5);
select public.create_agg_geohash_tbl(4);
select public.create_agg_geohash_tbl(3);
-- #
drop table if exists postgisftw.building_footprints_open_data_proj;
-- #
create table postgisftw.building_footprints_open_data_proj as
(
	select st_multi(
		st_collectionextract(
			ST_MakeValid(
				ST_Transform(geom ,3857)
			), 3)
		) as geom, gid_origin, table_orig
	from public.building_footprints_open_data
);
-- #
ALTER TABLE postgisftw.building_footprints_open_data_proj
ALTER COLUMN geom type geometry(MultiPolygon, 3857); 
-- #
create INDEX if not exists building_footprints_open_data_proj_idx 
ON postgisftw.building_footprints_open_data_proj
USING GIST(geom);
-- #
grant select on postgisftw.building_footprints_open_data_proj to generic_ro_user;
 
