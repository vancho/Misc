-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- SIMPLE SQL QUERIES--------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-- How can you retrieve all the information from the cd.facilities table?
SELECT *
FROM cd.facilities;

-- You want to print out a list of all of the facilities and their cost to members.
-- How would you retrieve a list of only facility names and costs?
SELECT name,
       membercost
FROM cd.facilities;

-- How can you produce a list of facilities that charge a fee to members?
SELECT *
FROM cd.facilities
WHERE membercost > 0;

-- How can you produce a list of facilities that charge a fee to members, and that fee is less than
-- 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly
-- maintenance of the facilities in question.
SELECT facid,
       name,
       membercost,
       monthlymaintenance
FROM cd.facilities
WHERE membercost > 0
  AND membercost < monthlymaintenance / 50;

-- How can you produce a list of all facilities with the word 'Tennis' in their name?
SELECT *
FROM cd.facilities
WHERE name LIKE ('%Tennis%');

-- How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
SELECT *
FROM cd.facilities
WHERE facid = 1
   OR facid = 5;

-- Without OR operator:
SELECT *
FROM cd.facilities
WHERE facid IN (1, 5);

-- How can you produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on if their
-- monthly maintenance cost is more than $100? Return the name and monthly maintenance of the facilities in question.
SELECT name,
       CASE
           WHEN monthlymaintenance > 100 THEN 'expensive'
           ELSE 'cheap'
           END AS cost
FROM cd.facilities;

-- How can you produce a list of members who joined after the start of September 2012? Return the memid, surname,
-- firstname, and joindate of the members in question.
SELECT memid,
       surname,
       firstname,
       joindate
FROM cd.members
WHERE joindate > '09/01/2012';

-- How can you produce an ordered list of the first 10 surnames in the members table? The list must
-- not contain duplicates.
SELECT DISTINCT surname
FROM cd.members
ORDER BY surname
LIMIT 10;

-- You, for some reason, want a combined list of all surnames and all facility names.
-- Yes, this is a contrived example :-). Produce that list!
SELECT surname
FROM cd.members
UNION
SELECT name
FROM cd.facilities;

-- You'd like to get the signup date of your last member. How can you retrieve this information?
SELECT MAX(joindate) AS latest
FROM cd.members;

-- You'd like to get the first and last name of the last member(s) who signed up - not just the date.
-- How can you do that?
SELECT firstname,
       surname,
       joindate
FROM cd.members
WHERE joindate = (SELECT MAX(joindate)
                  FROM cd.members);

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- JOINS AND SUBQUERIES -----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-- How can you produce a list of the start times for bookings by members named 'David Farrell'?
SELECT starttime
FROM cd.bookings
WHERE memid = (SELECT memid
               FROM cd.members
               WHERE firstname = 'David'
                 AND surname = 'Farrell');

SELECT bks.starttime
FROM cd.bookings bks
         INNER JOIN cd.members mems ON mems.memid = bks.memid
WHERE mems.firstname = 'David'
  AND mems.surname = 'Farrell';

-- How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'?
-- Return a list of start time and facility name pairings, ordered by the time.
SELECT bks.starttime AS start,
       fac.name
FROM cd.bookings bks
         INNER JOIN cd.facilities fac ON fac.facid = bks.facid
WHERE name LIKE ('%Tennis Court%')
  AND starttime >= ('09/21/2012')
  AND starttime < ('09/22/2012')
ORDER BY starttime;

-- How can you output a list of all members who have recommended another member?
-- Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
SELECT DISTINCT reqs.firstname AS firstname,
                reqs.surname   AS surname
FROM cd.members mems
         INNER JOIN cd.members reqs ON reqs.memid = mems.recommendedby
ORDER BY surname,
         firstname;

-- How can you output a list of all members, including the individual who recommended them (if any)?
-- Ensure that results are ordered by (surname, firstname).
SELECT mems.firstname AS memfname,
       mems.surname   AS memsname,
       reqs.firstname AS recfname,
       reqs.surname   AS recsname
