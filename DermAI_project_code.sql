/*=====================================================================================
	Data Exploration & DUBLICATION
========================================================================================*/
SELECT *
FROM table1
Limit 20
;

SELECT *
FROM table2
Limit 20
;

/*-----------------------------------------------------------------------------------------
		Counting number of rows in each table
------------------------------------------------------------------------------------------*/
SELECT COUNT(*) AS "Table1 Total" FROM table1;
SELECT COUNT(*) AS "Table2 Total" FROM table2;

/*-----------------------------------------------------------------------------------------
		Checking for missing values/data in individual columns of each table
------------------------------------------------------------------------------------------*/

SELECT
	COUNT(*) FILTER(WHERE patient_id IS NULL) 		 AS missing_patient_id,
	COUNT(*) FILTER(WHERE smoke IS NULL) 			 AS missing_smoke,
	COUNT(*) FILTER(WHERE drink IS NULL) 			 AS missing_drink,
	COUNT(*) FILTER(WHERE background_father IS NULL) AS missing_father_background,
	COUNT(*) FILTER(WHERE background_mother IS NULL) AS missing_background_mother,
	COUNT(*) FILTER(WHERE age IS NULL) 				 AS missing_age,
	COUNT(*) FILTER(WHERE pesticide IS NULL) 		 AS missing_pesticide,
	COUNT(*) FILTER(WHERE gender IS NULL) 			 AS missing_gender,
	COUNT(*) FILTER(WHERE skin_cancer_history IS NULL) AS missing_skin_cancer_history,
	COUNT(*) FILTER(WHERE cancer_history IS NULL)  	 AS missing_cancer_history,
	COUNT(*) FILTER(WHERE has_piped_water IS NULL) 	 AS missing_piped_water,
	COUNT(*) FILTER(WHERE has_sewage_system IS NULL) AS missing_sewage_system
FROM table1
;


SELECT
	COUNT(*) FILTER(WHERE lesion_id IS NULL) 	AS missing_lesion_id,
	COUNT(*) FILTER(WHERE patient_id IS NULL) 	AS missing_patient_id,
	COUNT(*) FILTER(WHERE fitspatrick IS NULL)  AS missing_fitspatrick,
	COUNT(*) FILTER(WHERE region IS NULL) 		AS missing_region,
	COUNT(*) FILTER(WHERE diameter_1 IS NULL)   AS missing_diameter_1,
	COUNT(*) FILTER(WHERE  diameter_2 IS NULL)  AS missing_diameter_2,
	COUNT(*) FILTER(WHERE diagnostic IS NULL)   AS missing_diagnostic, 
	COUNT(*) FILTER(WHERE itch IS NULL)         AS missing_itch, 
	COUNT(*) FILTER(WHERE grew IS NULL)         AS missing_grew,
	COUNT(*) FILTER(WHERE hurt IS NULL)         AS missing_hurt,
	COUNT(*) FILTER(WHERE changed IS NULL) 		AS missing_changed,
	COUNT(*) FILTER(WHERE bleed IS NULL) 		AS missing_bleed,
	COUNT(*) FILTER(WHERE elevation IS NULL) 	AS missing_elevation,
	COUNT(*) FILTER(WHERE img_id IS NULL) 		AS missing_img_id,
	COUNT(*) FILTER(WHERE biopsed IS NULL) 		AS missing_biopsed
FROM table2
;

/*-----------------------------------------------------------------------------------------
		Using DISTINCT to check for consistency in individual columns of each table
------------------------------------------------------------------------------------------*/
SELECT DISTINCT smoke FROM table1 ORDER BY 1 ;
SELECT DISTINCT drink FROM table1 ORDER BY 1 ;
SELECT DISTINCT background_father FROM table1 ORDER BY 1 ;
SELECT DISTINCT background_mother FROM table1 ORDER BY 1 ;

SELECT DISTINCT has_sewage_system FROM table1 ORDER BY 1 ;
SELECT DISTINCT cancer_history FROM table1 ORDER BY 1 ;

SELECT DISTINCT lesion_id FROM table2 ORDER BY 1 ;
SELECT DISTINCT fitspatrick FROM table2 ORDER BY 1 ;
SELECT DISTINCT region FROM table2 ORDER BY 1 ;
SELECT DISTINCT biopsed FROM table2 ORDER BY 1 ;
SELECT DISTINCT diameter_1 FROM table2 ORDER BY 1 ;


/*-----------------------------------------------------------------------------------------
	Dublicating table1 AS Patient_Info & table2 as Lesion_Info respectively
------------------------------------------------------------------------------------------*/
DROP TABLE IF EXISTS patient_info ;
CREATE TABLE patient_info AS SELECT * FROM table1 ;

DROP TABLE IF EXISTS lesion_info ;
CREATE TABLE lesion_info AS SELECT * FROM table2 ;

/*=====================================================================================
	Data Cleaning and Validation
========================================================================================*/
SELECT * FROM patient_info LIMIT 50 ;

