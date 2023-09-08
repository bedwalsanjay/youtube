drop TABLE BankUserActions
CREATE TABLE BankUserActions (
    UserID INT,  -- ID of the user attempting the action
    IPAddress VARCHAR(15), -- IP address of the user
    ActionDateTime DATETIME, -- Date and time of the action
    ActionType VARCHAR(50), -- Type of action (e.g., 'Log IN', 'Withdrawal', 'Access')
    ActionResult VARCHAR(50), -- Result of the action (e.g., 'Failed', 'Success')
    AccountID INT, -- ID of the affected account (if applicable)
);


truncate table BankUserActions
insert into BankUserActions values 
(1,'192.168.1.1', '2023-09-05 09:36:33.447','Log IN','Failed',123)
,(1,'192.168.1.1', '2023-09-05 09:38:33.447','Log IN','Failed',123)
,(1,'192.168.1.1', '2023-09-05 09:42:33.447','Log IN','Failed',123)
,(1,'192.168.1.1', '2023-09-06 11:42:33.447','Log IN','Failed',123)
,(2,'192.168.1.2', '2023-09-15 08:16:33.447','Log IN','Success',234)
,(2,'192.168.1.2', '2023-09-15 08:18:33.447','password change','Success',234)
,(2,'192.168.1.2', '2023-09-15 08:22:33.447','withdrawal','Success',234)
,(3,'192.168.1.3', '2023-09-05 09:32:33.447','Log IN','Failed',235)
,(3,'192.168.1.3', '2023-09-05 09:34:33.447','Log IN','Failed',235)
,(3,'192.168.1.3', '2023-09-05 09:36:33.447','Log IN','Success',235)
,(3,'192.168.1.3', '2023-09-05 09:38:33.447','withdrawal','Success',235)
,(3,'192.168.1.3', '2023-09-05 09:42:33.447','withdrawal','Success',235)
,(3,'192.168.1.3', '2023-09-05 09:45:33.447','withdrawal','Success',235)
,(4,'192.168.1.1', '2023-09-05 09:45:33.447','Log IN','Failed',124)
,(4,'192.168.1.1', '2023-09-05 09:48:33.447','Log IN','Failed',124)
,(4,'192.168.1.1', '2023-09-05 09:53:33.447','Log IN','Failed',124)
,(13,'192.168.1.13', '2023-09-07 11:10:33.447','Log IN','Success',236)
,(13,'192.168.1.13', '2023-09-07 11:18:33.447','withdrawal','Success',236)
,(13,'192.168.1.13', '2023-09-07 11:22:33.447','withdrawal','Success',236)
,(13,'192.168.1.13', '2023-09-07 11:25:33.447','withdrawal','Success',236)
,(13,'192.168.1.13', '2023-09-07 11:28:33.447','withdrawal','Success',236)
,(5,'192.168.1.5', '2023-09-06 07:36:33.447','Log IN','Success',237)
,(5,'192.168.1.5', '2023-09-06 07:42:33.447','withdrawal','Success',237)
,(5,'192.168.1.5', '2023-09-06 07:45:33.447','withdrawal','Success',237)
,(6,'192.168.1.6', '2023-09-22 10:56:33.447','Log IN','Success',238)
,(6,'192.168.1.6', '2023-09-22 10:58:33.447','withdrawal','Success',238)
,(6,'192.168.1.6', '2023-09-22 11:02:33.447','password change','Success',238)
,(14,'192.168.1.1', '2023-09-18 01:35:33.447','Log IN','Success',239)
,(14,'192.168.1.1', '2023-09-18 01:38:33.447','withdrawal','Success',239)
,(14,'192.168.1.1', '2023-09-18 02:42:33.447','withdrawal','Success',239)
,(14,'192.168.1.1', '2023-09-18 05:45:33.447','withdrawal','Success',239)

select * from BankUserActions




/*

================
Question
================

-- 1. if there are >=3  withdrawal transaction from a user ( in a single day ) , 
--	  time difference (gap) between 2 transactions of <=5 mins 
--    then tag that "day transaction", as a anamoly 
-- 2. if log-in failed for continuosly >=3 times  then tag that day login attempt
--    it as a anamoly( in a single day )

================
OutPut
================

userid	|   anamoly_reason		                        | actiondate	| attempt_cnt
3		|   more than 3 withdrawal attempt in a day		| 2023-09-05	| 3
13	    |	more than 3 withdrawal attempt in a day		| 2023-09-07	| 4
1		|   more than 3 failed login attempts in a day	| 2023-09-05	| 3
4		|   more than 3 failed login attempts in a day	| 2023-09-05	| 3

small requ
1. filter the withdrawal transaction
2. cast the actiondatetime to date
3. lag function to know the previous timestamp
4. deduct the curent ts - precious ts (duration )
5. filter the records having time diff <=360 seconds 
6. group by ACTIONDATE,users and find the count(withdrawal transaction )
7. filter the transactin ghaving count(withdrawal transaction ) >=3

*/
-- query for withdrawal_anomaly

with withdrawal_anomaly as (
select 
userid,
'more than 3 withdrawal attempt in a day' as anamoly_reason,
actiondate,
count(actiontype) as attempt_cnt
from 
(
select *,
CAST(actiondatetime as date) as actiondate
,lag(actiondatetime) over (partition by userid order by actiondatetime  ) as prev_ts
,
coalesce(
DATEDIFF(SECOND,lag(actiondatetime) over (partition by userid order by actiondatetime  ),actiondatetime)
,0)

as time_diff
from BankUserActions where  actiontype='withdrawal'
)a
where time_diff <=360
group by actiondate,userid
having count(actiontype)  >=3
)


/*
-- 2. if log-in failed for continuosly >=3 times  then tag that day login attempt
--    it as a anamoly( in a single day )

anamoly_reason								userid	actiondate	attempt_cnt
more than 2 failed login attempts in a day	1		2023-09-05	3
more than 2 failed login attempts in a day	4		2023-09-05	3


small requirement 

1. fitler the failed Log IN transactions
2. cast the actiondatetime to date
3. group by actiondate,userid 
4. where  count(Log IN) >=3
*/

-- query for login_anomaly

,login_anomaly as (
select 
userid,
'more than 3 failed login attempts in a day' as anamoly_reason,
CAST(actiondatetime as date) as actiondate,
count(actiontype) as attempt_cnt
from bankuseractions where  actiontype='log in' and ActionResult='Failed'
group by CAST(actiondatetime as date),userid
having count(actiontype) >=3
)

--userid	anamoly_reason									actiondate	attempt_cnt
--3		more than 3 withdrawal attempt in a day			2023-09-05	3
--13		more than 3 withdrawal attempt in a day			2023-09-07	4
--1		more than 3 failed login attempts in a day		2023-09-05	3
--4		more than 3 failed login attempts in a day		2023-09-05	3



select * from withdrawal_anomaly
union 
select * from  login_anomaly