FROM cd.members mems
         LEFT JOIN cd.members reqs ON reqs.memid = mems.recommendedby
ORDER BY memsname,
         memfname;

-- How can you produce a list of all members who have used a tennis court? Include in your output the name of the court,
-- and the name of the member formatted as a single column. Ensure no duplicate data,
-- and order by the member name followed by the facility name.
SELECT DISTINCT (
                    CONCAT(
                            mem.firstname,
                            ' ',
                            mem.surname
                        )
                    )    AS member,
                fac.name AS facility
FROM cd.bookings bkgs
         JOIN cd.facilities fac ON bkgs.facid = fac.facid
         JOIN cd.members mem ON bkgs.memid = mem.memid
WHERE fac.name LIKE ('%Tennis Court%')
ORDER BY member,
         facility;

SELECT DISTINCT mems.firstname || ' ' || mems.surname AS member,
                facs.name                             AS facility
FROM cd.members mems
         INNER JOIN cd.bookings bks ON mems.memid = bks.memid
         INNER JOIN cd.facilities facs ON bks.facid = facs.facid
WHERE facs.name IN ('Tennis Court 2', 'Tennis Court 1')
ORDER BY member,
         facility;

-- How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30?
-- Remember that guests have different costs to members (the listed costs are per half-hour 'slot'),
-- and the guest user is always ID 0. Include in your output the name of the facility,
-- the name of the member formatted as a single column, and the cost.
-- Order by descending cost, and do not use any subqueries.
SELECT CONCAT(mems.firstname, ' ', mems.surname) AS member,
       facs.name                                 AS facility,
       CASE
           WHEN mems.memid = 0 THEN bkgs.slots * facs.guestcost
           ELSE bkgs.slots * facs.membercost
           END                                   AS cost
FROM cd.bookings bkgs
         JOIN cd.facilities facs ON bkgs.facid = facs.facid
         JOIN cd.members mems ON bkgs.memid = mems.memid
WHERE bkgs.starttime >= '09/14/2012'
  AND bkgs.starttime < '09/15/2012'
  AND (
        (
                    mems.memid = 0
                AND bkgs.slots * facs.guestcost > 30
            )
        OR (
                    mems.memid != 0
                AND bkgs.slots * facs.membercost > 30
            )
    )
ORDER BY cost DESC;

-- The same but with subqueries:
SELECT member,
       facility,
       cost
FROM (SELECT mems.firstname || ' ' || mems.surname AS member,
             facs.name                             AS facility,
             CASE
                 WHEN mems.memid = 0 THEN bks.slots * facs.guestcost
                 ELSE bks.slots * facs.membercost
                 END                               AS cost
      FROM cd.members mems
               INNER JOIN cd.bookings bks ON mems.memid = bks.memid
               INNER JOIN cd.facilities facs ON bks.facid = facs.facid
      WHERE bks.starttime >= '2012-09-14'
        AND bks.starttime < '2012-09-15') AS bookings
WHERE cost > 30
ORDER BY cost DESC;

-- The same but with CTE
WITH costcte AS (SELECT CONCAT(mems.firstname, ' ', mems.surname) AS member,
                        facs.name                                 AS facility,
                        CASE
                            WHEN mems.memid = 0 THEN bkgs.slots * facs.guestcost
                            ELSE bkgs.slots * facs.membercost
                            END                                   AS cost,
                        mems.memid
                 FROM cd.bookings bkgs
                          JOIN cd.facilities facs ON bkgs.facid = facs.facid
                          JOIN cd.members mems ON bkgs.memid = mems.memid
                 WHERE bkgs.starttime >= '09/14/2012'
                   AND bkgs.starttime < '09/15/2012')

SELECT member,
       facility,
       cost
FROM costcte
WHERE (memid = 0 AND cost > 30)
   OR (memid != 0 AND cost > 30)
ORDER BY cost DESC;

