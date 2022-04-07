-- DROP TABLE tl_delta_table;
CREATE TABLE tl_delta_table(id CHAR(24),
			    username CHAR(16),
			    apm DECIMAL(5,2),
			    pps DECIMAL(5,2),
			    vs DECIMAL(5,2),
			    raw_eff FLOAT,
			    adjusted_eff FLOAT,
			    app FLOAT,
			    adjusted_app FLOAT,
			    tr DOUBLE,
			    tl_rank CHAR(2),
			    glicko DOUBLE,
			    rd TINYINT unsigned,
			    games_played INT unsigned,
			    games_won INT unsigned,
			    verified BOOLEAN,
			    delta_date DATETIME
			   )
