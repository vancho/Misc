-- Let's look ad description of this murder in reports
SELECT description
FROM crime_scene_report
WHERE city = 'SQL City'
  AND date = '20180115'
  AND type = 'murder';

-- Security footage shows that there were 2 witnesses.
-- The first witness lives at the last house on "Northwestern Dr".
-- The second witness, named Annabel, lives somewhere on "Franklin Ave".

SELECT *
FROM interview
WHERE person_id = (SELECT id
                   FROM (SELECT id,
                                MAX(address_number)
                         FROM person
                         WHERE address_street_name LIKE '%Northwestern Dr%'))
   OR person_id = (SELECT id
                   FROM person
                   WHERE name LIKE '%Annabel%'
                     AND address_street_name LIKE '%Franklin Ave%');


-- 14887,"I heard a gunshot and then saw a man run out. He had a ""Get Fit Now Gym"" bag.
-- The membership number on the bag started with ""48Z"". Only gold members have those bags.
-- The man got into a car with a plate that included ""H42W""."
-- 16371,"I saw the murder happen, and I recognized the killer from my gym when I was working out last week
-- on January the 9th."

SELECT p.name
FROM get_fit_now_check_in gf_chkins
         JOIN get_fit_now_member gf_m ON gf_m.id = gf_chkins.membership_id
         JOIN person p ON p.id = gf_m.person_id
         JOIN drivers_license dl ON dl.id = p.license_id
WHERE gf_m.id LIKE '48Z%'
  AND gf_m.membership_status = 'gold'
  AND gf_chkins.check_in_date = '20180109'
  AND dl.plate_number LIKE '%H42W%'
  AND dl.gender = 'male';

INSERT INTO solution
VALUES (1, 'Jeremy Bowers');

SELECT value
FROM solution;

-- Congrats, you found the murderer! But wait, there's more... If you think you're up for a challenge,
-- try querying the interview transcript of the murderer to find the real villain behind this crime.
-- If you feel especially confident in your SQL skills, try to complete this final step with no more than 2 queries.
-- Use this same INSERT statement with your new suspect to check your answer.

SELECT *
FROM interview
WHERE person_id = '67318';

-- I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67").
-- She has red hair and she drives a Tesla Model S.
-- I know that she attended the SQL Symphony Concert 3 times in December 2017.

SELECT p.name
FROM drivers_license AS dl
         JOIN person p ON dl.id = p.license_id
         JOIN facebook_event_checkin fec ON p.id = fec.person_id
WHERE dl.car_make = 'Tesla'
  AND dl.car_model = 'Model S'
  AND dl.gender = 'female'
  AND dl.hair_color = 'red'
  AND fec.event_name LIKE '%SQL%Symphony%Concert%'
GROUP BY p.name;