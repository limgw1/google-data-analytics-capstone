SELECT 'id', 'username', 'tlrank', 'apm', 'pps', 'vs', 'tr', 'glicko', 'rd', 'gamesplayed', 'gameswon', 'verified', 'deltadate'
UNION ALL
SELECT id, username, tl_rank, apm, pps, IFNULL(vs, "N/A"), tr, glicko, rd, games_played, games_won, IFNULL(vs, "N/A"), delta_date
FROM tl_delta_table
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\tl-delta-table.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ','
ESCAPED BY '"'
LINES TERMINATED BY '\n';