-- How can you output a list of all members, including the individual who recommended them (if any),
-- without using any joins? Ensure that there are no duplicates in the list,
-- and that each firstname + surname pairing is formatted as a column and ordered.
SELECT DISTINCT firstname || ' ' || surname            AS member,
                (SELECT firstname || ' ' || surname
                 FROM cd.members recs
                 WHERE recs.memid = mem.recommendedby) AS recommender
FROM cd.members AS mem
ORDER BY member;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- MODIFYING DATA -----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-- The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:
-- facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
INSERT INTO cd.facilities
VALUES (9, 'Spa', 20, 30, 100000, 800);

-- In the previous exercise, you learned how to add a facility. Now you're going to add multiple facilities in
-- one command. Use the following values:
--
-- facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
-- facid: 10, Name: 'Squash Court 2', membercost: 3.5, guestcost: 17.5, initialoutlay: 5000, monthlymaintenance: 80.
DELETE
FROM cd.facilities
WHERE facid = 9;

SELECT *
FROM cd.facilities;

INSERT INTO cd.facilities
VALUES (9, 'Spa', 20, 30, 100000, 800),
       (10, 'Squash Court 2', 3.5, 17.5, 5000, 80);

--  This time, though, we want to automatically generate the value for the next facid,
--  rather than specifying it as a constant. Use the following values for everything else:
--
-- Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800
DELETE
FROM cd.facilities
WHERE facid IN (9, 10);

SELECT *
FROM cd.facilities;

INSERT INTO cd.facilities
VALUES ((SELECT MAX(facid) FROM cd.facilities) + 1, 'Spa', 20, 30, 100000, 800);

-- We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000:
-- you need to alter the data to fix the error.
UPDATE cd.facilities
SET initialoutlay=8000
WHERE name = 'Tennis Court 2';

-- We want to increase the price of the tennis courts for both members and guests.
-- Update the costs to be 6 for members, and 30 for guests.
UPDATE cd.facilities
SET membercost = 6,
    guestcost=30
WHERE name LIKE 'Tennis Court%';

-- We want to alter the price of the second tennis court so that it costs 10% more than the first one.
-- Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
UPDATE cd.facilities
SET membercost = (SELECT membercost FROM cd.facilities WHERE facid = 0) * 1.1,
    guestcost  = (SELECT guestcost FROM cd.facilities WHERE facid = 0) * 1.1
WHERE name = 'Tennis Court 2';

UPDATE cd.facilities facs
SET membercost = facs2.membercost * 1.1,
    guestcost  = facs2.guestcost * 1.1
FROM (SELECT * FROM cd.facilities WHERE facid = 0) facs2
WHERE facs.facid = 1;

-- As part of a clearout of our database, we want to delete all bookings from the cd.bookings table.
-- How can we accomplish this?
DELETE
FROM cd.bookings
WHERE *;

-- We want to remove member 37, who has never made a booking, from our database. How can we achieve that?
DELETE
FROM cd.members
WHERE memid = 37;

-- In our previous exercises, we deleted a specific member who had never made a booking.
-- How can we make that more general, to delete all members who have never made a booking?
DELETE
FROM cd.members
WHERE memid NOT IN (SELECT DISTINCT memid FROM cd.bookings);

DELETE
FROM cd.members mems
WHERE NOT EXISTS (SELECT 1 FROM cd.bookings WHERE memid = mems.memid);

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- MODIFYING DATA -----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-- For our first foray into aggregates, we're going to stick to something simple.
-- We want to know how many facilities exist - simply produce a total count.
SELECT COUNT(facid)
FROM cd.facilities;

SELECT COUNT(*)
FROM cd.facilities;

-- Produce a count of the number of facilities that have a cost to guests of 10 or more.
SELECT COUNT(*)
FROM cd.facilities
WHERE guestcost >= 10;

-- Produce a count of the number of recommendations each member has made. Order by member ID.
SELECT recommendedby, COUNT(recommendedby)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;

-- Produce a list of the total number of slots booked per facility.
-- For now, just produce an output table consisting of facility id and slots, sorted by facility id.
SELECT facid,
       SUM(slots) AS total_slots
