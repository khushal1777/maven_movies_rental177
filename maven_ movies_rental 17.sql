USE MAVENMOVIES;

SELECT * FROM
 RENTAL;
 
 SELECT * FROM
 INVENTORY;
 
 SELECT * FROM FILM;
 
 SELECT COUNT(*) FROM CUSTOMER;
-- PROVIDE REVENUE TREND FOR INVESTORS
SELECT X.YEAR,X.MONTH_NAME,SUM(AMOUNT) AS REVENUE
FROM (SELECT *, EXTRACT(YEAR FROM PAYMENT_DATE) AS YEAR,DATE_FORMAT(PAYMENT_DATE,"%b") AS MONTH_NAME
 FROM PAYMENT) AS X
 GROUP BY X.YEAR,X.MONTH_NAME;
 
-- PROVIDE THE LIST OF 10 CUSTOMERS BASED ON REVENUE TO GIVE OFFERS TO THE THEM
SELECT *
 FROM CUSTOMER 
 WHERE CUSTOMER_ID IN (SELECT X.CUSTOMER_ID
 FROM (SELECT CUSTOMER_ID,SUM(AMOUNT) REVENUE_FROM_CUSTOMER FROM PAYMENT
 GROUP BY CUSTOMER_ID
 ORDER BY  REVENUE_FROM_CUSTOMER DESC
 LIMIT 10) AS X);
 
-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

-- You need to provide customer firstname, lastname and email id to the marketing team --
SELECT FIRST_NAME,LAST_NAME,EMAIL
 FROM CUSTOMER;

-- How many movies are with rental rate of $0.99? --
SELECT COUNT(*) AS CHEAPEST_RENTALS FROM FILM
WHERE RENTAL_RATE = 0.99;

-- We want to see rental rate and how many movies are in each rental category --
SELECT RENTAL_RATE,COUNT(*) AS TOTAL_NUMB_MOVIES
 FROM FILM
GROUP BY RENTAL_RATE;

-- Which rating has the most films? --
SELECT RATING,COUNT(*) AS NUMBER_OF_MOVIES FROM FILM
GROUP BY RATING
ORDER BY NUMBER_OF_MOVIES DESC;

-- Which rating is most prevalant in each store

SELECT INV.STORE_ID, F.RATING,COUNT(INVENTORY_ID) AS NUMB_OF_COPIES
FROM INVENTORY AS INV LEFT JOIN FILM AS F
ON INV.FILM_ID = F.FILM_ID
GROUP BY INV.STORE_ID,F.RATING
ORDER BY NUMB_OF_COPIES DESC ;

-- List of films by Film Name, Category, Language --
SELECT  F.FILM_ID,F.TITLE,C.NAME AS CATEGORY_NAME,L.NAME AS LANGUAGE_NAME
 FROM FILM AS F LEFT JOIN FILM_CATEGORY AS FC
ON F.FILM_ID = FC.FILM_ID LEFT JOIN CATEGORY AS C 
ON FC.CATEGORY_ID = C.CATEGORY_ID LEFT JOIN LANGUAGE AS L
ON F.LANGUAGE_ID = L.LANGUAGE_ID;

-- How many times each movie has been rented out?
SELECT F.TITLE, COUNT(R.RENTAL_ID) AS NUMBER_OF_RENTAL
FROM RENTAL AS R LEFT JOIN INVENTORY AS INV
			ON R.INVENTORY_ID = INV.INVENTORY_ID
					LEFT JOIN FILM AS F
			ON INV.FILM_ID = F.FILM_ID
GROUP BY F.TITLE
ORDER BY NUMBER_OF_RENTAL DESC;
-- REVENUE PER FILM (TOP 10 GROSSERS)

SELECT 
  F.TITLE, SUM(P.AMOUNT) AS REVENUE_PER_FILM
FROM
    PAYMENT AS P
        LEFT JOIN
    RENTAL AS R ON P.RENTAL_ID = R.RENTAL_ID
        LEFT JOIN
    INVENTORY AS INV ON R.INVENTORY_ID = INV.INVENTORY_ID
        LEFT JOIN
    FILM AS F ON INV.FILM_ID = F.FILM_ID
    GROUP BY F.TITLE
    ORDER BY REVENUE_PER_FILM DESC LIMIT 10;

-- Which Store has historically brought the most revenue?
SELECT ST.STORE_ID,SUM(P.AMOUNT) AS REVENUE_PER_STORE
FROM PAYMENT AS P LEFT JOIN STAFF AS ST
ON P.STAFF_ID = ST.STAFF_ID
GROUP BY ST.STORE_ID;

-- Reward users who have rented at least 30 times (with details of customers)
SELECT CUSTOMER_ID,COUNT(RENTAL_ID) AS NUMBER_OF_RENTAL
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING NUMBER_OF_RENTAL >= 30
ORDER BY CUSTOMER_ID;

SELECT LOYAL_CUSTOMERS.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,C.EMAIL,AD.PHONE
FROM (SELECT CUSTOMER_ID,COUNT(RENTAL_ID) AS NUMBER_OF_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING NUMBER_OF_RENTALS >=30
ORDER BY CUSTOMER_ID) AS LOYAL_CUSTOMERS LEFT JOIN CUSTOMER AS C
		ON LOYAL_CUSTOMERS.CUSTOMER_ID = C.CUSTOMER_ID
										LEFT JOIN ADDRESS AS AD
		ON C.ADDRESS_ID = AD.ADDRESS_ID;


