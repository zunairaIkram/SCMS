create database SCMS
drop database SCMS
use SCMS

-- ClubMember Table-------------------------------------------------------------------------------
CREATE TABLE ClubMember (
    memberID INT NOT NULL IDENTITY(1,1),
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    contactNo VARCHAR(255) NOT NULL,
    address VARCHAR(255),
    email VARCHAR(255),      
    DOB DATE,
    membershipType VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL DEFAULT 'Inactive',

    -- Constraints and checks
    CONSTRAINT PK_ClubMember PRIMARY KEY (memberID),
    CONSTRAINT UQ_ClubMember_contactNo UNIQUE (contactNo),
    CONSTRAINT UQ_ClubMember_email UNIQUE (email),
    CONSTRAINT CK_ClubMember_firstName CHECK (LEN(firstName) > 0),
    CONSTRAINT CK_ClubMember_lastName CHECK (LEN(lastName) > 0),
    CONSTRAINT CK_ClubMember_DOB CHECK (DOB <= DATEADD(year, -18, GETDATE()) AND DOB > DATEADD(year, -35, GETDATE())),
    CONSTRAINT CK_ClubMember_membershipType CHECK (membershipType IN ('Lifetime', 'Guest', 'Student', 'Individual', 'Competitive')),
    CONSTRAINT CK_ClubMember_status CHECK (status IN ('Active', 'Inactive'))
);

select * from ClubMember
truncate table ClubMember
drop table ClubMember

-- Trainer Table----------------------------------------------------------------------------------
CREATE TABLE Trainer (
    trainerID INT NOT NULL IDENTITY(1,1),
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    contactNo VARCHAR(20) NOT NULL,
    address VARCHAR(255),
    email VARCHAR(255),
    DOB DATE,
    hiringDate DATE NOT NULL,
    certification VARCHAR(255),

    -- Constraints and checks
    CONSTRAINT PK_Trainer PRIMARY KEY (trainerID),
    CONSTRAINT UQ_Trainer_contactNo UNIQUE (contactNo),
    CONSTRAINT UQ_Trainer_email UNIQUE (email),
    CONSTRAINT CK_Trainer_firstName CHECK (LEN(firstName) > 0),
    CONSTRAINT CK_Trainer_lastName CHECK (LEN(lastName) > 0),
    CONSTRAINT CK_Trainer_DOB CHECK (DOB < DATEADD(year, -25, GETDATE()) AND DOB > DATEADD(year, -60, GETDATE())),
    CONSTRAINT CK_Trainer_certification CHECK (certification IN ('Swimming', 'Diving', 'Water Polo', 'Synchronized Swimming', 'Water Safety and life saving', 'Competitive Swim Coaching')),
	CONSTRAINT CK_Trainer_hiringDate CHECK (hiringDate >= DATEADD(year, 25, DOB) AND hiringDate <= GETDATE() AND hiringDate >= DATEADD(year, -2, GETDATE()))
);

select * from Trainer
truncate table Trainer
drop table Trainer

-- Pool Table------------------------------------------------------------------------------------
CREATE TABLE Pool (
    poolID INT NOT NULL IDENTITY(1,1),
    poolName VARCHAR(50) NOT NULL,
    poolType VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL,

    -- Constraints and checks
    CONSTRAINT PK_Pool PRIMARY KEY (poolID),
    CONSTRAINT CK_Pool_poolName CHECK (LEN(poolName) > 0),
    CONSTRAINT CK_Pool_poolType CHECK (poolType IN ('Indoor', 'Outdoor', 'Lap', 'Diving', 'Leisure', 'Wave', 'Therapy')),
    CONSTRAINT CK_Pool_status CHECK (status IN ('Functional', 'Under Maintainance')),
    CONSTRAINT UQ_Pool_poolName UNIQUE (poolName)
);

select * from Pool
truncate table Pool
drop table Pool

