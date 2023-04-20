
library(magrittr)
library(dplyr)

# --- Connect as read only user  ---

conn_ro <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname=Sys.getenv("POSTGRES_DBNAME"),
  host = 'localhost',
  user = Sys.getenv("POSTGRES_USER_RO"),
  password = Sys.getenv("POSTGRES_PASSWORD_RO"),
  port= Sys.getenv("POSTGRES_PORT")
)

# from pg tile serv source
# From https://github.com/CrunchyData/pg_featureserv/blob/master/internal/data/db_sql.go

query_tbl_check <- "SELECT
  Format('%s.%s', n.nspname, c.relname) AS id,
  n.nspname AS schema,
  c.relname AS table,
  coalesce(d.description, '') AS description,
  a.attname AS geometry_column,
  postgis_typmod_srid(a.atttypmod) AS srid,
  postgis_typmod_type(a.atttypmod) AS geometry_type,
  coalesce(ia.attname, '') AS id_column,
  (
    SELECT array_agg(ARRAY[sa.attname, st.typname, coalesce(da.description,''), sa.attnum::text]::text[] ORDER BY sa.attnum)
    FROM pg_attribute sa
    JOIN pg_type st ON sa.atttypid = st.oid
    LEFT JOIN pg_description da ON (c.oid = da.objoid and sa.attnum = da.objsubid)
    WHERE sa.attrelid = c.oid
    AND sa.attnum > 0
    AND NOT sa.attisdropped
    AND st.typname NOT IN ('geometry', 'geography')
  ) AS props
  FROM pg_class c
  JOIN pg_namespace n ON (c.relnamespace = n.oid)
  JOIN pg_attribute a ON (a.attrelid = c.oid)
  JOIN pg_type t ON (a.atttypid = t.oid)
  LEFT JOIN pg_description d ON (c.oid = d.objoid AND d.objsubid = 0)
  LEFT JOIN pg_index i ON (c.oid = i.indrelid AND i.indisprimary
                           AND i.indnatts = 1)
  LEFT JOIN pg_attribute ia ON (ia.attrelid = i.indexrelid)
  LEFT JOIN pg_type it ON (ia.atttypid = it.oid AND it.typname in ('int2', 'int4', 'int8'))
  WHERE c.relkind IN ('r', 'v', 'm', 'p', 'f')
  AND t.typname IN ('geometry', 'geography')
  AND has_table_privilege(c.oid, 'select')
  AND postgis_typmod_srid(a.atttypmod) > 0
  ORDER BY id;
  "
  
tbl_results <- RPostgres::dbGetQuery(
  conn = conn_ro,
  statement = query_tbl_check
)

tbl_results %>% glimpse

tbl_results$table
