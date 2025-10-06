CREATE TABLE IF NOT EXISTS artifacts (
    code VARCHAR(20),
    name VARCHAR(50) NOT NULL,
    img VARCHAR(500) NOT NULL,
    PRIMARY KEY (code)

);

CREATE TABLE IF NOT EXISTS matched (
    code VARCHAR(20),
    name VARCHAR(50) NOT NULL,
    img VARCHAR(500) NOT NULL,
    PRIMARY KEY (code)
);

INSERT INTO artifacts VALUES ('shell1','Angel Wings', 'https://upload.wikimedia.org/wikipedia/commons/0/07/Cyrtopleura_costata_13a.jpg');
INSERT INTO artifacts VALUES ('shell2','Scallops', 'https://www.shells-of-aquarius.com/images/irish-flat-scallops.jpg');
INSERT INTO artifacts VALUES ('shell3','Rose Petal Tellin', 'https://www.shells-of-aquarius.com/images/sunrise_tellina.jpg');
INSERT INTO artifacts VALUES ('shell4','Pear Whelk', 'https://upload.wikimedia.org/wikipedia/commons/7/7b/Fulguropsis_spirata_pahayokee_01.JPG');
INSERT INTO artifacts VALUES ('shell5','Nutmeg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Cancellaria_reticulata_01.JPG/1200px-Cancellaria_reticulata_01.JPG');