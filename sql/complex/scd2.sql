
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'emp_source')
drop table emp_source
create table emp_source
(
emp_id int
,fname varchar(20)
,lname varchar(20)
,location varchar(20)
)

IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'emp_target')
drop table emp_target
create table emp_target
(
emp_id int
,fname varchar(20)
,lname varchar(20)
,location varchar(20)
,start_date date
,end_date date --9999-01-01
,active_flag bit
)

--Iteration 1 --> When it is first time insert and target table  is empty

INSERT INTO emp_source (emp_id, fname, lname, location)
VALUES 
    (1, 'John', 'Doe', 'New York'),
    (2, 'Jane', 'Smith', 'Los Angeles')

select * from emp_source
select * from emp_target


/*
--1 
insert brand new records with 
start_date=current_date
end_date='9999-01-01'
active_flag='Y'

--2
update the old recors with 
end_date=current_date-1
active_flag='N'

--3
Insert new records corresponding to the record which were updated in step2 with 
start_date=current_date
end_date='9999-01-01'
active_flag='Y'
*/

--use a temp TABLE

drop table #change_records
create table #change_records
(
emp_id int
)

-- identify the emp_id which has changed 
insert into #change_records
select s.emp_id 
from emp_source s
inner join emp_target t
on s.emp_id=t.emp_id and t.active_flag='1' 
and (
s.fname<>t.fname
OR s.lname<>t.lname
OR s.location<>t.location
)

select * from emp_source
select * from emp_target
select * from #change_records

-- Step 1: Insert brand new records
INSERT INTO emp_target (emp_id, fname, lname, location, start_date, end_date, active_flag)
SELECT
    s.emp_id,
    s.fname,
    s.lname,
    s.location,
    GETDATE() AS start_date,
    '9999-01-01' AS end_date,
    '1' AS active_flag
FROM emp_source s
LEFT JOIN emp_target t ON s.emp_id = t.emp_id
WHERE t.emp_id IS NULL;

select * from emp_source
select * from emp_target

--step 2 : Update old records 

UPDATE emp_target
SET
    end_date = DATEADD(day, -1, GETDATE()),
    active_flag = '0'
FROM emp_target t
JOIN #change_records CR ON t.emp_id = CR.emp_id
and t.active_flag='1'

select * from emp_source
select * from emp_target

INSERT INTO emp_target (emp_id, fname, lname, location, start_date, end_date, active_flag)
SELECT
    emp_id,
    fname,
    lname,
    location,
    GETDATE() AS start_date,
    '9999-01-01' AS end_date,
    '1' AS active_flag
FROM emp_source src
where emp_id in (select emp_id from #change_records)

select * from emp_source
select * from emp_target order by 1

update emp_target set start_date='2019-01-01' where emp_id=1


--second time records 

truncate table emp_source
INSERT INTO emp_source (emp_id, fname, lname, location)
VALUES 
    (1, 'John', 'Doe', 'London'),
    (3, 'Sanjay', 'Bedwal', 'India')