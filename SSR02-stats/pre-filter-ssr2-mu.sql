
-- prep SSR2 outline
-- ogr2ogr -t_srs EPSG:4326 ssr2_outline-gcs.shp ssr2_outline.shp

-- load
-- shp2pgsql -s 4326 -c -I -S ssr2_outline-gcs.shp dylan.ssr2 | psql -U postgres ssurgo_combined

DROP TABLE IF EXISTS soilweb.ssr2_mu;

CREATE TABLE soilweb.ssr2_mu AS
SELECT DISTINCT mukey 
FROM ssurgo.mapunit_poly
JOIN dylan.ssr2 ON ST_Contains(ssr2.geom, mapunit_poly.wkb_geometry);

CREATE INDEX ssr2_mu_idx ON soilweb.ssr2_mu (mukey);
VACUUM ANALYZE soilweb.ssr2_mu;

--
-- there should be ~ 194979969 ac. in the SSR2 outline
--
