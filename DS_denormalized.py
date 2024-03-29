import pyodbc
from faker import Faker
from datetime import datetime, timedelta

Driver = 'SQL SERVER'
Server = 'Zunaira'
Database = 'SCMS'

conn_str = f"Driver={{{Driver}}};Server={Server};Database={Database};Trusted_Connection=yes;"   #connection string
# conn_str = f'DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}'

connection = pyodbc.connect(conn_str)

# Create a cursor from the connection
cursor = connection.cursor()

# Faker instance for generating fake data
fake = Faker()

# Execute a SELECT query with JOINs
query = """
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
"""

cursor.execute(query)

# Fetch all rows from the result set
result_data = cursor.fetchall()

# Store data in a variable
result_set = []
for row in result_data:
    result = {
        'paymentID': row.paymentID,
        'memberID': row.memberID,
        'memberFirstName': row.memberFirstName,
        'memberLastName': row.memberLastName,
        'membershipType': row.membershipType,
        'memberStatus': row.memberStatus,
        'classID': row.classID,
        'className': row.className,
        'classDayOfWeek': row.classDayOfWeek,
        'classStartTime': row.classStartTime,
        'classEndTime': row.classEndTime,
        'classSkillLevel': row.classSkillLevel,
        'classAgeGroup': row.classAgeGroup,
        'classDescription': row.classDescription,
        'eventID': row.eventID,
        'eventName': row.eventName,
        'eventLocation': row.eventLocation,
        'eventDate': row.eventDate,
        'eventType': row.eventType,
        'paymentDate': row.paymentDate,
        'amount': row.amount,
        'paymentMethod': row.paymentMethod,
        'paymentStatus': row.paymentStatus,
        'paymentType': row.paymentType,
    }
    result_set.append(result)

# Insert data from the result_set into the DenormalizedPayments table
for record in result_set:
    insert_query = """
        INSERT INTO DenormalizedPayments (
            paymentID, memberID, memberFirstName, memberLastName, membershipType, memberStatus,
            classID, className, classDayOfWeek, classStartTime, classEndTime,
            classSkillLevel, classAgeGroup, classDescription,
            eventID, eventName, eventLocation, eventDate, eventType,
            paymentDate, amount, paymentMethod, paymentStatus, paymentType
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """

    cursor.execute(insert_query, (
        record['paymentID'], record['memberID'], record['memberFirstName'], record['memberLastName'],
        record['membershipType'], record['memberStatus'], record['classID'], record['className'],
        record['classDayOfWeek'], record['classStartTime'], record['classEndTime'],
        record['classSkillLevel'], record['classAgeGroup'], record['classDescription'],
        record['eventID'], record['eventName'], record['eventLocation'], record['eventDate'],
        record['eventType'], record['paymentDate'], record['amount'],
        record['paymentMethod'], record['paymentStatus'], record['paymentType']
    ))

# Commit the transaction
connection.commit()

print("Data inserted successfully!")

# Close the cursor and connection
cursor.close()
connection.close()
