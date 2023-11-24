-- =====================================================================================================================
SELECT password, Concat(first_name, ' ', last_name) AS name
FROM student
WHERE srn = '${req.body.id}';

SELECT password, Concat(first_name, ' ', last_name) AS name
FROM faculty
WHERE id = '${req.body.id}';

-- =====================================================================================================================
INSERT INTO student
VALUES ('${req.body.id}',
        '${req.body.details.firstName}',
        '${req.body.details.lastName}',
        '${req.body.details.dept}',
        ${req.body.details.sem},
        '${req.body.details.sec}',
        '${req.body.pwd}');

INSERT INTO faculty
VALUES ('${req.body.id}',
        '${req.body.details.firstName}',
        '${req.body.details.lastName}',
        '${req.body.details.dept}',
        '${req.body.details.domain}',
        '${req.body.pwd}');

-- =====================================================================================================================
SELECT id                    AS projectID,
       topic                 AS projectTitle,
       status                AS projectStatus,
       getFacultyDetails(id) AS faculty,
       getStudentDetails(id) AS student
FROM paper AS t1
WHERE EXISTS (SELECT *
              FROM student_writes_paper AS t2
              WHERE srn = 'PES2UG21CS001'
                AND t1.id = t2.paper_id)
ORDER BY projectID;

SELECT id                    AS projectID,
       topic                 AS projectTitle,
       status                AS projectStatus,
       getFacultyDetails(id) AS faculty,
       getStudentDetails(id) AS student
FROM paper AS t1
WHERE EXISTS (SELECT *
             FROM faculty_advises_paper AS t2
             WHERE faculty_id = '${req.body.id}'
               AND t1.id = t2.paper_id)
ORDER BY projectID;

SELECT id                    AS projectID,
       topic                 AS projectTitle,
       status                AS projectStatus,
       getFacultyDetails(id) AS faculty,
       getStudentDetails(id) AS student
FROM paper
WHERE status = 'Published'
ORDER BY projectID;

-- =====================================================================================================================
START TRANSACTION;

INSERT INTO paper (topic, status, start_date, end_date)
VALUES ('${req.body.projectTitle}',
        '${req.body.projectStatus}',
        '${req.body.startDate}',
        '${req.body.endDate}');

INSERT INTO paper (topic, status, start_date)
VALUES ('${req.body.projectTitle}',
        '${req.body.projectStatus}',
        '${req.body.startDate}');

SELECT id
FROM paper
ORDER BY id DESC
LIMIT 1;

#         valuesQuery = ``;
#         req.body.studentID.forEach((item, index) => {
#             if (index !== 0)
#                 valuesQuery += `,`;
#             valuesQuery += `('${item}', '${projectID}')`;
#         });
#         sqlQuery = `INSERT INTO student_writes_paper
#                     VALUES ` + valuesQuery;

#         valuesQuery = ``;
#         req.body.facultyID.forEach((item, index) => {
#             if (index !== 0)
#                 valuesQuery += `,`;
#             valuesQuery += `('${item}', '${projectID}')`;
#         });
#         sqlQuery = `INSERT INTO faculty_advises_paper (Faculty_ID, Paper_ID)
#                     VALUES ` + valuesQuery;

COMMIT;

-- =====================================================================================================================
SELECT id                                  AS projectID,
       topic                               AS projectTitle,
       status                              AS projectStatus,
       Date_Format(start_date, '%Y-%m-%d') AS startDate,
       Date_Format(end_date, '%Y-%m-%d')   AS endDate,
       getFacultyDetails(id)               AS faculty,
       getStudentDetails(id)               AS student
FROM paper
WHERE id = ${req.body.projectID};

-- =====================================================================================================================
START TRANSACTION;

UPDATE paper
SET topic = '${req.body.projectTitle}'
WHERE id = ${req.body.projectID};

UPDATE paper
SET topic = '${req.body.projectTitle}'
WHERE id = ${req.body.projectID};

UPDATE paper
SET status = '${req.body.projectStatus}'
WHERE id = ${req.body.projectID};

