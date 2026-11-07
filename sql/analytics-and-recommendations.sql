--Query1

CREATE TABLE query1 AS
SELECT g.name AS name, COUNT(*) as moviecount
FROM hasagenre h, genres g 
WHERE h.genreid=g.genreid 
GROUP BY g.name;






--Query2

CREATE TABLE query2 AS
SELECT g.name AS name, AVG(r.rating) as rating 
FROM genres g, ratings r, hasagenre h 
WHERE g.genreid=h.genreid AND h.movieid=r.movieid 
GROUP BY g.name;






--Query3

CREATE TABLE query3 AS	
 SELECT m.title as title, COUNT(*) as countofratings
 FROM movies m, ratings r 
 WHERE m.movieid=r.movieid 
 GROUP BY m.movieid 
 HAVING COUNT(*)>=10;




 --Query 4

 CREATE TABLE query4 AS
 SELECT m.movieid as movieid, m.title as title
 FROM movies m, genres g, hasagenre h
 WHERE m.movieid=h.movieid AND h.genreid=g.genreid AND g.name='Comedy';
 

 

 --Query 5

 CREATE TABLE query5 AS
 SELECT m.title as title, AVG(r.rating) as average
 FROM movies m, ratings r
 WHERE m.movieid = r.movieid
 GROUP BY m.title;
 




 --Query 6
 CREATE TABLE query6 AS
 SELECT AVG(r.rating) AS average
 FROM  ratings r, genres g, hasagenre h
 WHERE r.movieid = h.movieid AND h.genreid=g.genreid AND g.name='Comedy';
 

 
--Query 7
CREATE TABLE query7 AS
SELECT AVG(r.rating) AS average
FROM ratings r, hasagenre h1, hasagenre h2, genres g1, genres g2 
WHERE h1.movieid=h2.movieid AND h1.genreid=g1.genreid AND g1.name = 'Comedy' AND h2.genreid = g2.genreid AND g2.name = 'Romance' AND r.movieid = h1.movieid ;
	




--Query 8
CREATE TABLE query8 AS
SELECT AVG(r3.rating) AS average
FROM ratings r3
WHERE r3.movieid IN (
SELECT r1.movieid
FROM ratings r1, hasagenre h1, genres g1
WHERE h1.genreid = g1.genreid AND g1.name='Romance' AND r1.movieid = h1.movieid
EXCEPT
SELECT r2.movieid
FROM ratings r2, hasagenre h2, genres g2
WHERE h2.genreid = g2.genreid AND g2.name = 'Comedy' AND r2.movieid = h2.movieid
);





--Query 9
CREATE TABLE query9 AS
SELECT r.movieid as movieid, r.rating as rating
FROM ratings r WHERE r.userid = :v1;






--Query10

CREATE OR REPLACE VIEW CalAvgRating AS
SELECT r.movieid AS movieid, AVG(r.rating) AS avgrating
FROM ratings r
GROUP BY r.movieid;


CREATE OR REPLACE VIEW rated AS
(SELECT r.movieid AS id,r.rating AS rating FROM ratings r WHERE r.userid = :v1);

CREATE OR REPLACE VIEW notrated AS
SELECT m.movieid as id
FROM  movies m
WHERE m.movieid NOT IN (SELECT r.movieid FROM ratings r WHERE r.userid = :v1);



CREATE OR REPLACE VIEW similarity AS 
(SELECT r1.movieid AS movieid1, r2.movieid as movieid2,  (1-(abs(r1.avgrating-r2.avgrating)/5)) as sim
FROM  CalAvgRating r1, CalAvgRating r2
WHERE r1.movieid != r2.movieid);


CREATE OR REPLACE VIEW CalPredRating AS
SELECT s.movieid1 AS movieid,  
CASE 
SUM(s.sim) WHEN 0.0 THEN 0.0
ELSE
SUM(s.sim * r.rating)/SUM(s.sim) 
END
AS rating
FROM similarity s, rated r
WHERE s.movieid2 = r.id AND s.movieid1 IN (SELECT id FROM notrated)
GROUP BY (s.movieid1)
ORDER BY rating DESC;

CREATE TABLE recommendation as
(SELECT title
FROM movies m, CalPredRating pred
WHERE m.movieid = pred.movieid AND pred.rating > 3.90);