FROM cd.bookings
GROUP BY facid
ORDER BY facid;

-- Produce a list of the total number of slots booked per facility in the month of September 2012.
-- Produce an output table consisting of facility id and slots, sorted by the number of slots.
SELECT facid,
       SUM(slots) AS total_slots
FROM cd.bookings
WHERE starttime >= '2012-09-01'
  AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY total_slots;

-- Produce a list of the total number of slots booked per facility per month in the year of 2012.
-- Produce an output table consisting of facility id and slots, sorted by the id and month.
SELECT facid,
       EXTRACT(MONTH FROM starttime) AS month,
       SUM(slots)                    AS total_slots
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime) = 2012
GROUP BY facid, EXTRACT(MONTH FROM starttime)
ORDER BY facid, month;

-- Find the total number of members (including guests) who have made at least one booking.
SELECT COUNT(DISTINCT memid)
FROM cd.bookings;

-- Produce a list of facilities with more than 1000 slots booked.
-- Produce an output table consisting of facility id and slots, sorted by facility id.
SELECT facid,
       SUM(slots) AS total_slots
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) > 1000
ORDER BY facid;

-- Produce a list of facilities along with their total revenue. The output table should consist of facility name and
-- revenue, sorted by revenue. Remember that there's a different cost for guests and members!
SELECT facs.name,
       SUM(slots * CASE
                       WHEN memid = 0 THEN facs.guestcost
                       ELSE facs.membercost
           END) AS revenue
FROM cd.bookings bkgs
         INNER JOIN cd.facilities facs ON facs.facid = bkgs.facid
GROUP BY facs.name
ORDER BY revenue;

-- Produce a list of facilities with a total revenue less than 1000. Produce an output table consisting of
-- facility name and revenue, sorted by revenue. Remember that there's a different cost for guests and members!
SELECT facs.name,
       SUM(slots * CASE
                       WHEN memid = 0 THEN facs.guestcost
                       ELSE facs.membercost
           END) AS revenue
FROM cd.bookings bkgs
         INNER JOIN cd.facilities facs ON facs.facid = bkgs.facid
GROUP BY facs.name
HAVING SUM(slots * CASE
                       WHEN memid = 0 THEN facs.guestcost
                       ELSE facs.membercost
    END) < 1000
ORDER BY revenue;

SELECT name, revenue
FROM (SELECT facs.name,
             SUM(slots * CASE
                             WHEN memid = 0 THEN facs.guestcost
                             ELSE facs.membercost
                 END) AS revenue
      FROM cd.bookings bkgs
               INNER JOIN cd.facilities facs ON facs.facid = bkgs.facid
      GROUP BY facs.name
      ORDER BY revenue) AS agg
WHERE revenue < 1000;

-- Output the facility id that has the highest number of slots booked.
-- For bonus points, try a version without a LIMIT clause. This version will probably look messy!
SELECT facid,
       SUM(slots) AS totalslots
FROM cd.bookings
GROUP BY facid
ORDER BY SUM(slots) DESC
LIMIT 1;

SELECT facid, SUM(slots) AS totalslots
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) = (SELECT MAX(sum2.totalslots)
                     FROM (SELECT SUM(slots) AS totalslots
                           FROM cd.bookings
                           GROUP BY facid) AS sum2);

-- Produce a list of the total number of slots booked per facility per month in the year of 2012.
-- In this version, include output rows containing totals for all months per facility,
-- and a total for all months for all facilities. The output table should consist of facility id,
-- month and slots, sorted by the id and month. When calculating the aggregated values for all months and all facids,
-- return null values in the month and facid columns.
SELECT facid, EXTRACT(MONTH FROM starttime) AS month, SUM(slots) AS slots
FROM cd.bookings
WHERE starttime >= '2012-01-01'
  AND starttime < '2013-01-01'
GROUP BY ROLLUP (facid, month)
ORDER BY facid, month;

