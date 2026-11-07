CREATE TABLE users
(
   userid INT PRIMARY KEY NOT NULL,
   name TEXT NOT NULL
);

CREATE TABLE movies
(
   movieid INT PRIMARY KEY NOT NULL,
   title TEXT NOT NULL
);

CREATE TABLE taginfo
(
   tagid INT PRIMARY KEY NOT NULL,
   content TEXT NOT NULL
);

CREATE TABLE genres
(
   genreid INT PRIMARY KEY NOT NULL,
   name TEXT NOT NULL
);

CREATE TABLE ratings
(
   userid INT REFERENCES users(userid),
   movieid INT REFERENCES movies(movieid),
   rating NUMERIC NOT NULL CHECK(rating>=0 AND rating<=5),
   timestamp BIGINT NOT NULL,
   PRIMARY KEY (userid, movieid)
);

CREATE TABLE tags
(
   userid INT REFERENCES users(userid),
   movieid INT REFERENCES movies(movieid),
   tagid INT REFERENCES taginfo(tagid),
   timestamp BIGINT NOT NULL,
   PRIMARY KEY (userid, movieid, tagid)
);

CREATE TABLE hasagenre
(
   movieid INT REFERENCES movies(movieid),
   genreid INT REFERENCES genres(genreid),
   PRIMARY KEY (movieid, genreid)  
);