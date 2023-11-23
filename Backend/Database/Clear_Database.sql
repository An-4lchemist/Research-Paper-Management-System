USE research_mgmt;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE paper_refs_literature_survey;
TRUNCATE TABLE literature_survey_datasets;
TRUNCATE TABLE literature_survey_authors;
TRUNCATE TABLE literature_survey;

TRUNCATE TABLE faculty_advises_paper;
TRUNCATE TABLE faculty;

TRUNCATE TABLE student_writes_paper;
TRUNCATE TABLE student;

TRUNCATE TABLE meeting;
TRUNCATE TABLE paper;

SET FOREIGN_KEY_CHECKS = 1;