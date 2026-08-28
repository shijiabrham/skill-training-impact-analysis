1. Beneficiaries who did not join employment


SELECT 
    COUNT(*) AS beneficiaries_not_joined_employment
FROM rbl_data
WHERE Joining_Status = 'Not Accepted & Joined';


2. Currently employed female beneficiaries
SELECT
    COUNT(*) AS currently_employed_female_beneficiaries
FROM rbl_data
WHERE currently_working_in_BFSI IN ('Yes in the same sector', 'Yes in another sector')
    AND Gender = 'Female';


3. Cohort-wise employment continuity beyond 12 months
SELECT 
Year AS financial_year,
COUNT(*) AS total_placed_beneficiaries,
 SUM(
 CASE
    WHEN currently_working_in_BFSI IN (
                'Yes in the same sector',
                'Yes in another sector'
            )
      AND DATEDIFF(CURDATE(), Placement_Date) > 365
   THEN 1
     WHEN currently_working_in_BFSI = 'No'
      AND If_not_working_last_day_of_job IS NOT NULL
       AND DATEDIFF(
                If_not_working_last_day_of_job,
                Placement_Date
            ) > 365
     THEN 1
     ELSE 0
    END
) AS beneficiaries_with_employment_continuity_beyond_12_months,
ROUND(
        SUM(
            CASE
                WHEN currently_working_in_BFSI IN (
                    'Yes in the same sector',
                    'Yes in another sector'
                )
                AND DATEDIFF(CURDATE(), Placement_Date) > 365
                THEN 1
                WHEN currently_working_in_BFSI = 'No'
                AND If_not_working_last_day_of_job IS NOT NULL
                AND DATEDIFF(
                    If_not_working_last_day_of_job,
                    Placement_Date
                ) > 365
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),2) AS employment_continuity_beyond_12_months_percentage
FROM rbl_data
WHERE Joining_Status = 'Accepted & Joined'
GROUP BY Year
ORDER BY Year;


4.Currently employed beneficiaries in the BFSI sector
SELECT 
    Year,
    Gender,
    Placement_Date,
    currently_working_in_BFSI
FROM rbl_data_final
WHERE Joining_Status = 'Accepted & Joined'
AND currently_working_in_BFSI = 'Yes in the same sector'
ORDER BY Year, Placement_Date;


5. Beneficiaries Who Earned Income After Training
SELECT 
    earned_income_after_training,
    COUNT(*) AS total_beneficiaries,
    ROUND(
        COUNT(*) * 100.0 / (
            SELECT COUNT(*)
            FROM beneficiary_hh
            WHERE earned_income_after_training IS NOT NULL
        ),2) AS percentage
FROM beneficiary_hh
WHERE earned_income_after_training IS NOT NULL
GROUP BY earned_income_after_training;








6. Cohort-wise overall employment retention and BFSI retention
SELECT
    Year AS `Financial Year`,
    COUNT(CASE
            WHEN Joining_Status = 'Accepted & Joined'
            THEN 1
        END ) AS `Total Placed`,
    COUNT(  CASE
            WHEN currently_working_in_BFSI IN
            ('Yes in the same sector', 'Yes in another sector')
            THEN 1
        END
    ) AS `Currently Working`,
    ROUND(
        COUNT(
            CASE
                WHEN currently_working_in_BFSI IN
                ('Yes in the same sector', 'Yes in another sector')
                THEN 1
            END
        ) * 100.0
        /
        NULLIF(
            COUNT(
                CASE
                    WHEN Joining_Status = 'Accepted & Joined'
                    THEN 1
                END
            ),
            0
        ),
        2
    ) AS `Overall Employment Retention (%)`,
    COUNT(
        CASE
            WHEN currently_working_in_BFSI = 'Yes in the same sector'
            THEN 1
        END
    ) AS `Currently Working in BFSI`,
    ROUND(
        COUNT(
            CASE
                WHEN currently_working_in_BFSI = 'Yes in the same sector'
                THEN 1
            END
        ) * 100.0
        /
        NULLIF(
            COUNT(
                CASE
                    WHEN Joining_Status = 'Accepted & Joined'
                    THEN 1
                END
            ),
            0
        ),
        2
    ) AS `BFSI Retention (%)`


FROM rbl_data
GROUP BY Year
ORDER BY Year;


7. Average starting salary versus average latest salary
SELECT
    ROUND(AVG(NULLIF(salary, 0)), 2) AS `Average Starting Salary`,
    ROUND(AVG(CASE
           WHEN currently_working_in_bfsi IN ('Yes in the same sector', 'Yes in another sector')
                THEN NULLIF(if_working_current_salary, 0)
                WHEN currently_working_in_bfsi = 'No'
                THEN NULLIF(if_not_working_last_salary_drawn, 0)
            END), 2 ) AS `Average Latest Salary`
FROM rbl_data;