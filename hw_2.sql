-- remove all previous databases
DROP TABLE IF EXISTS Enrolled;
DROP TABLE IF EXISTS Class;
DROP TABLE IF EXISTS Faculty;
DROP TABLE IF EXISTS Student;

-- create the relations (GQ4)
CREATE TABLE Student (
    snum INT PRIMARY KEY,
    sname VARCHAR(64) NOT NULL,
    major VARCHAR(64),
    slevel VARCHAR(64) NOT NULL,
    age INT NOT NULL,

    CONSTRAINT CHK_slevel CHECK (slevel IN ('FR', 'SF', 'JR', 'SR'))
);

CREATE TABLE Faculty (
    fid INT PRIMARY KEY,
    fname VARCHAR(64) NOT NULL,
    deptid INT NOT NULL,
    salary REAL NOT NULL
)

CREATE TABLE Class (
    cname VARCHAR(64) PRIMARY KEY,
    meets_at VARCHAR(64) NOT NULL,
    room VARCHAR(64) NOT NULL,
    fid INT NOT NULL,

    CONSTRAINT FK_faculty FOREIGN KEY (fid) REFERENCES Faculty
);

CREATE TABLE Enrolled (
    snum INT,
    cname VARCHAR(64),

    CONSTRAINT PK_enrollment PRIMARY KEY (snum, cname),

    CONSTRAINT FK_student FOREIGN KEY (snum) REFERENCES Student,
    CONSTRAINT FK_class FOREIGN KEY (cname) REFERENCES Class
);

-- populate the values (GQ5)
INSERT INTO Student
VALUES
    (1, 'Adams', 'History', 'FR', 18),
    (2, 'Bethany', 'History', 'FR', 20),
    (3, 'Adams', 'CS', 'SF', 20),
    (4, 'Codd', 'CS', 'SF', 22),
    (5, 'Daniels', 'ECE', 'JR', 22),
    (6, 'Daniels', 'CS', 'JR', 24),
    (7, 'Gordon', 'ECE', 'SR', 24),
    (8, 'Smith', 'Physics', 'SR', 26);

INSERT INTO Faculty
VALUES
    (101, 'Johnson', 10, 55000),
    (102, 'Lynn', 10, 65000),
    (103, 'Lynn', 12, 30000),
    (104, 'Black', 11, 32000);

INSERT INTO Class
VALUES
    ('Intro to Java', 'W 13:30', 'R128', 102),
    ('CS 4513', 'F 12:00', 'K53', 102),
    ('Intro to Pascal', 'F 09:00', 'S217', 102),
    ('Data structures', 'W 13:30', 'S217', 103),
    ('Advanced Java', 'M 15:30', 'R128', 103),
    ('Data Networks', 'M 15:30', 'S217', 101),
    ('Operating Systems', 'F 09:00', 'K53', 103),
    ('Intro to Compilers', 'M 14:30', 'K53', 101),
    ('Computer Architecture', 'W 08:00', 'R128', 101),
    ('Software engineering', 'W 10:00', 'R128', 104);

INSERT INTO Enrolled
VALUES
    (4, 'Data Networks'),
    (5, 'Data Networks'),
    (6, 'Intro to Compilers'),
    (4, 'Intro to Compilers'),
    (5, 'Intro to Compilers'),
    (1, 'Intro to Compilers'),
    (2, 'Intro to Compilers'),
    (3, 'Intro to Compilers'),
    (4, 'Advanced Java');

-- a load of queries (GQ6)
-- 1. Display all the data you store in the database to verify that you have populated the relations correctly
SELECT * FROM Student
JOIN Enrolled ON Student.snum = Enrolled.snum
JOIN Class ON Enrolled.cname = Class.cname
JOIN Faculty ON Class.fid = Faculty.fid;

-- 2. Find the names of all Juniors (slevel = JR) who are enrolled in a class taught by Johnson
SELECT DISTINCT sname FROM Student
JOIN Enrolled ON Student.snum = Enrolled.snum
JOIN Class ON Enrolled.cname = Class.cname
JOIN Faculty ON Class.fid = Faculty.fid
WHERE Student.slevel = 'JR' AND Faculty.fname = 'Johnson';

-- 3. Find the age of the oldest student who is either a History major or is enrolled in a course taught by Johnson
SELECT MAX(age) FROM Student
JOIN Enrolled ON Student.snum = Enrolled.snum
JOIN Class ON Enrolled.cname = Class.cname
JOIN Faculty ON Class.fid = Faculty.fid
WHERE Student.major = 'History' OR Faculty.fname = 'Johnson';

-- 4. Find the names of all classes that either meet in room R128 or have five or more students enrolled
SELECT cname FROM Class
WHERE
cname IN (SELECT cname FROM Class WHERE room = 'R128') OR
cname IN (
    SELECT cname FROM Enrolled
    GROUP BY cname
    HAVING COUNT(snum) >= 5
);

-- 5. Find the names of all students who are enrolled in two classes that meet at the same time
SELECT sname FROM Student WHERE snum IN (
    SELECT Student.snum FROM Student
    JOIN Enrolled ON Student.snum = Enrolled.snum
    JOIN Class ON Class.cname = Enrolled.cname
    GROUP BY Student.snum, meets_at
    HAVING COUNT(meets_at) > 1
);

-- 6. Find the names of faculty members who teach in every room in which some class is taught
SELECT fname FROM Faculty WHERE fid IN (
    SELECT Faculty.fid FROM Class
    JOIN Faculty ON Class.fid = Faculty.fid
    GROUP BY Faculty.fid
    HAVING COUNT(DISTINCT room) = (SELECT COUNT(DISTINCT room) FROM Class)
);

-- 7. Find the names of faculty members for whom the combined enrollment of the courses that they teach is fewer than five
SELECT fname FROM Faculty WHERE fid IN (
    SELECT Class.fid FROM Enrolled
    JOIN Class ON Enrolled.cname = Class.cname
    JOIN Faculty ON Class.fid = Faculty.fid
    GROUP BY Class.fid
    HAVING COUNT(snum) < 5
);

-- 8. For each Level (slevel), display the Level and the average age of students for that Level
SELECT slevel, AVG(age) FROM Student GROUP BY slevel;

-- 9. Delete all Seniors (slevel = SR)
SELECT * FROM Student;
DELETE FROM Student WHERE slevel = 'SR';
SELECT * FROM Student;

-- 10. Increase the salary of all faculty members who teach the class named “CS4513” by 5%.
SELECT * FROM Faculty;
UPDATE Faculty SET salary *= 1.05
WHERE fid IN (
    SELECT Faculty.fid FROM Faculty
    JOIN Class ON Class.fid = Faculty.fid
    WHERE Class.cname = 'CS 4513'
);
SELECT * FROM Faculty;