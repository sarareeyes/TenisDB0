USE TenisDB;
DELIMITER //

CREATE OR REPLACE PROCEDURE createDB()
BEGIN
		
		DROP TABLE IF EXISTS Sets;
		DROP TABLE IF EXISTS Matches;
		DROP TABLE IF EXISTS Players;
		DROP TABLE IF EXISTS Referees;
		DROP TABLE IF EXISTS People;
			
		CREATE TABLE People (
				person_id INT NOT NULL AUTO_INCREMENT,
				NAME VARCHAR(32) NOT NULL,
				age INT NOT NULL,
				nationality VARCHAR(32) NOT NULL,
				PRIMARY KEY(person_id),
				CONSTRAINT uniquePersonName UNIQUE(NAME),
				CONSTRAINT invalidAge CHECK (age >= 18)
				);
		
		CREATE TABLE Referees (
				referee_id INT NOT NULL,
				license VARCHAR(20) NOT NULL,
				PRIMARY KEY(referee_id),
				FOREIGN KEY(referee_id) REFERENCES People (person_id)
				);
				
		CREATE TABLE Players (
				player_id INT NOT NULL,
				ranking INT NOT NULL,
				PRIMARY KEY(player_id),
				FOREIGN KEY(player_id) REFERENCES People(person_id),
				CONSTRAINT invalidRanking CHECK(ranking >= 0 AND ranking <= 1000)
				);
				
		CREATE TABLE Matches (
				match_id INT NOT NULL AUTO_INCREMENT,
				referee_id INT NOT NULL,
				player1_id INT NOT NULL,
				player2_id INT NOT NULL,
				winner_id INT NOT NULL,
				tournament VARCHAR(50) NOT NULL,
				match_date DATE NOT NULL,
				round VARCHAR(20) NOT NULL,
				duration INT NOT NULL,
				PRIMARY KEY(match_id),
				FOREIGN KEY(referee_id) REFERENCES Referees(referee_id),
				FOREIGN KEY(player1_id) REFERENCES Players(player_id),
				FOREIGN KEY(player2_id) REFERENCES Players(player_id),
				FOREIGN KEY(winner_id) REFERENCES Players(player_id),
				CONSTRAINT playerNameDuplicated CHECK (player1_id != player2_id),
				CONSTRAINT winnerIsAPlayer CHECK (winner_id = player1_id OR winner_id = player2_id)
				);
		
		CREATE TABLE Sets (
				match_id INT NOT NULL,
				winner_id INT NOT NULL,
				set_order INT NOT NULL,
				score VARCHAR(10) NOT NULL,
				PRIMARY KEY(match_id, set_order),
				FOREIGN KEY(winner_id) REFERENCES Players(player_id),
				FOREIGN KEY(match_id) REFERENCES Matches(match_id) ON DELETE CASCADE,
				CONSTRAINT invalidSetOrder CHECK (set_order IN (1,2,3,4,5))
				);

END //
DELIMITER ;

CALL createDB();