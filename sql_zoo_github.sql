-- https://sqlzoo.net/wiki/The_JOIN_operation
-- 1.
SELECT matchid, player FROM goal
  WHERE teamid = 'GER'
-- 2.
SELECT id,stadium,team1,team2
  FROM game
where id in (select matchid
                   from goal
                   where player  like '%bender%')
-- 3.
SELECT player, teamid, stadium , mdate
  FROM game
JOIN goal
ON game.id=goal.matchid
WHERE goal.teamid = 'GER'
-- 4.
SELECT game.team1,game.team2, goal.player
FROM game
JOIN goal
ON game.id = goal.matchid
WHERE goal.player LIKE 'Mario%'
-- 5.
SELECT goal.player,goal.teamid, eteam.coach, goal.gtime
FROM goal
JOIN eteam
ON goal.teamid= eteam.id
WHERE gtime <= 10
-- 6.
SELECT game.mdate, eteam.teamname
FROM game
JOIN eteam
ON game.team1 = eteam.id
WHERE eteam.coach = 'Fernando Santos'
-- 7.
SELECT goal.player
FROM goal
JOIN game
ON goal.matchid=game.id
WHERE game.stadium = 'National Stadium, Warsaw'
-- 8.
SELECT player, gtime
  FROM game JOIN goal ON matchid = id
    WHERE (team1='GER' AND team2='GRE')
-- 9.
SELECT eteam.teamname, count(goal.teamid) as total
FROM eteam
JOIN goal
ON eteam.id = goal.teamid
GROUP BY 1
-- 10.
SELECT stadium, COUNT(matchid)
FROM game
JOIN goal
ON game.id=goal.matchid
GROUP BY 1
-- 11.
SELECT goal.matchid,  game.mdate,COUNT(*)
FROM game
JOIN goal
ON game.id = goal.matchid
WHERE game.team1 ='POL' or game.team2='POL'
GROUP BY 1,2
-- 12.
SELECT goal.matchid, game.mdate, COUNT(*)
FROM goal
JOIN game
ON game.id = goal.matchid
WHERE goal.teamid = 'GER'
GROUP BY 1,2
-- 13.
SELECT mdate,
 team1,
  SUM(CASE WHEN teamid=team1 THEN 1 ELSE 0 END)  score1,
team2,
 SUM(CASE  WHEN teamid = team2 THEN 1 ELSE 0 END) score2

FROM game
LEFT JOIN goal
ON goal.matchid = game.id
GROUP BY mdate,team1,team2
ORDER BY mdate, matchid, team1, team2


-- https://sqlzoo.net/wiki/SELECT_within_SELECT_Tutorial
-- 5. Show the name and the population of each country in Europe. Show the population as a percentage of the population of Germany.
SELECT name, CONCAT(ROUND(population/(SELECT population FROM world WHERE name = 'Germany')*100), '%') FROM world WHERE continent = 'Europe';
-- 6. Which countries have a GDP greater than every country in Europe? [Give the name only.] (Some countries may have NULL gdp values)
SELECT name
FROM world
where gdp > (SELECT gdp FROM world
             WHERE continent ='Europe' AND gdp >0
             ORDER BY gdp DESC
             LIMIT 1)

-- 7.  Find the largest country (by area) in each continent, show the continent, the name and the area:
SELECT continent, name, area
FROM world
WHERE area IN  (
SELECT max(area)
FROM world
GROUP By continent)
-- 8. List each continent and the name of the country that comes first alphabetically.
SELECT continent, MIN(name) AS name
FROM world
GROUP BY continent
ORDER by continent



-- 9. Find the continents where all countries have a population <= 25000000. Then find the names of the countries associated with these continents. Show name, continent and population.

SELECT name, continent, population
FROM world
WHERE continent IN
(SELECT continent
FROM world
GROUP BY continent
HAVING MAX(population) <= 25000000 )
-- 10. Some countries have populations more than three times that of any of their neighbours (in the same continent). Give the countries and continents.
SELECT name, continent
FROM world x
WHERE population > ALL
(SELECT population*3
FROM world y
WHERE x.continent = y.continent AND x.name != y.name
AND population >0)     --synchronized sub-queries

-- https://sqlzoo.net/wiki/More_JOIN_operations
-- 10. List the films together with the leading star for all 1962 films.
SELECT movie.title, actor.name
FROM movie
JOIN casting
ON casting.movieid= movie.id
JOIN actor
ON actor.id= casting.actorid
WHERE movie.yr=1962 and casting.ord =1

-- 11. Which were the busiest years for 'John Travolta', show the year and the number of movies he made each year for any year in which he made more than 2 movies.
SELECT sub.yr, COUNT(sub.id) as new
FROM (SELECT movie.yr,movie.id
     FROM movie
    JOIN casting
   ON casting.movieid = movie.id
   WHERE casting.actorid = (SELECT id FROM actor WHERE name = 'John Travolta')
) as sub

GROUP BY 1
HAVING COUNT(sub.id) > 2
-- 12. List the film title and the leading actor for all of the films 'Julie Andrews' played in.
SELECT movie.title, actor.name
FROM movie
JOIN casting
ON movie.id=casting.movieid
JOIN actor
ON actor.id = casting.actorid

WHERE movie.id in
(SELECT movieid
FROM casting
WHERE casting.actorid  =   (SELECT id FROM actor
       WHERE name = 'Julie Andrews')
) and casting.ord=1

-- 13. Obtain a list, in alphabetical order, of actors who've had at least 30 starring roles.

SELECT actor.name
FROM actor
JOIN
(SELECT actorid, COUNT(movieid) as counts
FROM casting
WHERE ord =1
GROUP BY actorid
HAVING COUNt(movieid) >= 30 ) sub
ON actor.id = sub.actorid
ORDER BY 1

-- 14. List the films released in the year 1978 ordered by the number of actors in the cast, then by title.
SELECT title, COUNT(actorid)
FROM movie
JOIN casting
ON movie.id = casting.movieid
WHERE yr = 1978
GROUP BY title
ORDER BY COUNT(actorid) DESC

-- 15. List all the people who have worked with 'Art Garfunkel'.

SELECT distinct name
FROM actor
JOIN casting
ON actor.id = casting.actorid
WHERE casting.movieid in
(SELECT movieid FROM casting JOIN actor ON actor.id = casting.actorid
WHERE actor.name = 'Art Garfunkel') and name !='Art Garfunkel'

-- Self join https://sqlzoo.net/wiki/Self_join
-- 9. Give a distinct list of the stops which may be reached from 'Craiglockhart' by taking one bus, including 'Craiglockhart' itself, offered by the LRT company. Include the company and bus no. of the relevant services.
SELECT stopb.name, a.company,a.num
FROM route a JOIN route b ON (a.company = b.company AND a.num = b.num)
JOIN stops stopa ON stopa.id = a.stop
JOIN stops stopb ON stopb.id = b.stop
WHERE a.company = 'LRT' and stopa.name = 'Craiglockhart'