-- Produce a list of the total number of hours booked per facility, remembering that a slot lasts half an hour.
-- The output table should consist of the facility id, name, and hours booked, sorted by facility id.
-- Try formatting the hours to two decimal places.
SELECT b.facid,
       f.name,
       ROUND(SUM(slots) / 2.0, 2) AS total_hours
FROM cd.bookings b
         JOIN cd.facilities f ON f.facid = b.facid
GROUP BY b.facid, f.name
ORDER BY b.facid;

SELECT facs.facid,
       facs.name,
       TRIM(TO_CHAR(SUM(bks.slots) / 2.0, '9999999999999999D99')) AS "Total Hours"
FROM cd.bookings bks
         INNER JOIN cd.facilities facs
                    ON facs.facid = bks.facid
GROUP BY facs.facid, facs.name
ORDER BY facs.facid;

-- Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
SELECT m.surname,
       m.firstname,
       b.memid,
       MIN(b.starttime) AS starttime
FROM cd.bookings b
         JOIN cd.members m ON m.memid = b.memid
WHERE starttime >= '2012-09-01'
GROUP BY b.memid, m.firstname, m.surname
ORDER BY memid;

-- Produce a list of member names, with each row containing the total member count.
-- Order by join date, and include guest members.
SELECT COUNT(*) OVER (),
       firstname,
       surname
FROM cd.members
ORDER BY joindate;

-- Produce a monotonically increasing numbered list of members (including guests), ordered by their date of joining.
-- Remember that member IDs are not guaranteed to be sequential.
SELECT ROW_NUMBER() OVER () AS row_number,
       firstname,
       surname
FROM cd.members
ORDER BY joindate;

SELECT COUNT(*) OVER (ORDER BY joindate),
       firstname,
       surname
FROM cd.members
ORDER BY joindate;

-- Output the facility id that has the highest number of slots booked.
-- Ensure that in the event of a tie, all tieing results get output.
SELECT facid, SUM(slots) AS totalslots
FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) = (SELECT MAX(sum2.totalslots)
                     FROM (SELECT SUM(slots) AS totalslots
                           FROM cd.bookings
                           GROUP BY facid) AS sum2);

SELECT facid,
       total
FROM (SELECT facid,
             SUM(slots)                             total,
             RANK() OVER (ORDER BY SUM(slots) DESC) rank
      FROM cd.bookings
      GROUP BY facid) AS ranked
WHERE rank = 1;

-- Produce a list of members (including guests), along with the number of hours they've booked in facilities,
-- rounded to the nearest ten hours. Rank them by this rounded figure, producing output of first name, surname,
-- rounded hours, rank. Sort by rank, surname, and first name.
SELECT firstname,
       surname,
       ROUND(SUM(b.slots) / 2, -1)                             AS hours,
       RANK() OVER (ORDER BY ROUND(SUM(b.slots) / 2, -1) DESC) AS rank
FROM cd.bookings b
         JOIN cd.members m ON m.memid = b.memid
GROUP BY b.memid, m.firstname, m.surname
ORDER BY rank, m.surname, m.firstname;

-- Produce a list of the top three revenue generating facilities (including ties).
-- Output facility name and rank, sorted by rank and facility name.
SELECT f.name,
       RANK() OVER (ORDER BY SUM(slots * CASE
                                             WHEN memid = 0 THEN f.guestcost
                                             ELSE f.membercost
           END) DESC)
FROM cd.bookings b
         JOIN cd.facilities f ON f.facid = b.facid
GROUP BY f.name
LIMIT 3;

SELECT name, rank
FROM (SELECT facs.name      AS name,
             RANK() OVER (ORDER BY SUM(CASE
                                           WHEN memid = 0 THEN slots * facs.guestcost
                                           ELSE slots * membercost
                 END) DESC) AS rank
      FROM cd.bookings bks
               INNER JOIN cd.facilities facs
                          ON bks.facid = facs.facid
      GROUP BY facs.name) AS subq
WHERE rank <= 3
ORDER BY rank;