UPDATE paper
SET start_date = '${req.body.startDate}'
WHERE id = ${req.body.projectID};

UPDATE paper
SET end_date = '${req.body.endDate}'
WHERE id = ${req.body.projectID};

UPDATE paper
SET end_date = NULL
WHERE id = ${req.body.projectID};

DELETE
FROM student_writes_paper
WHERE paper_id = ${req.body.projectID};

#             valuesQuery = ``;
#             req.body.studentID.forEach((item, index) => {
#                 if (index !== 0)
#                     valuesQuery += `,`;
#                 valuesQuery += `('${item}', '${req.body.projectID}')`;
#             });
#             sqlQuery = `INSERT INTO student_writes_paper
#                         VALUES ` + valuesQuery;

DELETE
FROM faculty_advises_paper
WHERE paper_id = ${req.body.projectID};

#             valuesQuery = ``;
#             req.body.facultyID.forEach((item, index) => {
#                 if (index !== 0)
#                     valuesQuery += `,`;
#                 valuesQuery += `('${item}', '${req.body.projectID}')`;
#             });
#             sqlQuery = `INSERT INTO faculty_advises_paper (faculty_id, paper_id)
#                         VALUES ` + valuesQuery;

COMMIT;

-- =====================================================================================================================
DELETE
FROM paper
WHERE id = ${req.body.projectID};

-- =====================================================================================================================
INSERT INTO meeting(paper_id, start_time, end_time, link, remarks)
VALUES ('${req.body.projectID}',
        '${req.body.startTime}',
        '${req.body.endTime}',
        '${req.body.link}',
        '${req.body.remarks}');

-- =====================================================================================================================
SELECT id,
       DATE_FORMAT(start_time, '%Y-%m-%d %H-%i-%s') AS startTime,
       DATE_FORMAT(end_time, '%Y-%m-%d %H-%i-%s')   AS endTime,
       link,
       status,
       remarks
FROM meeting
WHERE paper_id = ${req.body.projectID};

-- =====================================================================================================================
START TRANSACTION;

UPDATE meeting
SET status = '${req.body.status}'
WHERE id = ${req.body.meetingID};

UPDATE meeting
SET start_time = '${req.body.startTime}',
    status     = 'Requested'
WHERE id = ${req.body.meetingID};

UPDATE meeting
SET end_time = '${req.body.endTime}',
    status   = 'Requested'
WHERE id = ${req.body.meetingID};

UPDATE meeting
SET link = '${req.body.link}'
WHERE id = ${req.body.meetingID};

UPDATE meeting
SET remarks = '${req.body.remarks}',
    status  = 'Requested'
WHERE id = ${req.body.meetingID};
COMMIT;

-- =====================================================================================================================
INSERT INTO faculty_advises_paper
VALUES ('${req.body.facultyID}',
        '${req.body.projectID}',
        '${req.body.suggestion}',
        Now());

-- =====================================================================================================================
SELECT t1.*, Concat(first_name, ' ', last_name) AS name
FROM (SELECT faculty_id AS id, suggestions AS msg, DATE_FORMAT(timestamp, '%Y-%m-%d %H-%i-%s') AS time
      FROM faculty_advises_paper
      WHERE paper_id = ${req.body.projectID}
        AND suggestions <> '') AS t1
         NATURAL JOIN faculty;

-- =====================================================================================================================
SELECT doi, keywords, DATE_FORMAT(date, '%Y-%m-%d') AS date, authors, datasets
FROM literature_survey
         NATURAL JOIN
     (select doi, Concat('[', Group_Concat(Concat('"', first_name, ' ', last_name, '"')), ']') AS authors
      from literature_survey_authors
      group by doi) AS t1
         NATURAL JOIN
     (select doi, Concat('[', Group_Concat(Concat('"', dataset, '"')), ']') AS datasets
      from literature_survey_datasets
      group by doi) AS t2;

-- =====================================================================================================================
SELECT srn
FROM student;

SELECT id
FROM faculty;

-- =====================================================================================================================
SHOW tables;

-- =====================================================================================================================