libname lab9 'C:/Users/Tanya/Downloads/AI4/SASsystem/SAS_labs/IntroSASLab09';

/* Joining 2 tables in SQL - let us assume that we have two tables: A and B. Table A has column id_A, table B has column id_B.
These tables can have more columns. We want to join them on a common values of columns id_A and id_B. 
We have the following possibilities to join them:
- INNER JOIN (JOIN) - returns only records from tables A and B for which the match was found, example:
SELECT id_A,id_B
FROM A
INNER JOIN 
B
ON id_A=id_B
;
- LEFT JOIN - returns records returned by INNER JOIN 
				+ records from A for which the match with B was not found (in this case columns from the table B are missing), 
			example:
			
SELECT id_A,id_B
FROM A
LEFT JOIN 
B
ON id_A=id_B
;

- RIGHT JOIN - returns records returned by INNER JOIN
				 + records from B for which the match with A was not found (in this case columns from the table A are missing);
				 it is the same type of join as LEFT JOIN except the fact that roles of A and B are inverted, 
				 example:

SELECT id_A,id_B
FROM A
RIGHT JOIN 
B
ON id_A=id_B
;

- FULL JOIN - returns records returned by INNER JOIN
				+ records from A for which the match with B was not found (in this case columns from the table B are missing) 
				+ records from B for which the match with A was not found (in this case columns from the table A are missing), 
				example:

SELECT id_A,id_B
FROM A
RIGHT JOIN 
B
ON id_A=id_B
;

Note 1: When using above joins, ON statement is obligatory and this statement contains a logical condition indicating whether 
the match is found.

Note 2: If in above examples one of the keys is duplicated, the resulting table will also contain duplicate keys (it can happen
that the resulting table has much more rows than input tables).

Note 3: Most often used type of above joins in practice is LEFT JOIN: in most cases we have a situation where one table is the main one
and we want to append the information from some columns contained in auxiliary tables.

Note 4: It is worth to use table aliases when performing joins, e.g. like in exercise 9.1a):
lab9.rental_offices AS a
Then, if you want to refer to the column nr_place from lab9.rental_offices, you can write a.nr_place 
(or just nr_place, if the column with such name exists only in the lab9.rental_offices).

Note 5: Multiple join statements are allowed, in this case they are executed according to their order in the code, e.g.:
SELECT *
FROM
A 
LEFT JOIN B
ON A.id_A=B.id_B
LEFT JOIN C
ON A.id_A=C.id_C
;

More details about joins here:
https://www.w3schools.com/sql/sql_join.asp
https://www.w3schools.com/sql/sql_join_inner.asp
https://www.w3schools.com/sql/sql_join_left.asp
https://www.w3schools.com/sql/sql_join_right.asp
https://www.w3schools.com/sql/sql_join_full.asp
*/


/*Exercise 9.1 */

*c;
proc sql;
create table table9_c as
select nr_car, nr_rent_office, intck('day', input(date_rent, yymmdd10.), input(date_return, yymmdd10.))  as length_rent
from lab9.rental
where input(date_rent, yymmdd10.) between input("1/10/1998", ddmmyy10.) and input("31/12/1998", ddmmyy10.) 
order by nr_rent_office, length_rent;
quit;

*9.1.d;
proc sql;
	create table table9_d as
	select c.surname
	from lab9.customers as c
	where nr_customer in
	(
		select c.nr_customer
		from lab9.customers as c
		inner join lab9.rental as r on r.nr_customer=c.nr_customer
		group by c.nr_customer
		having count(*) > 1
	) 
	and nr_customer in
	(
		select r1.nr_customer
		from lab9.rental as r1, lab9.rental as r2
		where r1.nr_car <> r2.nr_car and r1.nr_customer = r2.nr_customer
	);
quit;

*e;
/* 1st way of solution */

proc sql;
create table table9_e as
select distinct a.name, a.surname
from lab9.employees as a
left join 
lab9.rental as b
on a.nr_employee=b.nr_employee_rent
where b.date_rent not between "01/10/1999" and "29/02/2000"
group by a.surname
;
quit;

*e;
/* 2nd way of solution */ 
proc sql;
create table table9_e as
select distinct a.name, a.surname
from lab9.employees as a
left join 
lab9.rental as b
on a.nr_employee=b.nr_employee_rent
where MONTH(input(b.date_rent, yymmdd10.))<10 and MONTH(input(b.date_rent, yymmdd10.))>2
UNION YEAR(input(b.date_rent, yymmdd10.))<>1999 and YEAR(input(b.date_rent, yymmdd10.))<>2000 
group by a.surname
;
quit;

*9.1.f;
proc sql;
	create table table9_f as 
	select e.nr_employee, e.name, e.surname
	from lab9.employees as e
	where nr_employee in 
	(
		select r1.nr_employee_rent
		from lab9.rental as r1
		where r1.nr_rent_office ~= r1.nr_office_return
		union
		select r2.nr_employee_return
		from lab9.rental as r2
		where r2.nr_rent_office ~= r2.nr_office_return
	)
	;
quit;	