--Standardizing by only capitalizing the first letters. 
-- BOOLEAN data cannot be standadized
UPDATE patient_info
SET 
	background_father = INITCAP(background_father),
	background_mother = INITCAP(background_mother),
	gender = INITCAP(gender)
;

SELECT DISTINCT background_father FROM patient_info ORDER BY 1 ;
SELECT DISTINCT background_mother FROM patient_info ORDER BY 1 ;

-- Handling data inconsistency
UPDATE patient_info
SET background_father = 'Unknown'
WHERE background_father = 'Unk'
;

UPDATE patient_info
SET background_mother = 'Unknown'
WHERE background_mother = 'Unk'
;

SELECT * FROM lesion_info LIMIT 50 ;

UPDATE lesion_info
SET region = INITCAP(region)
;
/*
SELECT DISTINCT(diagnostic) FROM lesion_info;

UPDATE lesion_info
SET diagnostic = ( CASE
	WHEN (diagnostic = 'SCC') THEN 'Squamous Cell Carcinoma'
	WHEN (diagnostic = 'BCC') THEN 'Basal Cell Cancinoma'
	WHEN (diagnostic = 'MEL') THEN 'Melanoma'
	WHEN (diagnostic = 'ACK') THEN 'Actinic Keratosis'
	WHEN (diagnostic = 'SEK') THEN 'Seborrheic Keratosis'
	WHEN (diagnostic = 'NEV') THEN 'Nevus'
	ELSE (diagnostic) 
END)
*/

/*-----------------------------------------------------------------------
	Creating a view table by joining Patient_info and lesion_info
-------------------------------------------------------------------------*/
DROP VIEW IF EXISTS p_health_table;

CREATE VIEW p_health_table AS
SELECT 
	p.patient_id, l.lesion_id,
	p.background_father, p.background_mother,
	p.age, p.gender,
	l.fitspatrick, 
	l.region, l.diameter_1, l.diameter_2,
	l.diagnostic,
	p.smoke, p.drink,
	p.skin_cancer_history, p.cancer_history,
	p.has_piped_water, p.has_sewage_system, p.pesticide,
	l.itch, l.grew, l.hurt,
	l.changed, l.bleed, l.elevation,
	l.biopsed, l.img_id
FROM patient_info p
JOIN lesion_info l
ON l.patient_id = p.patient_id
;

SELECT * FROM p_health_table  ;

--Total Patients
SELECT
	COUNT(DISTINCT patient_id) AS total_patients
FROM p_health_table


/*-----------------------------------------------------------------------
	Business Questions and Solutions
------------------------------------------------------------------------
Q1. What's the distribution of lesion dignoses? Overall percentage of each diagnoses?
------------------------------------------------------------------------*/
SELECT 
	diagnostic, 
CASE
	WHEN (diagnostic = 'SCC') THEN 'Squamous Cell Carcinoma'
	WHEN (diagnostic = 'BCC') THEN 'Basal Cell Cancinoma'
	WHEN (diagnostic = 'MEL') THEN 'Melanoma'
	WHEN (diagnostic = 'ACK') THEN 'Actinic Keratosis'
	WHEN (diagnostic = 'SEK') THEN 'Seborrheic Keratosis'
	WHEN (diagnostic = 'NEV') THEN 'Nevus'
	ELSE (diagnostic) 
END AS "Lesion Diagnostics",
	COUNT(*) AS lesion_records, 
	ROUND(100 * COUNT(*)/SUM(COUNT(*)) OVER(),2) AS "Percentage Diagnostic" 
FROM p_health_table
GROUP BY diagnostic 
ORDER BY lesion_records DESC
;

----------------------------------------------------------------
--  Q2. Which gender are more diagnosed?
 ----------------------------------------------------------------
SELECT 
	gender,
	COUNT(DISTINCT patient_id) AS Persons
FROM p_health_table
GROUP BY 1, 2
;

----------------------------------------------------------------
--  Q3. How does diagnoses vary across different age groups?
 ----------------------------------------------------------------
SELECT DISTINCT(age) FROM p_health_table;

SELECT CASE
	WHEN age < 20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 40 THEN '(20 - 40)'
	WHEN age BETWEEN 41 AND 60 THEN '(41 - 60)'
	WHEN age BETWEEN 61 AND 80 THEN '(61 - 80)'
	WHEN age BETWEEN 81 AND 100 THEN '(81 - 100)'
	ELSE 'Above 100'
	END AS "Age Groups",
	diagnostic,
	COUNT(diagnostic) AS Total_Cases
FROM p_health_table
GROUP BY diagnostic, "Age Groups"
ORDER BY Total_Cases DESC
;

----------------------------------------------------------------
--  Q4. Which backgrounds(location) have higher diagnoses
 ----------------------------------------------------------------
SELECT 
	background_father,
	background_mother,
	COUNT(DISTINCT patient_id) AS Persons
FROM p_health_table
GROUP BY 1, 2
ORDER BY Persons DESC
LIMIT 10
;

----------------------------------------------------------------
--  Q5. What's the Impact of a patient's lifestyle on diagnoses?
 ----------------------------------------------------------------