-- Classify facilities into equally sized groups of high, average, and low based on their revenue.
-- Order by classification and facility name.
SELECT name,
       CASE
           WHEN class = 1 THEN 'high'
           WHEN class = 2 THEN 'average'
           ELSE 'low'
           END revenue
FROM (SELECT facs.name      AS name,
             NTILE(3) OVER (ORDER BY SUM(CASE
                                             WHEN memid = 0 THEN slots * facs.guestcost
                                             ELSE slots * membercost
                 END) DESC) AS class
      FROM cd.bookings bks
               JOIN cd.facilities facs
                    ON bks.facid = facs.facid
      GROUP BY facs.name) AS subq
ORDER BY class, name;

-- Based on the 3 complete months of data so far, calculate the amount of time each facility will take to
-- repay its cost of ownership. Remember to take into account ongoing monthly maintenance.
-- Output facility name and payback time in months, order by facility name.
-- Don't worry about differences in month lengths, we're only looking for a rough value here!
SELECT f.name,
       f.initialoutlay / ((SUM(CASE
                                   WHEN memid = 0 THEN slots * f.guestcost
                                   ELSE slots * membercost
           END) / 3) - f.monthlymaintenance) AS months

FROM cd.bookings b
         JOIN cd.facilities f ON f.facid = b.facid
GROUP BY f.facid, f.name
ORDER BY f.name;

-- For each day in August 2012, calculate a rolling average of total revenue over the previous 15 days.
-- Output should contain date and revenue columns, sorted by the date.
-- Remember to account for the possibility of a day having zero revenue.
-- This one's a bit tough, so don't be afraid to check out the hint!
SELECT dategen.date,
       (
           -- correlated subquery that, for each day fed into it,
           -- finds the average revenue for the last 15 days
           SELECT SUM(CASE
                          WHEN memid = 0 THEN slots * f.guestcost
                          ELSE slots * membercost
               END) AS rev

           FROM cd.bookings b
                    INNER JOIN cd.facilities f
                               ON b.facid = f.facid
           WHERE b.starttime > dategen.date - INTERVAL '14 days'
             AND b.starttime < dategen.date + INTERVAL '1 day') / 15 AS revenue
FROM (
         -- generates a list of days in august
         SELECT CAST(GENERATE_SERIES(timestamp '2012-08-01',
                                     '2012-08-31', '1 day') AS date) AS date) AS dategen
ORDER BY dategen.date;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- DATES, TIMESTAMPS --------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-- Produce a timestamp for 1 a.m. on the 31st of August 2012.
SELECT timestamp '2012-08-31 01:00:00';

-- Find the result of subtracting the timestamp '2012-07-30 01:00:00' from the timestamp '2012-08-31 01:00:00'
SELECT CONCAT(('2012-08-31 01:00:00'::DATE - '2012-07-30 01:00:00' :: DATE), ' days') AS interval;

SELECT timestamp '2012-08-31 01:00:00' - timestamp '2012-07-30 01:00:00' AS interval;

-- Produce a list of all the dates in October 2012.
-- They can be output as a timestamp (with time set to midnight) or a date.
SELECT date '2012-09-30' + i AS ts
FROM GENERATE_SERIES(1, (SELECT date '2012-11-01' - date '2012-10-01')) i;

SELECT GENERATE_SERIES(timestamp '2012-10-01', timestamp '2012-10-31', INTERVAL '1 day') AS ts;

-- Get the day of the month from the timestamp '2012-08-31' as an integer.
SELECT EXTRACT(DAY FROM date('2012-08-31'));

SELECT EXTRACT(DAY FROM timestamp '2012-08-31');

-- Work out the number of seconds between the timestamps '2012-08-31 01:00:00' and '2012-09-02 00:00:00'
SELECT EXTRACT(EPOCH FROM (timestamp '2012-09-02 00:00:00' - timestamp '2012-08-31 01:00:00'));

SELECT EXTRACT(EPOCH FROM (timestamp '2012-09-02 00:00:00' - timestamp '2012-08-31 01:00:00'))::int;