*9.1.g;
proc sql;
create table table9_g as
(select intck('day', input(b.date_rent, yymmdd10.), input(b.date_return, yymmdd10.)) as length_rent
from lab9.rental as b
where b.date_return <> '' and year(input(b.date_rent, yymmdd10.))=1999);
quit;

proc sql;
create table table9g as
select distinct a.name, a.surname
from lab9.employees as a
left join 
lab9.rental as b
on a.nr_employee=b.nr_employee_rent
where year(a.date_employment)<1998
group by a.surname;
quit;

*9.1.h;
proc sql;
	create table ex9_1_h_1 as 
	select r.date_rent, r.date_return, r.nr_customer, r.day_price
	from lab9.rental as r
	where r.nr_car = '000003'
	;
quit;
proc sql;
	create table ex9_1_h as 
	select e.date_rent, e.date_return, c.name, c.surname
	from lab9.customers as c, ex9_1_h_1 as e
	where e.nr_customer = c.nr_customer;
quit;

/* Exercise 9.2 */
proc sql;
	TITLE "Exercise 9.2";
	SELECT Dates.instrument, Dates.date, measurement FROM lab9.dates Dates
	INNER JOIN lab9.measurements measurements ON measurements.instrument=Dates.instrument AND measurements.date IN
	(SELECT date FROM (
		SELECT date, abs(Dates.date-date) AS diff
		FROM lab9.measurements WHERE instrument=Dates.instrument)
	HAVING diff=MIN(diff));
quit;

/* Exercise 9.3  */
proc sql;
	create table table9_3 as 
	select art,
	sum (case when dat="19jul06"d then quantity end) as d19jul2006,
	sum (case when dat="20jul06"d then quantity end) as d20jul2006,
	sum (case when dat="21jul06"d then quantity end) as d21jul2006,
	sum (case when dat="22jul06"d then quantity end) as d22jul2006,
	sum (case when dat="23jul06"d then quantity end) as d23jul2006,
	sum (case when dat="24jul06"d then quantity end) as d24jul2006,
	sum (case when dat="25jul06"d then quantity end) as d25jul2006,
	sum (case when dat="26jul06"d then quantity end) as d26jul2006,
	sum (case when dat="27jul06"d then quantity end) as d27jul2006,
	sum (case when dat="28jul06"d then quantity end) as d28jul2006
	from lab9.z1
	group by art
	order by art;
quit;


/* Exercise 9.4 */
proc sql;
	TITLE "Exercise 9.4";
	SELECT * FROM (SELECT *, "." AS indyk FROM (
		SELECT * FROM lab9.b INTERSECT SELECT * FROM lab9.a))
	UNION
	SELECT * FROM (SELECT *, "1" AS indyk FROM (
		SELECT * FROM lab9.b EXCEPT SELECT * FROM lab9.a))
	ORDER BY a,b,c;
quit;

/* Exercise 9.5 */
proc sql;
	TITLE "Exercise 9.5";
	SELECT DISTINCT Students1.id_student AS student1, Students2.id_student AS student2, Students1.id_class FROM lab9.students Students1
	INNER JOIN lab9.students Students2 ON Students1.id_student<>Students2.id_student AND Students1.id_class IN 
	(SELECT id_class FROM lab9.students WHERE id_class=Students1.id_class AND id_student=Students2.id_student)
	ORDER BY Students1.id_student, Students1.id_class;
quit;



  




/*Homework: 9.1c)-h), 9.2-9.5 
All exercises in this homework shall be done ONLY in PROC SQL. DATA STEPs are not allowed.
*/
/*
Hints:
9.1c) SAS functions work in PROC SQL, e.g. you can use INPUT function to convert dates to numeric variables
9.1e) To find all employees, use UNION statement in PROC SQL, see notes at the end of this file
9.1g) Profit from renting one car is calculated as: 
(number of days the car was rent)x(day_price). 
For cars not returned profit should be equal 0.
9.4 UNION, INTERSECT, EXCEPT can be useful in this exercise, see notes at the end of this file

Expected number of rows in output data sets:
9.1a) 1
9.1b) 3
9.1c) 7
9.1d) 4
9.1e) 5
9.1f) 10
9.1g) 2
9.1h) 3
9.2 20
9.3 1
9.4 7
9.5 20
*/

/*
Other types of joins: self join - creates Cartesian product of two tables - every row of one table is matched with 
every row of second table (less efficient than previously presented joins), example:
SELECT *
FROM A,B
;

Set operations on data sets in SQL: they can be used to join tables by rows (not by columns like presented above). Important note:
columns in joined tables shall have the same: names, order and formats.
We have the following operators to join tables:
UNION - returns data set which rows are the union of rows of two data sets in sense of set theory (duplicated rows are removed)
UNION ALL - returns data set where rows from the second data set are appended to the first (duplicated rows are not removed)
INTERSECT - returns data set with common rows in both data sets (duplicated rows are removed)
EXCEPT - returns data set with rows existing in the first data set which do not exist in the second data set
Usage:
SELECT *
FROM A
UNION | UNION ALL | INTERSECT | EXCEPT
SELECT *
FROM B
;

More here:
https://www.techonthenet.com/sql/intersect.php
https://www.techonthenet.com/sql/union.php
https://www.techonthenet.com/sql/union_all.php
https://www.techonthenet.com/sql/except.php
*/

