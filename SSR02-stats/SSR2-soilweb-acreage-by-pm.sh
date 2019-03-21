## 2018-08-24
## D.E. Beaudette
##
## prepare area stats on pmkind | pmorigin for SSR2 components
##

# get table from arguments
# should be pmorigin | pmkind
var=$1


# pre-filter component data
# ~ 7 seconds pmkind
psql -U postgres ssurgo_combined <<EOF

DROP TABLE IF EXISTS soilweb.ssr2_comp_data_${var};
CREATE TABLE soilweb.ssr2_comp_data_${var} AS
WITH comp_data AS (
select DISTINCT ON (cokey, ${var}) mukey, cokey, compname, comppct_r, majcompflag, copmgrpkey, ${var}, rvindicator 
FROM 
ssurgo.component
-- keep only SSR2 MU
JOIN soilweb.ssr2_mu USING (mukey)
JOIN ssurgo.copmgrp USING (cokey) 
JOIN ssurgo.copm USING (copmgrpkey) 
WHERE majcompflag = 'Yes'
AND compkind != 'Miscellaneous area'
AND rvindicator = 'Yes'
ORDER BY cokey, ${var}, comppct_r DESC
)
SELECT mukey, ${var}, sum(comppct_r/100.00) as pct
FROM comp_data
GROUP BY mukey, ${var};

CREATE INDEX ssr2_comp_data_${var}_idx ON soilweb.ssr2_comp_data_${var} (mukey);
VACUUM ANALYZE soilweb.ssr2_comp_data_${var};

-- remove rows with missing ${var} data
DELETE FROM soilweb.ssr2_comp_data_${var} WHERE ${var} IS NULL;
VACUUM ANALYZE soilweb.ssr2_comp_data_${var};

EOF

# move any previously computed stats to backup file
if [ -f ${var}-stats.txt ]; then
	echo "saving existing stats file"
    mv ${var}-stats.txt ${var}-stats-old.txt
fi


# compute stats by ${var}
# ~1 hour run in parallel (8 cores)

echo "select DISTINCT ${var} from soilweb.ssr2_comp_data_${var}" | psql -U postgres ssurgo_combined -t -A > ${var}-list-for-stats

cat ${var}-list-for-stats | parallel --eta --progress -q bash -c "echo \"SELECT ${var}, ROUND((SUM(pct * ST_Area(wkb_geometry::geography)) * 0.000247105)::numeric)::bigint AS ac, COUNT(wkb_geometry) as n_polygons FROM ssurgo.mapunit_poly JOIN soilweb.ssr2_comp_data_${var} USING (mukey) WHERE ssr2_comp_data_${var}.${var} = '{}' GROUP BY ${var}\" | psql -U postgres ssurgo_combined -t -A >> ${var}-stats.txt"

# compress
gzip ${var}-stats.txt

# cleanup
echo "DROP TABLE IF EXISTS soilweb.ssr2_comp_data_${var};" | psql -U postgres ssurgo_combined