-- Classes Table----------------------------------------------------------------------------------
CREATE TABLE Class (
    classID INT NOT NULL IDENTITY(1,1),
    poolID INT NOT NULL,
    trainerID INT,
    className VARCHAR(255) NOT NULL,
    dayOfWeek VARCHAR(50),
    startTime TIME,
    endTime TIME,
    skillLevel VARCHAR(255),
    ageGroup VARCHAR(255),
    classDescription VARCHAR(255),

    FOREIGN KEY (trainerID) REFERENCES Trainer(trainerID),
    FOREIGN KEY (poolID) REFERENCES Pool(poolID),

    CONSTRAINT PK_Class PRIMARY KEY (classID),
    CONSTRAINT CK_Class_dayOfWeek CHECK (dayOfWeek IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    CONSTRAINT CK_Class_skillLevel CHECK (skillLevel IN ('Beginner', 'Intermediate', 'Advanced')),
    CONSTRAINT CK_Class_ageGroup CHECK (ageGroup IN ('Teens', 'Adults', 'All Ages')),
    CONSTRAINT CK_Class_time CHECK (startTime < endTime OR endTime IS NULL)
);
select * from Class
truncate table Class
drop table Class

-- Enrollment Table--------------------------------------------------------------------------------------------
CREATE TABLE Enrollment (
    enrollmentID INT NOT NULL IDENTITY(1,1),
    memberID INT NOT NULL,
    classID INT NOT NULL,
    enrollmentDate DATE,         
    status VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Enrollment PRIMARY KEY (enrollmentID),
    -- Foreign keys
    FOREIGN KEY (memberID) REFERENCES ClubMember(memberID),
    FOREIGN KEY (classID) REFERENCES Class(classID),

    -- Constraints and checks
    CONSTRAINT CK_Enrollment_status CHECK (status IN ('Active', 'Completed', 'Cancelled')),

    -- Unique constraint
    CONSTRAINT UQ_Enrollment_memberID_classID UNIQUE (memberID, classID) -- a member cannot be enrolled in the same class more than once.
);

select * from Enrollment
truncate table Enrollment
drop table Enrollment


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Event Table----------------------------------------------------------------------------------------------
CREATE TABLE Event (
    eventID INT NOT NULL IDENTITY(1,1),
    eventName VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    eventDate DATE NOT NULL,
    eventType VARCHAR(255),  

    CONSTRAINT PK_Event PRIMARY KEY (eventID),
    CONSTRAINT UQ_Event_eventName UNIQUE (eventName),
    CONSTRAINT CK_Event_eventType CHECK (eventType IN ('Tournament', 'Training Session', 'Meetup', 'Competition')),
);

select * from Event
truncate table Event
drop table Event

-- Team Table-------------------------------------------------------------------------------------------
CREATE TABLE Team (
    teamID INT NOT NULL IDENTITY(1,1),
    teamName VARCHAR(50) NOT NULL,
    ageGroups VARCHAR(255),

    -- Constraints and checks
    CONSTRAINT PK_Team PRIMARY KEY (teamID),
    CONSTRAINT UQ_Team_teamName UNIQUE (teamName),
    CONSTRAINT CK_Team_ageGroups CHECK (ageGroups IN ('Teens', 'Adults', 'All Ages'))
);

select * from Team
drop table Team
truncate table Team

-- EventTeam Associative Table
CREATE TABLE EventTeam (
    eventTeamID INT NOT NULL IDENTITY(1,1),
    eventID INT NOT NULL,
    teamID INT NOT NULL,

	CONSTRAINT PK_EventTeam PRIMARY KEY (eventTeamID),
    -- Foreign keys
    FOREIGN KEY (eventID) REFERENCES Event(eventID),
    FOREIGN KEY (teamID) REFERENCES Team(teamID),

    -- Constraints
    CONSTRAINT UQ_EventTeam_eventID_teamID UNIQUE (eventID, teamID)
);
select * from EventTeam
truncate table EventTeam
drop table EventTeam

-- TeamMembers Associative Table -----------------------------------------------------------------------------------
CREATE TABLE TeamMember (
    teamMemberID INT NOT NULL IDENTITY(1,1),
    teamID INT NOT NULL,
	memberID INT NOT NULL,

    -- Foreign keys
    FOREIGN KEY (memberID) REFERENCES ClubMember(memberID),
    FOREIGN KEY (teamID) REFERENCES Team(teamID),

    -- Constraints and checks
    CONSTRAINT PK_TeamMember PRIMARY KEY (teamMemberID),
    CONSTRAINT UQ_TeamMember_memberID UNIQUE (memberID) -- One member can only be a part of one team
);

select * from TeamMember
truncate table TeamMember
drop table TeamMember

-- Payment Table------------------------------------------------------------------------------------
CREATE TABLE Payment (
    paymentID INT NOT NULL IDENTITY(1,1),
    memberID INT NOT NULL,
    classID INT, 
    eventID INT,
    paymentDate DATE NOT NULL,

    amount INT NOT NULL CHECK (amount > 0),
    paymentMethod VARCHAR(50) CHECK (paymentMethod IN ('Credit Card', 'Cash', 'Online Transfer')),
    paymentStatus VARCHAR(50) CHECK (paymentStatus IN ('Completed', 'Pending', 'Failed')),
    paymentType VARCHAR(50) CHECK (paymentType IN ('Membership Fee', 'Class Fee', 'Event Fee')),

    FOREIGN KEY (classID) REFERENCES Class(classID),
    FOREIGN KEY (eventID) REFERENCES Event(eventID),
	FOREIGN KEY (memberID) REFERENCES ClubMember(memberID),

    CONSTRAINT PK_Payment PRIMARY KEY (paymentID),
    --CONSTRAINT UQ_Payment_memberID_eventID UNIQUE (memberID, eventID),
    --CONSTRAINT UQ_Payment_memberID_classID UNIQUE (memberID, classID)
);
-- ensure that a member cannot have duplicate payments for the same event or class.


select * from Payment
truncate table Payment
drop table Payment

-- LockerRental Table-----------------------------------------------------------------------------------------
CREATE TABLE LockerRental (
    lockerNO INT NOT NULL IDENTITY(1,1),
    startDate DATE,
    endDate DATE,                 
    lockerSize VARCHAR(50),
    lockerStatus VARCHAR(50),        
    memberID INT,

    -- Foreign key
    FOREIGN KEY (memberID) REFERENCES ClubMember(memberID),

    -- Constraints and checks
    CONSTRAINT PK_LockerRental PRIMARY KEY (lockerNO),
    CONSTRAINT CK_LockerRental_dates CHECK (startDate < endDate OR endDate IS NULL),
    CONSTRAINT CK_LockerRental_lockerSize CHECK (lockerSize IN ('Small', 'Medium', 'Large', 'Extra Large')),
    CONSTRAINT CK_LockerRental_lockerStatus CHECK (lockerStatus IN ('Assigned', 'Not Assigned'))
);

select * from LockerRental
truncate table LockerRental
drop table LockerRental

--------Non Clustered Indexes------
CREATE NONCLUSTERED INDEX ClubMember_ContactNo ON ClubMember(ContactNo);
CREATE NONCLUSTERED INDEX ClubMember_MembershipType ON ClubMember(MembershipType);
CREATE NONCLUSTERED INDEX Trainer_Certification ON Trainer(Certification);
CREATE NONCLUSTERED INDEX Pool_poolName ON pool(poolName);
CREATE NONCLUSTERED INDEX Class_TrainerID ON Class(TrainerID);
CREATE NONCLUSTERED INDEX Class_poolID ON Class(poolID);
CREATE NONCLUSTERED INDEX Enrollment_MemberID ON Enrollment(MemberID);
CREATE NONCLUSTERED INDEX Enrollment_ClassID ON Enrollment(ClassID);
CREATE NONCLUSTERED INDEX EventTeam_eventID ON EventTeam(eventID);
CREATE NONCLUSTERED INDEX LockerRental_memberID ON LockerRental(memberID);
CREATE NONCLUSTERED INDEX Payment_memberID ON Payment(memberID);
CREATE NONCLUSTERED INDEX Payment_classID ON Payment(classID);
CREATE NONCLUSTERED INDEX Payment_eventID ON Payment(eventID);

SELECT *
FROM sys.indexes
--WHERE object_id = OBJECT_ID('ClubMember');


--Denormalized Table-------------------------------------------------------------------------------------------
CREATE TABLE DenormalizedPayments (
    paymentID INT NOT NULL,
    memberID INT NOT NULL,
    memberFirstName VARCHAR(50),
    memberLastName VARCHAR(50),
    membershipType VARCHAR(255),
    memberStatus VARCHAR(255),

    classID INT,
    className VARCHAR(255),
    classDayOfWeek VARCHAR(50),
    classStartTime TIME,
    classEndTime TIME,
    classSkillLevel VARCHAR(255),
    classAgeGroup VARCHAR(255),
    classDescription VARCHAR(255),

    eventID INT,
    eventName VARCHAR(255),
    eventLocation VARCHAR(255),
    eventDate DATE,
    eventType VARCHAR(255),

    paymentDate DATE NOT NULL,
    amount INT NOT NULL,
    paymentMethod VARCHAR(50),
    paymentStatus VARCHAR(50),
    paymentType VARCHAR(50),

    -- Composite Key for reference
    CONSTRAINT PK_DenormalizedPayments PRIMARY KEY (paymentID),

    -- Constraints and checks
    CONSTRAINT CK_DenormalizedPayments_paymentMethod CHECK (paymentMethod IN ('Credit Card', 'Cash', 'Online Transfer')),
    CONSTRAINT CK_DenormalizedPayments_paymentStatus CHECK (paymentStatus IN ('Completed', 'Pending', 'Failed')),
    CONSTRAINT CK_DenormalizedPayments_paymentType CHECK (paymentType IN ('Membership Fee', 'Class Fee', 'Event Fee'))
);

select * from DenormalizedPayments
truncate table DenormalizedPayments
drop table DenormalizedPayments

select * from DenormalizedPayments

SELECT
    p.paymentID,
    cm.memberID,
    cm.firstName AS memberFirstName,
    cm.lastName AS memberLastName,
    cm.membershipType,
    cm.status AS memberStatus,
    cl.classID,
    cl.className,
    cl.dayOfWeek AS classDayOfWeek,
    cl.startTime AS classStartTime,
    cl.endTime AS classEndTime,
    cl.skillLevel AS classSkillLevel,
    cl.ageGroup AS classAgeGroup,
    cl.classDescription,
    e.eventID,
    e.eventName,
    e.location AS eventLocation,
    e.eventDate,
    e.eventType,
    p.paymentDate,
    p.amount,
    p.paymentMethod,
    p.paymentStatus,
    p.paymentType
FROM
    Payment p
    LEFT JOIN ClubMember cm ON p.memberID = cm.memberID
    LEFT JOIN Class cl ON p.classID = cl.classID
    LEFT JOIN Event e ON p.eventID = e.eventID;


--Audit table-----------------------------------------------------------------------------------------------------
CREATE TABLE AuditTable(
    TableName VARCHAR(50), 
    ModifiedBy VARCHAR(50), 
    ModifiedDate DATETIME
);

create trigger Auditdelete
on Enrollment
after delete
as
insert into dbo.AuditTable
(TableName , ModifiedBy , ModifiedDate)

Values('Enrollment',SUSER_SNAME(),GETDATE())
GO

create trigger Auditinsert
on Enrollment
after insert
as
insert into dbo.AuditTable
(TableName , ModifiedBy , ModifiedDate)

Values('Enrollment',SUSER_SNAME(),GETDATE())
GO

create trigger Auditupdate
on Enrollment
after update
as
insert into dbo.AuditTable
(TableName , ModifiedBy , ModifiedDate)

Values('Enrollment',SUSER_SNAME(),GETDATE())
GO

DELETE FROM Enrollment
WHERE enrollmentID = 3

select * from AuditTable;

-----------------------------Update status procedure--------------------------------------------------------------------------------------------------------
-- Stored Procedure to Update Member Status in ClubMember and Enrollment Tables
CREATE PROCEDURE UpdateMemberStatusProcedure
AS
BEGIN
    SET NOCOUNT ON;

    -- Update Member Status in ClubMember Table
    UPDATE ClubMember
    SET status = CASE 
                    WHEN EXISTS (
                        SELECT 1 FROM Payment p
                        WHERE p.memberID = ClubMember.memberID 
                        AND p.paymentType = 'Membership Fee' 
                        AND p.paymentStatus = 'Completed'
                    ) THEN 'Active'
                    ELSE 'Inactive'
                 END;

    -- Update Member Status in Enrollment Table
    UPDATE Enrollment
    SET status = CASE 
                    WHEN EXISTS (
                        SELECT 1 FROM Payment p
                        WHERE p.memberID = Enrollment.memberID 
                        AND p.paymentType = 'Membership Fee' 
                        AND p.paymentStatus = 'Completed'
                    ) THEN 'Active'
                    ELSE 'Inactive'
                 END;
END;

-- Execute the Stored Procedure to Update Member Status
EXEC UpdateMemberStatusProcedure;

-- Create View for Displaying Member Status in ClubMember Table
CREATE VIEW ClubMemberStatusView AS
SELECT 
    c.memberID,
    c.firstName,
    c.lastName,
    c.status AS CurrentStatus
FROM ClubMember c;

-- Create View for Displaying Member Status in Enrollment Table
CREATE VIEW EnrollmentStatusView AS
SELECT 
    e.enrollmentID,
    e.memberID,
    e.classID,
    e.status AS EnrollmentStatus
FROM Enrollment e;

-- Query the ClubMemberStatusView
SELECT * FROM ClubMemberStatusView;

-- Query the EnrollmentStatusView
SELECT * FROM EnrollmentStatusView;
------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------Report from audit table--------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE GenerateAuditReport
AS
BEGIN
    SELECT 
        TableName, 
        ModifiedBy, 
        ModifiedDate,
        CASE 
            WHEN TableName = 'Enrollment' AND ModifiedBy IS NOT NULL THEN 'Operation Performed on Enrollment Table'
            ELSE 'Unknown Operation'
        END AS OperationDetails
    FROM 
        AuditTable
    ORDER BY 
        ModifiedDate DESC;
END;
GO

EXEC GenerateAuditReport;

--------------------------------------------DeNormalized Table Reports-------------------------------------------------


-- Monthly Revenue Trend:
-- This query provides a monthly breakdown of the total revenue.
CREATE PROCEDURE MonthlyRevenueTrend
AS
BEGIN
	SELECT
		YEAR(paymentDate) AS [Payment Year],
		MONTH(paymentDate) AS [Payment Month],
		CONCAT('Rs. ', SUM(amount)) AS [Monthly Revenue]
	FROM
		DenormalizedPayments
	GROUP BY
		YEAR(paymentDate), MONTH(paymentDate)
	ORDER BY
		YEAR(paymentDate), MONTH(paymentDate)
END;

EXEC MonthlyRevenueTrend



-- Total Payments for Completed Events:
-- This query calculates the total payments for events that have been completed.
CREATE PROCEDURE TotalPaymentsForCompletedEvents
AS
BEGIN
	SELECT
		eventID AS [Event ID],
		eventName AS [Event Name],
		CONCAT('Rs. ', SUM(amount)) AS [Total Payments]
	FROM
		DenormalizedPayments
	WHERE
		paymentStatus = 'Completed'
		AND eventType IS NOT NULL
	GROUP BY
		eventID, eventName
	ORDER BY
		eventID
END;

EXEC TotalPaymentsForCompletedEvents



-- Members with Pending Payments:
-- This query retrieves members who have pending payments, along with the total amount pending.
CREATE PROCEDURE MembersWithPendingPayments
AS
BEGIN
	SELECT
		memberID AS [Member ID],
		memberFirstName AS [Member's First Name],
		memberLastName AS [Member's Last Name],
		CONCAT( 'Rs. ', SUM( CASE WHEN paymentStatus = 'Pending' THEN amount ELSE 0 END ) ) AS [Pending Amount]
	FROM
		DenormalizedPayments
	GROUP BY
		memberID, memberFirstName, memberLastName
	HAVING
		SUM( CASE WHEN paymentStatus = 'Pending' THEN amount ELSE 0 END ) > 0
	ORDER BY 
		memberID
END;

EXEC MembersWithPendingPayments



-- Total Payments per Membership Type with Percentage:
-- This query calculates the total payments per membership type and the percentage of total payments for each type.
CREATE PROCEDURE TotalPaymentsPerMembershipTypeWithPercentage
AS
BEGIN
	SELECT
		membershipType AS [Membership Type],
		CONCAT('Rs. ', SUM(amount) ) AS [Total Payments],
		CONCAT( FORMAT( ( SUM(amount) * 100.00) / (
			SELECT
				SUM(amount)
			FROM
				DenormalizedPayments
			), 
		'N2'), '%') AS [Percentage of Total Payments]
	FROM
		DenormalizedPayments
	WHERE
		membershipType IS NOT NULL
	GROUP BY
		membershipType
	ORDER BY 
		SUM(amount) DESC, membershipType ASC
END;

EXEC TotalPaymentsPerMembershipTypeWithPercentage



--------------------------------------------Reports---------------------------------------------------------


-- Find the total revenue generated from class fees for each trainer.
CREATE PROCEDURE GeneratRevenue
AS
BEGIN
	SELECT 
	t.trainerID AS [Trainer ID], 
	t.firstName AS [Trainer's First Name], 
	t.lastName AS [Trainer's Last Name], 
	CONCAT( 'Rs. ', SUM(p.amount) ) AS [Total Class Revenue]
FROM 
	Trainer t
	INNER JOIN Class c 
	ON t.trainerID = c.trainerID
	LEFT JOIN Payment p 
	ON c.classID = p.classID
WHERE 
	p.paymentType = 'Class Fee'
GROUP BY 
	t.trainerID, t.firstName, t.lastName
ORDER BY 
	SUM(p.amount) DESC, t.trainerID ASC
END;

EXEC GeneratRevenue;

-- Identify classes with the highest average age of enrolled members.
CREATE PROCEDURE GenerateaverageAgeEnrollment
AS
BEGIN
	SELECT 
	c.classID AS [Class ID],
	c.className AS [Class Name], 
	CONCAT( AVG( DATEDIFF( YEAR, m.DOB, GETDATE() ) ), ' years') AS [Top Average Age]
FROM 
	Class c
	JOIN Enrollment e 
	ON c.classID = e.classID
	JOIN ClubMember m 
	ON e.memberID = m.memberID
GROUP BY 
	c.classID, c.className
HAVING 
	AVG(DATEDIFF(YEAR, m.DOB, GETDATE())) = ( 
		SELECT TOP 1 AVG(DATEDIFF(YEAR, m.DOB, GETDATE()))
		FROM Class c JOIN Enrollment e ON c.classID = e.classID
		JOIN ClubMember m ON e.memberID = m.memberID
		GROUP BY c.classID
		ORDER BY AVG(DATEDIFF(YEAR, m.DOB, GETDATE())) DESC 
		)
ORDER BY 
	c.classID
END;

EXEC GenerateaverageAgeEnrollment;



-- Identify events with the attendance in descending order
CREATE PROCEDURE GeneratAttendanceDesc
AS
BEGIN
	
SELECT 
	e.eventID AS [Event ID], 
	e.eventName AS [Event Name], 
	COUNT(et.teamID) AS [Attendance (Teams count)]
FROM 
	Event e
	LEFT JOIN EventTeam et 
	ON e.eventID = et.eventID
GROUP BY 
	e.eventID, e.eventName
ORDER BY 
	COUNT(et.teamID) DESC, e.eventId ASC
END;

EXEC GeneratAttendanceDesc;



-- Class Participation Statistics:
-- This query provides statistics on class participation, including the number of members and the 
-- average age of participants for each class.
CREATE PROCEDURE GeneratClassStatstics
AS
BEGIN
	SELECT
    c.classID AS [Class ID],
    c.className AS [Class Name],
    COUNT(e.memberID) AS [Number of Members],
    AVG(DATEDIFF(YEAR, cm.DOB, GETDATE())) AS [Average Participant Age]
FROM
    Class c
	LEFT JOIN Enrollment e 
	ON c.classID = e.classID
	LEFT JOIN ClubMember cm 
	ON e.memberID = cm.memberID
GROUP BY
    c.classID, c.className
ORDER BY 
	COUNT(e.memberID) DESC, 
	AVG(DATEDIFF(YEAR, cm.DOB, GETDATE())) ASC,
	c.className ASC,
	c.classID ASC
END;

EXEC GeneratClassStatstics;

-- Retrieve the members who have enrolled in the most classes.
CREATE PROCEDURE GenerateMemberEnrolledMax
AS
BEGIN
    SELECT 
	m.memberID AS [Member ID],
	m.firstName AS [Memeber's First Name],
	m.lastName AS [Member's Last Name], 
	COUNT(e.classID) AS [Enrolled Classes]
FROM 
	ClubMember m
	LEFT JOIN Enrollment e 
	ON m.memberID = e.memberID
GROUP BY 
	m.memberID, m.firstName, m.lastName
HAVING 
	COUNT(e.classID) = ( 
		SELECT TOP 1 COUNT(e.classID)
		FROM ClubMember m
		LEFT JOIN Enrollment e 
		ON m.memberID = e.memberID
		GROUP BY m.memberID
		ORDER BY COUNT(e.classID) DESC
	)
ORDER BY 
	m.memberID ASC
END;

EXEC GenerateMemberEnrolledMax;

-- Create a stored procedure for Team and Team Members Report
/*CREATE PROCEDURE GenerateTeamMembersReport
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.teamID AS TeamID,
        t.teamName AS TeamName,
        t.ageGroups AS TeamAgeGroup,
        m.memberID AS MemberID,
        m.firstName AS MemberFirstName,
        m.lastName AS MemberLastName,
        m.contactNo AS MemberContactNo,
        m.email AS MemberEmail
    FROM
        Team t
    LEFT JOIN
        TeamMember tm ON t.teamID = tm.teamID
    LEFT JOIN
        ClubMember m ON tm.memberID = m.memberID
    ORDER BY
        t.teamID, m.memberID;
END;

EXEC GenerateTeamMembersReport;*/

-- Create a stored procedure for Team Report with Calculations
CREATE PROCEDURE GenerateTeamReport
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.teamID AS TeamID,
        t.teamName AS TeamName,
        AVG(DATEDIFF(YEAR, m.DOB, GETDATE())) AS AverageMemberAge,
        COUNT(tm.teamMemberID) AS NumberOfMembers
    FROM
        Team t
    LEFT JOIN
        TeamMember tm ON t.teamID = tm.teamID
    LEFT JOIN
        ClubMember m ON tm.memberID = m.memberID
    GROUP BY
        t.teamID, t.teamName
    ORDER BY
        TeamID;
END;

EXEC GenerateTeamReport;

--Reports by using view-------------------------------------------------------------------------
-- Create a view for the report
CREATE VIEW MemberReportView AS
SELECT
    c.firstName,
    c.lastName,
    e.status AS MembershipStatus,  -- Use e.status from Enrollment table
    COUNT(e.enrollmentID) AS EnrollmentCount
FROM ClubMember c
LEFT JOIN Enrollment e ON c.memberID = e.memberID
GROUP BY c.firstName, c.lastName, e.status;  -- Use e.status here

drop view MemberReportView
 -- Query the view
SELECT * FROM MemberReportView;


-- Create a view for locker rental statistics (total, assigned, and unassigned lockers)
CREATE VIEW LockerRentalStatistics AS
SELECT
    lockerSize,
    COUNT(lockerNO) AS TotalLockers,
    SUM(CASE WHEN lockerStatus = 'Assigned' THEN 1 ELSE 0 END) AS AssignedLockers,
    SUM(CASE WHEN lockerStatus = 'Not Assigned' THEN 1 ELSE 0 END) AS UnassignedLockers
FROM LockerRental
GROUP BY lockerSize;

drop view LockerRentalStatistics
SELECT * FROM LockerRentalStatistics;


-------------------Insertion Procedure--------------------------------------
/*CREATE PROCEDURE InsertClubMember
    @firstName VARCHAR(50),
    @lastName VARCHAR(50),
    @contactNo VARCHAR(255),
    @address VARCHAR(255),
    @email VARCHAR(255),
    @DOB DATE,
    @membershipType VARCHAR(255),
    @status VARCHAR(255) = 'Inactive'
AS
BEGIN
    INSERT INTO ClubMember (firstName, lastName, contactNo, address, email, DOB, membershipType, status)
    VALUES (@firstName, @lastName, @contactNo, @address, @email, @DOB, @membershipType, @status);
END;

drop procedure InsertClubMember

EXEC InsertClubMember
    @firstName = 'John',
    @lastName = 'Doe',
    @contactNo = '1234567890',
    @address = '123 Main St',
    @email = 'john.doe@example.com',
    @DOB = '1990-01-01',
    @membershipType = 'Lifetime',
    @status = 'Active';*/


--calculates the revenue a trainer gives
CREATE PROCEDURE TrainerPerformanceReport
AS
BEGIN
    SET NOCOUNT ON;

    -- Create a temporary table to store intermediate results
    CREATE TABLE #TrainerPerformance (
        TrainerID INT,
        TrainerName VARCHAR(100),
        TotalRevenue INT,
        AverageSkillLevel FLOAT
    );

    -- Insert data into the temporary table
    INSERT INTO #TrainerPerformance (TrainerID, TrainerName, TotalRevenue, AverageSkillLevel)
    SELECT
        T.trainerID,
        CONCAT(T.firstName, ' ', T.lastName) AS TrainerName,
        SUM(P.amount) AS TotalRevenue,
        AVG(CASE 
               WHEN TRY_CAST(C.skillLevel AS FLOAT) IS NOT NULL THEN TRY_CAST(C.skillLevel AS FLOAT)
               ELSE 0 
           END) AS AverageSkillLevel
    FROM
        Trainer T
    LEFT JOIN
        Class C ON T.trainerID = C.trainerID
    LEFT JOIN
        Payment P ON C.classID = P.classID
    WHERE
        P.paymentStatus = 'Completed'
        AND P.paymentType = 'Class Fee'
    GROUP BY
        T.trainerID, T.firstName, T.lastName;

    -- Retrieve data from the temporary table
    SELECT
        TrainerID,
        TrainerName,
        TotalRevenue
    FROM
        #TrainerPerformance
    ORDER BY
        TotalRevenue DESC;

    -- Drop the temporary table
    DROP TABLE #TrainerPerformance;
END;

drop procedure TrainerPerformanceReport

EXEC TrainerPerformanceReport;

-- Average Class Size Report
/*CREATE PROCEDURE AverageClassSizeReport
AS
BEGIN
    SET NOCOUNT ON;

    -- Create a temporary table to store intermediate results
    CREATE TABLE #AverageClassSize (
        ClassID INT,
        ClassName VARCHAR(255),
        AverageClassSize FLOAT
    );

    -- Insert data into the temporary table
    INSERT INTO #AverageClassSize (ClassID, ClassName, AverageClassSize)
    SELECT
        C.classID,
        C.className,
        AVG(CASE WHEN E.status = 'Active' THEN 1 ELSE 0 END) AS AverageClassSize
    FROM
        Class C
    LEFT JOIN
        Enrollment E ON C.classID = E.classID
    GROUP BY
        C.classID, C.className;

    -- Retrieve data from the temporary table
    SELECT
        ClassID,
        ClassName,
        AverageClassSize
    FROM
        #AverageClassSize
    ORDER BY
        AverageClassSize DESC;

    -- Drop the temporary table
    DROP TABLE #AverageClassSize;
END;

EXEC AverageClassSizeReport;*/

-- Pool Aggregated Statistics Report
/*CREATE PROCEDURE PoolStatisticsReport
AS
BEGIN
    SET NOCOUNT ON;

    -- Main query to retrieve pool statistics
    SELECT
        p.poolID AS [Pool ID],
        p.poolName AS [Pool Name],
        p.poolType AS [Pool Type],
        p.status AS [Pool Status],
        COUNT(DISTINCT c.classID) AS [Total Classes],
        COUNT(DISTINCT e.enrollmentID) AS [Total Enrollments],
        SUM(CASE WHEN e.status = 'Active' THEN 1 ELSE 0 END) AS [Active Enrollments],
        COUNT(DISTINCT tm.teamMemberID) AS [Total Team Members]
    FROM
        Pool p
    LEFT JOIN
        Class c ON p.poolID = c.poolID
    LEFT JOIN
        Enrollment e ON c.classID = e.classID
    LEFT JOIN
        Team t ON p.poolID = t.poolID
    LEFT JOIN
        TeamMember tm ON t.teamID = tm.teamID
    GROUP BY
        p.poolID, p.poolName, p.poolType, p.status
    ORDER BY
        [Active Enrollments] DESC; -- Added ORDER BY for clarity

    -- Subquery to retrieve the pool with the highest number of active enrollments
    SELECT TOP 1
        poolID AS [Top Pool ID],
        poolName AS [Top Pool Name],
        [Total Active Enrollments]
    FROM (
        SELECT TOP 1
            p.poolID,
            p.poolName,
            COUNT(DISTINCT e.enrollmentID) AS [Total Active Enrollments]
        FROM
            Pool p
        LEFT JOIN
            Class c ON p.poolID = c.poolID
        LEFT JOIN
            Enrollment e ON c.classID = e.classID
        WHERE
            e.status = 'Active'
        GROUP BY
            p.poolID, p.poolName
        ORDER BY
            [Total Active Enrollments] DESC
        ) AS TOP_POOL;

END;

-- Execute the PoolStatisticsReport stored procedure
EXEC PoolStatisticsReport;
