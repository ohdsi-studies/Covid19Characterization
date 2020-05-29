@target_strata_xref_table_create

DELETE FROM @cohort_database_schema.@cohort_staging_table
WHERE cohort_definition_id IN (SELECT DISTINCT cohort_id FROM #TARGET_STRATA_XREF)
;

INSERT INTO @cohort_database_schema.@cohort_staging_table (
  cohort_definition_id,
  subject_id,
  cohort_start_date,
  cohort_end_date
)
SELECT 
  x.cohort_id,
  s.subject_id,
  s.cohort_start_date,
  s.cohort_end_date
FROM (
  -- Stratify the cohort
  SELECT 
    c.cohort_definition_id, 
    c.subject_id, 
    c.cohort_start_date, 
    c.cohort_end_date,
    CASE 
      WHEN DATEDIFF(dd, c.cohort_start_date, c.cohort_end_date) + 1 >= @strata_value THEN 'TwS'
      ELSE 'TwoS'
    END cohort_type
  FROM @cohort_database_schema.@cohort_staging_table c
  INNER JOIN (SELECT DISTINCT target_id FROM #TARGET_STRATA_XREF) x ON x.target_id = c.cohort_definition_id
) s
INNER JOIN #TARGET_STRATA_XREF x ON s.cohort_definition_id = x.target_id AND s.cohort_type = x.cohort_type
;

@target_strata_xref_table_drop