SELECT * FROM CUSTOMER;

SELECT * FROM ADDRESS;

SELECT DISTINCT RENTAL_DURATION
FROM FILM;
-- Could you pull all payments from our first 100 customers (based on customer ID)
SELECT CUSTOMER_ID,RENTAL_ID,AMOUNT,PAYMENT_DATE
FROM PAYMENT
WHERE CUSTOMER_ID<101;

-- Now I’d love to see just payments over $5 for those same customers, since January 1, 2006
SELECT CUSTOMER_ID,RENTAL_ID,AMOUNT,PAYMENT_DATE
FROM PAYMENT
WHERE CUSTOMER_ID<101 AND AMOUNT > 5 AND PAYMENT_DATE> '2006-01-01';

-- Now, could you please write a query to pull all payments from those specific customers, along
-- with payments over $5, from any customer?
 SELECT CUSTOMER_ID,RENTAL_ID,AMOUNT,PAYMENT_DATE
FROM PAYMENT
WHERE AMOUNT > 5 AND CUSTOMER_ID IN (42,53,60,75);

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?
 SELECT TITLE,SPECIAL_FEATURES
FROM FILM
WHERE SPECIAL_FEATURES LIKE '%Behind the Scenes%';
-- unique movie ratings and number of movies
SELECT RATING,COUNT(FILM_ID) AS NUMBER_0F_MOVIES
FROM FILM
GROUP BY RATING;
-- Could you please pull a count of titles sliced by rental duration?
SELECT RENTAL_DURATION,COUNT(FILM_ID) AS NUMBER_0F_MOVIES
FROM FILM
GROUP BY RENTAL_DURATION;
-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION
SELECT RATING,COUNT(FILM_ID) AS NUMBER_OF_MOVIES,
MIN(LENGTH) AS SHORTEST_LENGTH,
MAX(LENGTH) AS LONGEST_LENGTH,
AVG(RENTAL_DURATION) AS AVG_RENTAL_DURATION,
AVG(LENGTH) AS AVG_FILM_LENGTH
FROM FILM
GROUP BY RATING
ORDER BY  AVG_FILM_LENGTH;
-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?
SELECT REPLACEMENT_COST,COUNT(FILM_ID) AS NUMBER_OF_MOVIES,
MIN(RENTAL_RATE) AS CHEAPEST_RENTAL,
MAX(RENTAL_RATE) AS EXPENSIVE_RENTAL,
AVG(RENTAL_RATE) AS AVG_RENTAL
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;

-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”
SELECT CUSTOMER_ID,COUNT(*) AS TOTAL_RENTALS
 FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING TOTAL_RENTALS < 15;
-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”
SELECT TITLE,LENGTH,RENTAL_RATE
FROM FILM
ORDER BY LENGTH DESC;
-- CATEGORIZE MOVIES AS PER LENGTH
SELECT TITLE,LENGTH,
	CASE
		WHEN LENGTH < 60 THEN 'UNDER 1 HR'
        WHEN LENGTH BETWEEN 60 AND 90 THEN '1 TO 1.5 HRS'
        WHEN LENGTH > 90 THEN 'OVER 1.5 HRS'
        ELSE 'ERROR'
	END AS LENGTH_BUCKET
FROM FILM;

SELECT DISTINCT TITLE,
	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;


-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”
SELECT CUSTOMER_ID,FIRST_NAME,LAST_NAME,
	CASE
		WHEN STORE_ID = 1 AND ACTIVE = 1 THEN 'store 1 active'
        WHEN STORE_ID = 1 AND ACTIVE = 0 THEN 'store 1 inactive'
        WHEN STORE_ID = 2 AND ACTIVE = 1 THEN 'store 2 active'
        WHEN STORE_ID = 2 AND ACTIVE = 0 THEN 'store 2 inactive'
        ELSE 'ERROR'
	END AS STORE_AND_STATUS
FROM CUSTOMER;

-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

select distinct inventory.inventory_id,inventory.store_id,
film.title,film.description
from film inner join inventory on film.film_id = inventory.film_id;

-- Actor first_name, last_name and number of movies
select actor.actor_id,
actor.first_name,
actor.last_name,
count(film_actor.film_id)
from actor left join film_actor 
on actor.actor_id = film_actor.actor_id
group by actor.actor_id;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

select film.title,
count(film_actor.actor_id)
from film left join film_actor
on film.film_id = film_actor.film_id
group by film.film_id;


-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”

select actor.first_name,
actor.last_name,
film.title
from actor inner join film_actor
on actor.actor_id = film_actor.actor_id
inner join film on film_actor.film_id = film.film_id
order by 
actor.last_name,
actor.first_name;
-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”
SELECT DISTINCT FILM.TITLE,
	FILM.DESCRIPTION
FROM FILM
	INNER JOIN INVENTORY
		ON FILM.FILM_ID = INVENTORY.FILM_ID
        AND INVENTORY.STORE_ID = 2;
-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”
        (SELECT FIRST_NAME,
		LAST_NAME,
        'ADVISORS' AS DESIGNATION
FROM ADVISOR

UNION

SELECT FIRST_NAME,
		LAST_NAME,
        'STAFF MEMBER' AS DESIGNATION
FROM STAFF);
