CREATE DATABASE research_mgmt;

USE research_mgmt;

CREATE TABLE paper
(
    `ID`         INT PRIMARY KEY AUTO_INCREMENT,
    `Topic`      VARCHAR(255)                  NOT NULL,
    `Status`     ENUM ('Published', 'Ongoing') NOT NULL DEFAULT 'Ongoing',
    `Start_Date` DATE                          NOT NULL,
    `End_Date`   DATE                          NULL
);

CREATE TABLE meeting
(
    `ID`         INT PRIMARY KEY AUTO_INCREMENT,
    `Paper_ID`   INT                                        NOT NULL,
    `Start_Time` DATETIME                                   NOT NULL,
    `End_Time`   DATETIME                                   NOT NULL,
    `Link`       VARCHAR(255) UNIQUE                        NOT NULL,
    `Status`     ENUM ('Accepted', 'Rejected', 'Requested') NOT NULL DEFAULT 'Requested',
    `Remarks`    VARCHAR(255)                               NOT NULL,
    CONSTRAINT FK_meeting_paper_id FOREIGN KEY (Paper_ID) REFERENCES paper (ID) ON DELETE CASCADE
);

CREATE TABLE student
(
    `SRN`        CHAR(13) PRIMARY KEY,
    `First_Name` VARCHAR(25)                              NOT NULL,
    `Last_Name`  VARCHAR(25)                              NOT NULL,
    `Department` ENUM ('CSE', 'ECE', 'EEE', 'AIML', 'ME') NOT NULL,
    `Semester`   NUMERIC(1)                               NOT NULL,
    `Section`    CHAR(1)                                  NOT NULL,
    `Password`   VARCHAR(20)                              NOT NULL
);

CREATE TABLE student_writes_paper
(
    `SRN`      CHAR(13),
    `Paper_ID` INT,
    PRIMARY KEY (SRN, Paper_ID),
    CONSTRAINT FK_student_writes_paper_student_srn FOREIGN KEY (SRN) REFERENCES student (SRN) ON DELETE CASCADE,
    CONSTRAINT FK_student_writes_paper_paper_id FOREIGN KEY (Paper_ID) REFERENCES paper (ID) ON DELETE CASCADE
);

CREATE TABLE faculty
(
    `ID`         CHAR(8) PRIMARY KEY,
    `First_Name` VARCHAR(25)                              NOT NULL,
    `Last_Name`  VARCHAR(25)                              NOT NULL,
    `Department` ENUM ('CSE', 'ECE', 'EEE', 'AIML', 'ME') NOT NULL,
    `Domain`     VARCHAR(50)                              NOT NULL,
    `Password`   VARCHAR(20)                              NOT NULL
);

CREATE TABLE faculty_advises_paper
(
    `Faculty_ID`  CHAR(8)      NOT NULL,
    `Paper_ID`    INT          NOT NULL,
    `Suggestions` VARCHAR(200) NOT NULL DEFAULT '',
    `Timestamp`   DATETIME     NOT NULL DEFAULT '2020-01-01 00:00:00',
    PRIMARY KEY (Faculty_ID, Paper_ID, Suggestions),
    CONSTRAINT FK_faculty_advises_paper_faculty_id FOREIGN KEY (Faculty_ID) REFERENCES faculty (ID) ON DELETE CASCADE,
    CONSTRAINT FK_faculty_advises_paper_paper_id FOREIGN KEY (Paper_ID) REFERENCES paper (ID) ON DELETE CASCADE
);

CREATE TABLE literature_survey
(
    `DOI`      VARCHAR(50) PRIMARY KEY,
    `Keywords` VARCHAR(300) NOT NULL,
    `Date`     DATE         NOT NULL
);

CREATE TABLE literature_survey_authors
(
    `DOI`        VARCHAR(50) NOT NULL,
    `First_Name` VARCHAR(25) NOT NULL,
    `Last_Name`  VARCHAR(25) NOT NULL,
    PRIMARY KEY (DOI, First_Name, Last_Name),
    CONSTRAINT FK_literature_survey_authors_literature_survey_doi
        FOREIGN KEY (DOI) REFERENCES literature_survey (DOI) ON DELETE CASCADE
);

CREATE TABLE literature_survey_datasets
(
    `DOI`     VARCHAR(50) NOT NULL,
    `Dataset` VARCHAR(50) NOT NULL,
    PRIMARY KEY (DOI, Dataset),
    CONSTRAINT FK_literature_survey_datasets_literature_survey_doi
        FOREIGN KEY (DOI) REFERENCES literature_survey (DOI) ON DELETE CASCADE
);

CREATE TABLE paper_refs_literature_survey
(
    `DOI`      VARCHAR(50) NOT NULL,
    `Paper_ID` INT         NOT NULL,
    PRIMARY KEY (DOI, Paper_ID),
    CONSTRAINT FK_paper_refs_literature_survey_literature_survey_doi
        FOREIGN KEY (DOI) REFERENCES literature_survey (DOI) ON DELETE RESTRICT,
    CONSTRAINT FK_paper_refs_literature_survey_paper_id FOREIGN KEY (Paper_ID) REFERENCES paper (ID) ON DELETE CASCADE
);

CREATE FUNCTION getStudentDetails(project_id INT)
    RETURNS VARCHAR(500)
    NOT DETERMINISTIC
    READS SQL DATA
BEGIN
    DECLARE ret_value VARCHAR(500);

    SELECT Concat('[', Group_Concat(studentDetails), ']')
    INTO ret_value
    FROM (SELECT * FROM student_writes_paper WHERE paper_id = project_id) AS t1
             NATURAL JOIN (SELECT srn,
                                  Concat('{ "id": "', srn, '", "name": "', first_name, ' ', last_name, '" }')
                                      AS studentDetails
                           FROM student) AS t2
    GROUP BY paper_id;

    RETURN (IFNULL(ret_value, '[]'));
END;

CREATE FUNCTION getFacultyDetails(project_id INT)
    RETURNS VARCHAR(500)
    NOT DETERMINISTIC
    READS SQL DATA
BEGIN
    DECLARE ret_value VARCHAR(500);

    SELECT Concat('[', Group_Concat(facultyDetails), ']')
    INTO ret_value
    FROM (SELECT DISTINCT faculty_id AS id, paper_id FROM faculty_advises_paper WHERE paper_id = project_id) AS t2
             NATURAL JOIN (SELECT id,
                                  Concat('{ "id": "', id, '", "name": "', first_name, ' ', last_name, '" }')
                                      AS facultyDetails
                           FROM faculty) AS t3
    GROUP BY paper_id;

    RETURN (IFNULL(ret_value, '[]'));
END;

CREATE TRIGGER checkStudentSRN
    BEFORE INSERT
    ON student
    FOR EACH ROW
BEGIN
    IF NOT REGEXP_LIKE(NEW.SRN, 'PES[12]UG[1-9][1-9](CS|EC|EE|ME|AI)[0-9][0-9][0-9]') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid ID';
    END IF;
END;

CREATE TRIGGER checkFacultyID
    BEFORE INSERT
    ON faculty
    FOR EACH ROW
BEGIN
    IF NOT REGEXP_LIKE(NEW.ID, 'PES(CS|EC|EE|ME|AI)[0-9][0-9][0-9]') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid ID';
    END IF;
END;