-- For each month of the year in 2012, output the number of days in that month.
-- Format the output as an integer column containing the month of the year, and a second column containing
-- an interval data type.
SELECT EXTRACT(MONTH FROM cal.month)                AS month,
       (cal.month + INTERVAL '1 month') - cal.month AS length
FROM (SELECT GENERATE_SERIES(timestamp '2012-01-01', timestamp '2012-12-01', INTERVAL '1 month') AS month) cal
ORDER BY month;

-- For any given timestamp, work out the number of days remaining in the month.
-- The current day should count as a whole day, regardless of the time.
-- Use '2012-02-11 01:00:00' as an example timestamp for the purposes of making the answer.
-- Format the output as a single interval value.
SELECT (DATE_TRUNC('month', timestamp '2012-02-11 01:00:00') + INTERVAL '1 month')
           - DATE_TRUNC('day', timestamp '2012-02-11 01:00:00') AS remaining;

SELECT (DATE_TRUNC('month', ts.testts) + INTERVAL '1 month')
           - DATE_TRUNC('day', ts.testts) AS remaining
FROM (SELECT timestamp '2012-02-11 01:00:00' AS testts) ts;

-- Return a list of the start and end time of the last 10 bookings
-- (ordered by the time at which they end, followed by the time at which they start) in the system.
SELECT starttime                                 AS starttime,
       starttime + INTERVAL '30 minutes' * slots AS endtime
FROM cd.bookings
ORDER BY endtime DESC, starttime DESC
LIMIT 10;

-- Return a count of bookings for each month, sorted by month
SELECT DATE_TRUNC('month', starttime) AS month,
       COUNT(*)                       AS count
FROM cd.bookings
GROUP BY month
ORDER BY month;

-- Work out the utilisation percentage for each facility by month, sorted by name and month,
-- rounded to 1 decimal place. Opening time is 8am, closing time is 8.30pm.
-- You can treat every month as a full month, regardless of if there were some dates the club was not open.
SELECT name,
       month,
       ROUND((100 * slots) /
             CAST(25 * (CAST((month + INTERVAL '1 month') AS date)
                 - CAST(month AS date)) AS numeric), 1) AS utilisation
FROM (SELECT facs.name                      AS name,
             DATE_TRUNC('month', starttime) AS month,
             SUM(slots)                     AS slots
      FROM cd.bookings bks
               JOIN cd.facilities facs
                    ON bks.facid = facs.facid
      GROUP BY facs.facid, month) AS inn
ORDER BY name, month;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- STRINGS ------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-- Output the names of all members, formatted as 'Surname, Firstname'
SELECT CONCAT(surname, ', ', firstname) AS name
FROM cd.members;

-- Find all facilities whose name begins with 'Tennis'. Retrieve all columns.
SELECT *
FROM cd.facilities
WHERE name LIKE ('Tennis%');

-- Perform a case-insensitive search to find all facilities whose name begins with 'tennis'. Retrieve all columns.
SELECT *
FROM cd.facilities
WHERE LOWER(name) LIKE ('tennis%');

-- You've noticed that the club's member table has telephone numbers with very inconsistent formatting.
-- You'd like to find all the telephone numbers that contain parentheses,
-- returning the member ID and telephone number sorted by member ID.
SELECT memid,
       telephone
FROM cd.members
WHERE telephone LIKE ('%(%)%')
ORDER BY memid;

SELECT memid, telephone
FROM cd.members
WHERE telephone ~ '[()]'
ORDER BY memid;

SELECT memid,
       telephone
FROM cd.members
WHERE telephone SIMILAR TO '%[()]%';

-- The zip codes in our example dataset have had leading zeroes removed from them by virtue of being stored as
-- a numeric type. Retrieve all zip codes from the members table, padding any zip codes less than 5 characters long
-- with leading zeroes. Order by the new zip code.
SELECT CASE
           WHEN LENGTH(zipcode::varchar) = 1 THEN CONCAT('0000', zipcode)
           WHEN LENGTH(zipcode::varchar) = 2 THEN CONCAT('000', zipcode)
           WHEN LENGTH(zipcode::varchar) = 3 THEN CONCAT('00', zipcode)
           WHEN LENGTH(zipcode::varchar) = 4 THEN CONCAT('0', zipcode)
           ELSE zipcode::varchar
           END AS zip
