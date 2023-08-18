-- Create the sample table
Drop table Employee
CREATE TABLE Employee (
    ID INT ,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Department NVARCHAR(50)
);

-- Insert 10 sample records with duplicates
INSERT INTO Employee (ID, FirstName, LastName, Department)
VALUES
    (1, 'John', 'Doe', 'HR'),
    (2, 'Jane', 'Smith', 'IT'),
    (3, 'Alice', 'Johnson', 'IT'),
    (4, 'Michael', 'Brown', 'Finance'),
    (5, 'John', 'Smith', 'HR'),
    (1, 'John', 'Doe', 'HR'),
    (2, 'Jane', 'Smith', 'IT'),
	 (1, 'John', 'Doe', 'HR'),
    (3, 'Alice', 'Johnson', 'IT')


-- 3 ways of deleting exact duplicate records from the table


--1 Using row_number
select * from Employee order by id
WITH Employee_CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY ID, FirstName, LastName, Department 
		   ORDER BY ID) AS RowNum
    FROM Employee
)
--select *  FROM Employee_CTE WHERE RowNum > 1;

delete FROM Employee_CTE WHERE RowNum > 1;

--2 Group by all columns
select * from Employee order by id

drop table #emp_groupby
CREATE TABLE #emp_groupby  (
    ID INT ,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Department NVARCHAR(50)
);

insert into #emp_groupby
select ID, FirstName, LastName, Department from 
employee group by ID, FirstName, LastName, Department

select * from #emp_groupby

truncate table employee
insert into employee select * from #emp_groupby


--3 distinct of  all columns
select * from Employee order by id

drop table #emp_distinct
CREATE TABLE #emp_distinct  (
    ID INT ,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Department NVARCHAR(50)
);

insert into #emp_distinct
select distinct * from 
employee 

select * from #emp_distinct

truncate table employee
insert into employee select * from #emp_distinct

select * from Employee order by id