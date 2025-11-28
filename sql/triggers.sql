delimiter //
CREATE OR REPLACE TRIGGER referees_3_matches_max
BEFORE INSERT ON 	Matches
FOR EACH ROW
BEGIN 
	DECLARE num_partidos INT; -- declaramos variables que vamos a usar
	
	SELECT COUNT(*) INTO num_partidos -- hacemos un select y lo guardamos en esa variable
	FROM Matches
	WHERE referee_id = NEW.referee_id	-- en la columna (referee_id), el valor a insertar (new.referee_id)
      AND match_date = NEW.match_date;
	
	if num_partidos>=3 then			
	SIGNAL SQLSTATE '45000'											-- código de error más común para indicar que una regla de negocio ha sido violada.
	SET MESSAGE_TEXT = 'El árbitro ya tiene 3 partidos';	-- texto que se mostrará al usuario (excepcion q salta)
	END if;
END//

delimiter ;
	
delimiter //
CREATE OR REPLACE TRIGGER nationalities_duplicated		
BEFORE INSERT ON matches
FOR EACH ROW
BEGIN 
	DECLARE referee_nat VARCHAR(32);
	DECLARE player1_nat VARCHAR(32);
	DECLARE player2_nat VARCHAR(32);
	
	SELECT nationality INTO referee_nat
	FROM people 
	WHERE person_id= NEW.referee_id;
	
	
	SELECT nationality INTO player1_nat
	FROM people 
	WHERE person_id= NEW.player1_id;
	
	SELECT nationality INTO player2_nat
	FROM people 
	WHERE person_id= NEW.player2_id;
	
	if referee_nat = player1_nat OR referee_nat = player2_nat then
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Las nacionalidades de los jugadores no pueden coincidir con la del árbitro';
	END if;
END //
delimiter ;
	