FROM cd.members
ORDER BY zip;

SELECT LPAD(CAST(zipcode AS char(5)), 5, '0') AS zip
FROM cd.members
ORDER BY zip;

-- You'd like to produce a count of how many members you have whose surname starts with each letter of the alphabet.
-- Sort by the letter, and don't worry about printing out a letter if the count is 0.
SELECT LEFT(surname, 1) AS letter,
       COUNT(*)         AS count
FROM cd.members
GROUP BY letter
ORDER BY letter;

-- The telephone numbers in the database are very inconsistently formatted.
-- You'd like to print a list of member ids and numbers that have had '-','(',')', and ' ' characters removed.
-- Order by member id.
SELECT memid,
       REGEXP_REPLACE(telephone, '[ ()-]+', '', 'g')
FROM cd.members
ORDER BY memid;

SELECT memid, REGEXP_REPLACE(telephone, '[^0-9]', '', 'g') AS telephone
FROM cd.members
ORDER BY memid;

SELECT memid, TRANSLATE(telephone, '-() ', '') AS telephone
FROM cd.members
ORDER BY memid;


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- RECURSIVES ---------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-- Simple Recursive Example
WITH RECURSIVE increment(num) AS (SELECT 1
                                  UNION ALL
                                  SELECT increment.num + 1
                                  FROM increment
                                  WHERE increment.num < 5)
SELECT *
FROM increment;


-- Find the upward recommendation chain for member ID 27: that is, the member who recommended them,
-- and the member who recommended that member, and so on. Return member ID, first name, and surname.
-- Order by descending member id.
WITH RECURSIVE recommenders(recommender) AS (SELECT recommendedby
                                             FROM cd.members
                                             WHERE memid = 27
                                             UNION ALL
                                             SELECT mems.recommendedby
                                             FROM recommenders recs
                                                      INNER JOIN cd.members mems
                                                                 ON mems.memid = recs.recommender)
SELECT recs.recommender, mems.firstname, mems.surname
FROM recommenders recs
         INNER JOIN cd.members mems
                    ON recs.recommender = mems.memid
ORDER BY memid DESC;

-- Find the downward recommendation chain for member ID 1: that is, the members they recommended,
-- the members those members recommended, and so on. Return member ID and name, and order by ascending member id.
WITH RECURSIVE recommendeds(memid) AS (SELECT memid
                                       FROM cd.members
                                       WHERE recommendedby = 1
                                       UNION ALL
                                       SELECT mems.memid
                                       FROM recommendeds recs
                                                INNER JOIN cd.members mems
                                                           ON mems.recommendedby = recs.memid)
SELECT recs.memid, mems.firstname, mems.surname
FROM recommendeds recs
         INNER JOIN cd.members mems
                    ON recs.memid = mems.memid
ORDER BY memid;

-- Produce a CTE that can return the upward recommendation chain for any member.
-- You should be able to select recommender from recommenders where member=x.
-- Demonstrate it by getting the chains for members 12 and 22. Results table should have member and recommender,
-- ordered by member ascending, recommender descending.
WITH RECURSIVE recommenders(recommender, member) AS (SELECT recommendedby, memid
                                                     FROM cd.members
                                                     UNION ALL
                                                     SELECT mems.recommendedby, recs.member
                                                     FROM recommenders recs
                                                              INNER JOIN cd.members mems
                                                                         ON mems.memid = recs.recommender)
SELECT recs.member member, recs.recommender, mems.firstname, mems.surname
FROM recommenders recs
         INNER JOIN cd.members mems
                    ON recs.recommender = mems.memid
WHERE recs.member = 22
   OR recs.member = 12
ORDER BY recs.member ASC, recs.recommender DESC;