SELECT 
	smoke,
	drink,
	COUNT(DISTINCT patient_id) AS Persons
FROM p_health_table
GROUP BY 1, 2
ORDER BY Persons DESC
;

----------------------------------------------------------------
--  Q6. Which body region has the most lesions?
 ----------------------------------------------------------------
SELECT 
	region,
	COUNT(diagnostic) AS lesion_Cases
FROM p_health_table
GROUP BY 1
ORDER BY 2 DESC
;

----------------------------------------------------------------
--  Q7. How does Fitzpatrick Skin type relate to diagnosis?
 ----------------------------------------------------------------
SELECT
 	fitspatrick,
	diagnostic,
	COUNT(*) AS Cases
FROM p_health_table
GROUP BY 1, 2
ORDER BY Cases DESC
;

----------------------------------------------------------------
--  Q8. Which symptoms are most common by each diagnoses?
--Calculating the Average score of each symptom
 --------------------------------------------------------------
 --Using WITH Clause to create Common Table of Expression(CTE)
With Symptoms AS (
 	SELECT 
 		diagnostic,
		ROUND(AVG(CASE WHEN itch = 'true' THEN 1 ELSE 0 END), 1) AS itch_score,
		ROUND(AVG(CASE WHEN grew = 'true' THEN 1 ELSE 0 END), 1) AS grew_score,
		ROUND(AVG(CASE WHEN hurt = 'true' THEN 1 ELSE 0 END), 1) AS hurt_score,
		ROUND(AVG(CASE WHEN changed = 'true' THEN 1 ELSE 0 END), 1) AS changed_score,
		ROUND(AVG(CASE WHEN bleed = 'true' THEN 1 ELSE 0 END), 1) AS bleed_score,
		ROUND(AVG(CASE WHEN elevation = 'true' THEN 1 ELSE 0 END), 1) AS elevation_score
 FROM p_health_table
 GROUP BY 1 )
 
SELECT * FROM Symptoms 
ORDER BY diagnostic;

----------------------------------------------------------------
--  Q9. History of Cancer vs diagnosis?
 ----------------------------------------------------------------
SELECT 
 	diagnostic,
	ROUND(AVG(CASE WHEN skin_cancer_history = 'true' THEN 1 ELSE 0 END), 2) AS Avg_Skin_Cancer_History,
	ROUND(AVG(CASE WHEN cancer_history = 'true' THEN 1 ELSE 0 END), 2) 	  AS Avg_Cancer_History
FROM p_health_table
GROUP BY 1
 ;

 ----------------------------------------------------------------
--  Q10. Environmental Exposures vs diagnosis?
 ----------------------------------------------------------------
 --Has piped water and sewage systems vs diagnosis?
SELECT 
 	diagnostic,
	 ROUND(AVG(CASE WHEN pesticide = 'true' THEN 1 ELSE 0 END), 2) AS Pesticide_Exposure,
	 ROUND(AVG(CASE WHEN has_piped_water = 'true' THEN 1 ELSE 0 END), 2) AS P_has_piped_water,
	 ROUND(AVG(CASE WHEN has_sewage_system = 'true' THEN 1 ELSE 0 END), 2) AS P_has_sewage_system
FROM p_health_table
GROUP BY 1
ORDER BY Pesticide_Exposure DESC
 ;

 ----------------------------------------------------------------
--  Q10.1 No piped water and no sewage systems vs diagnosis?
 ----------------------------------------------------------------

SELECT 
 	diagnostic,
	 ROUND(AVG(CASE WHEN has_piped_water = 'false' THEN 1 ELSE 0 END), 2) AS P_has_NO_piped_water,
	 ROUND(AVG(CASE WHEN has_sewage_system = 'false' THEN 1 ELSE 0 END), 2) AS P_has_NO_sewage_system
FROM p_health_table
GROUP BY 1
ORDER BY P_has_NO_piped_water DESC
 ;
 ----------------------------------------------------------------
--  Q11. Which diagnoses have the highest biopsy rate?
-- (Whether the lesion was biopsy-confirmed)
 ----------------------------------------------------------------
SELECT * FROM p_health_table LIMIT 5;
SELECT 
	diagnostic,
	COUNT(*) AS Total_counts,
	SUM(CASE WHEN biopsed = 'true' THEN 1 ELSE 0 END) AS Total_biopsied,
	ROUND(100 * AVG(CASE WHEN biopsed = 'true' THEN 1 ELSE 0 END),2) AS biopsy_rate
FROM p_health_table
GROUP BY diagnostic 
ORDER BY biopsy_rate DESC
;

 ----------------------------------------------------------------
--  Q12 What's the Average lesion diameter
 ----------------------------------------------------------------

SELECT 
	diagnostic, 
	--ROUND(AVG((diameter_1+diameter_2)/2)::"numeric", 2) AS avg_diameter_mm 
	ROUND(CAST(AVG((diameter_1+diameter_2)/2)AS Numeric), 2) AS avg_diameter_mm 
FROM p_health_table
GROUP BY diagnostic 
ORDER BY avg_diameter_mm DESC
;