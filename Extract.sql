
-- Notes :
-- Average number of goals per game between 1900 and 2000
-- Matches ranges from 1900-01-01 to 2000-12-31 specficilly.
-- The formula is => Goals per game = home team score + away team score ! 

-- Objectives #1 
SELECT
    COUNT(*) AS games,

    -- CAST => switch the value data type from string to integer, so we can do math on it
    SUM(CAST(home_Team_score AS INTEGER) + CAST(away_Team_score AS INTEGER)) AS total_goals,  

    ROUND(AVG(CAST(home_Team_score AS INTEGER) + CAST(away_Team_score AS INTEGER)), 2) AS avg_goals_per_game FROM results

    WHERE date BETWEEN '1900-01-01' AND '2000-12-31';


-- Objectives #2
SELECT winner AS country, COUNT(*) AS shootout_wins -- Idenify the numbers that make a team a winning team 

FROM shootouts

GROUP BY winner

ORDER BY winner;

-- Objectives #3  - Use Agile (Break the task into 4 sub-sections) - Easy to Target 
-- Rule : A reliable key to join goalscorers, results and shootouts
-- Rule : A team can't play two matches on the same day, so that combination should identify a match.

--    Check if the Rules been meet :
--      * shootouts: key is unique (0 duplicates)
--      * goalscorers -> results: 43,189 / 43,189 rows match (100%)
--      * shootouts   -> results: 561 / 562 match (1 orphan, see notes)
--      * results: 2 keys are duplicated (1974-02-17 Tahiti v New

-- Objectives #3 - Section A


--- Extracting the data that need to be focused at 
ALTER TABLE results ADD COLUMN match_key TEXT;
ALTER TABLE goalscorers ADD COLUMN match_key TEXT;
ALTER TABLE shootouts ADD COLUMN match_key TEXT;

-- Update the values triming the data through take off the while space (and lower case's) - make the data clean and uniform for the join key
UPDATE results SET match_key = LOWER(TRIM(date)) || '|' || LOWER(TRIM(home_team)) || '|' || LOWER(TRIM(away_team));
UPDATE goalscorers SET match_key = LOWER(TRIM(date)) || '|' || LOWER(TRIM(home_team)) || '|' || LOWER(TRIM(away_team));
UPDATE shootouts SET match_key = LOWER(TRIM(date)) || '|' || LOWER(TRIM(home_team)) || '|' || LOWER(TRIM(away_team));


-- Creating new values that identify as the new (Cleaned data) that will be used in the join key for the tables 
CREATE INDEX IF NOT EXISTS ix_results_key ON results(match_key);
CREATE INDEX IF NOT EXISTS ix_goalscorers_key ON goalscorers(match_key); -- Match_key is not unique in goalscorers (lost it's integrity)
CREATE UNIQUE INDEX IF NOT EXISTS ix_shootouts_key ON shootouts(match_key);



-- Objectives #3 - Section B
SELECT match_key, COUNT(*) AS n FROM results

GROUP BY match_key

HAVING COUNT(*) > 1;

-- Objectives #3 - Section C
SELECT r.match_key,
       r.date, r.home_team, r.away_team, r.home_score, r.away_score, r.tournament,
       s.winner        AS shootout_winner,
       g.team          AS scoring_team,
       g.scorer, g.minute, g.own_goal, g.penalty
FROM results r
LEFT JOIN shootouts   s ON s.match_key = r.match_key
LEFT JOIN goalscorers g ON g.match_key = r.match_key;

-- 3d. Orphan check: shootouts with no matching result
SELECT s.*
FROM shootouts s
LEFT JOIN results r ON r.match_key = s.match_key
WHERE r.match_key IS NULL;



-- Objective 4

-- 4a. Every match: which team won the shootout after a 1-1
SELECT r.date, r.home_team, r.away_team, r.home_score, r.away_score,
       r.tournament, s.winner AS shootout_winner
FROM shootouts s
JOIN results  r ON r.match_key = s.match_key
WHERE CAST(r.home_score AS INTEGER) = 1
  AND CAST(r.away_score AS INTEGER) = 1
ORDER BY r.date;


-- 4b. Distinct list of teams, with how many times each did it
SELECT s.winner AS team,
       COUNT(*) AS shootout_wins_after_1_1
FROM shootouts s
JOIN results  r ON r.match_key = s.match_key
WHERE CAST(r.home_score AS INTEGER) = 1
  AND CAST(r.away_score AS INTEGER) = 1
GROUP BY s.winner
ORDER BY shootout_wins_after_1_1 DESC, team;
