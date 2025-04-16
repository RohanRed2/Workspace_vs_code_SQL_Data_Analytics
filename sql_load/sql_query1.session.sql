CREATE TABLE Test(Id INT , FirstName varchar(10), Present BOOLEAN)

INSERT INTO Test
VALUES (1, 'Rohan' , True), (2, 'Rahul', False)

INSERT INTO Test
VALUES (3, 'Mohan' , true)

SELECT * FROM Test

ALTER table Test ADD COLUMN LastName VARCHAR(10);
Alter table Test ALTER COLUMN LastName TYPE TEXT;