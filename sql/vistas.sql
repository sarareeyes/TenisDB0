SELECT *
FROM Matches 
WHERE duration>120
;

SELECT tournament, duration
FROM matches
WHERE tournament LIKE 'Roland Garros%'
;

SELECT c.name,m.duration
FROM matches m
JOIN players p
	ON m.winner_id=p.player_id
	JOIN people c
		ON c.person_id=p.player_id
WHERE m.tournament LIKE 'Wimbledon%'
;

SELECT AVG(duration)
FROM matches 
WHERE tournament LIKE 'Roland%'
;

SELECT winner_id, COUNT(*)
FROM matches
GROUP BY winner_id
;