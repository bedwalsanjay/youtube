-- create table 

CREATE TABLE UserActions (
    UserID INT,
    Action VARCHAR(50)
);


-- run below query to insert dummy records in your table

-- Generate  INSERT statements with random user actions
DECLARE @UserActions TABLE (
    UserID INT,
    Action VARCHAR(50)
);

DECLARE @Users TABLE (
    UserID INT IDENTITY(1,1),
    UserName VARCHAR(50)
);

INSERT INTO @Users (UserName)
VALUES
('Alex'),
('Reny'),
('John'),
('Sarah'),
('Michael'),
('Emma'),
('Oliver'),
('Ava'),
('William'),
('Sophia'),
('James'),
('Isabella'),
('Benjamin'),
('Mia'),
('Henry');

DECLARE @ActionList TABLE (
    ActionID INT IDENTITY(1,1),
    ActionName VARCHAR(50)
);

INSERT INTO @ActionList (ActionName)
VALUES
('Liked a picture'),
('Shared a post'),
('Commented on a post'),
('Sent a message'),
('Uploaded a picture'),
('Uploaded a video');

DECLARE @Counter INT = 1;

WHILE @Counter <= 6
BEGIN
    INSERT INTO @UserActions (UserID, Action)
    SELECT
        UserID,
        ActionName
    FROM (
        SELECT
            UserID,
            ActionName,
            ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY NEWID()) AS RowNum
        FROM @Users CROSS JOIN @ActionList
    ) AS RandomizedActions
    WHERE RowNum = 1;

    SET @Counter = @Counter + 1;
END

-- View the generated INSERT statements
SELECT * FROM @UserActions;
insert into UserActions SELECT * FROM @UserActions;

