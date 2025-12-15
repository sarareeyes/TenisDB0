
USE TenisDB;

CREATE OR REPLACE TABLE test_results(
	test_id VARCHAR(20) NOT NULL PRIMARY KEY,
	test_name VARCHAR(200) NOT NULL,
	test_message VARCHAR(500) NOT NULL,
	test_status ENUM('PASS','FAIL','ERROR') NOT NULL,
	execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
	
	
delimiter //
CREATE OR REPLACE PROCEDURE p_log_test(
	IN p_test_id VARCHAR(20),
	IN p_message VARCHAR(500),
	IN p_status ENUM('PASS','FAIL','ERROR')
)
BEGIN 
	INSERT INTO test_results (test_id, test_name, test_message, test_status)
	VALUES (p_test_id,SUBSTRING_INDEX(p_message,':',1), p_message, p_status);
END //
delimiter ;


delimiter //
CREATE OR REPLACE PROCEDURE p_test_rn02_adult_age()
BEGIN
	DECLARE EXIT handler FOR SQLEXCEPTION 
		CALL p_log_test('RN-02', 'RN-02: No se permiten personas menores de 18 años' , 'PASS');
		
	CALL p_populate_db();
	INSERT INTO people (NAME, age, nationality) VALUES ('Young Player', 17, 'España');
	CALL p_log_test('RN-02', 'ERROR: Se insertó una persona menor de edad','FAIL');
	
END //
delimiter ;

delimiter //
CREATE OR REPLACE PROCEDURE p_test_rn03_unique_name()
BEGIN 
	DECLARE exit handler FOR sqlexception
		CALL p_log_test('RN-03','RN-03: No se puede repetir el nombre','PASS');
		
	CALL p_populate_db();
	INSERT INTO people (NAME,age,nationality) VALUES ('Carlos Alcaraz',22,'España');
	CALL p_log_test('RN-03', 'ERROR: Se insertó un nombre duplicado','FAIL');
	
END //
delimiter ;

delimiter // 
CREATE OR REPLACE PROCEDURE p_test_rn04_zero_ranking()
BEGIN
	DECLARE exit handler FOR sqlexception
		CALL p_log_test('RN-04A','RN-04A: El ranking no puede ser negativo','PASS');
	
	CALL p_populate_db();
	INSERT INTO people (person_id, NAME, age, nationality) VALUES (19,'Young Man', 18, 'England');
	INSERT INTO players (player_id, ranking) VALUES (19, -1);
	CALL p_log_test('RN-04A','Error: Se insertó un ranking negativo','FAIL');
	
END //
delimiter ;

delimiter // 
CREATE OR REPLACE PROCEDURE p_test_rn04_invalid_ranking()
BEGIN
	DECLARE exit handler FOR sqlexception
		CALL p_log_test('RN-04B','RN-04B: El ranking no puede ser superior a 1000','PASS');
	
	CALL p_populate_db();
	INSERT INTO people (person_id, NAME, age, nationality) VALUES (20,'Old Man', 31, 'England');
	INSERT INTO players (player_id, ranking) VALUES (20, 1500);
	CALL p_log_test('RN-04B','Error: Se insertó un ranking superior a 1000','FAIL');
		
END //
delimiter ;
	
delimiter //
CREATE OR REPLACE PROCEDURE p_test_rn05_same_player()
BEGIN 
	DECLARE exit handler FOR sqlexception
		CALL p_log_test('RN-05','RN-05: Un jugador no puede jugar contra sí mismo','PASS');
		
	CALL p_populate_db();
	INSERT INTO matches (match_id, referee_id, player1_id, player2_id, winner_id, tournament, match_date, round, duration) 
		VALUES (17,17,2, 2,2,'Roland Garros','2025-02-25', 'Semifinal', 60);
	CALL p_log_test('RN-05','RN-05: Se insertó un partido en el que un jugador juega contra sí mismo','FAIL');
	
END //
delimiter ;

delimiter //
CREATE OR REPLACE PROCEDURE p_test_rn06_max_matches_referee()
BEGIN
 	DECLARE exit handler FOR sqlexception
		CALL p_log_test('RN-06','RN-06: Un árbitro no puede jugar más de 3 partidos en un día','PASS');
	
	CALL p_populate_db();
	INSERT INTO matches (match_id, referee_id, player1_id, player2_id, winner_id, tournament, match_date, round, duration)
        VALUES (18, 16, 1, 10, 10, 'Queens Club 2025', '2025-06-15', 'Final', 95);
   
   INSERT INTO matches (match_id, referee_id, player1_id, player2_id, winner_id, tournament, match_date, round, duration)
        VALUES (19, 16, 5, 6, 6, 'Roland Garros', '2025-06-15', 'Cuartos de final', 115);
   
   INSERT INTO matches (match_id, referee_id, player1_id, player2_id, winner_id, tournament, match_date, round, duration)
        VALUES (20, 16, 3, 5, 3, 'Indian Wells 2025', '2025-06-15', 'Semifinal', 105);
   
	INSERT INTO matches (match_id, referee_id, player1_id, player2_id, winner_id, tournament, match_date, round, duration)
        VALUES (21, 16, 2, 4, 2, 'Indian Wells 2025', '2025-06-15', 'Semifinal', 105);
	CALL p_log_test('RN-06','RN-06: Se insertaron más de 3 partidos un mismo día con el mismo árbitro','FAIL');

END //
delimiter ;

delimiter //
CREATE OR REPLACE PROCEDURE p_test_rn07_referee_nationality()
BEGIN
	DECLARE exit handler FOR sqlexception
		CALL p_log_test ('RN-07','RN-07: Un árbitro no puede tener la misma nacionalidad que los jugadores','PASS');
		
	CALL p_populate_db();
	INSERT INTO matches (match_id, referee_id, player1_id, player2_id, winner_id, tournament, match_date, round, duration)
        VALUES (22, 7, 3, 5, 3, 'Indian Wells 2025', '2025-12-15', 'Semifinal', 105);
   CALL p_log_test('RN-07','RN-07: Se permitió insertar un partido con nacionalidad coincidente','FAIL');

END //
delimiter ;

delimiter //
CREATE OR REPLACE PROCEDURE p_test_sets_invalid_winner()
BEGIN 
	DECLARE exit handler FOR sqlexception
		CALL p_log_test ('IW','IW: No puede ganar el partido alguien que no lo juega','PASS');
	
	CALL p_populate_db();	
	INSERT INTO matches (match_id, referee_id, player1_id, player2_id, winner_id, tournament, match_date, round, duration)
        VALUES (23, 15, 3, 5, 6, 'Indian Wells 2025', '2025-12-15', 'Semifinal', 105);
	CALL p_log_test('IW','IW: Se insertó un ganador del partido incorrecto','FAIL');

END //
delimiter ;
	
delimiter //
CREATE OR REPLACE PROCEDURE p_test_sets_max_5_sets()
BEGIN 
	DECLARE exit handler FOR sqlexception
		CALL p_log_test ('M5S','M5S: Un partido no puede tener más de 5 sets','PASS');
	
	CALL p_populate_db();
	INSERT INTO matches (match_id, referee_id, player1_id, player2_id, winner_id, tournament, match_date, round, duration)
        VALUES (24, 16, 1, 2, 1, 'Wimbledon 2026', '2026-07-14', 'Final', 240);
   INSERT INTO sets (match_id, winner_id, set_order, score) VALUES
        (24, 1, 1, '6-4'),
        (24, 2, 2, '4-6'),
        (24, 1, 3, '7-6'),
        (24, 2, 4, '3-6'),
        (24, 1, 5, '6-3'),
        (24, 1, 6, '6-4');
	CALL p_log_test('M5S','M5S: Se permitió insertar un sexto set','FAIL');

END //
delimiter ;

delimiter //
CREATE OR REPLACE PROCEDURE p_run_all_tests()
BEGIN
	DELETE from test_results;
	CALL p_test_rn02_adult_age();
	CALL p_test_rn03_unique_name();
	CALL p_test_rn04_invalid_ranking();
	CALL p_test_rn04_zero_ranking();
	CALL p_test_rn05_same_player();
	CALL p_test_rn06_max_matches_referee();
	CALL p_test_rn07_referee_nationality();
	CALL p_test_sets_invalid_winner();
	CALL p_test_sets_max_5_sets();
	
	SELECT * FROM test_results ORDER BY execution_time, test_id;
	
	SELECT test_status, COUNT(*) AS COUNT FROM test_results GROUP BY test_status;
END //
delimiter ;

CALL p_run_all_tests();