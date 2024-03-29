from faker import Faker
import pyodbc as odbc
from faker.providers import BaseProvider
import random
from datetime import datetime, timedelta

fake = Faker()

def fetch_memberIds(cursor):
    cursor.execute("SELECT memberID FROM ClubMember")
    return [row[0] for row in cursor.fetchall()]

def fetch_classIds(cursor):
    cursor.execute("SELECT classID FROM Class")
    return [row[0] for row in cursor.fetchall()]

def fetch_eventIds(cursor):
    cursor.execute("SELECT eventID FROM Event")
    return [row[0] for row in cursor.fetchall()]

def generate_payments(eventIds, memberIds, classIds):
    payments = []
    payment_methods = ['Credit Card', 'Cash', 'Online Transfer']
    payment_statuses = ['Completed', 'Pending', 'Failed']

    # Generate membership fee dates for each member
    membership_payment_dates = {}
    for memberId in memberIds:
        membership_payment_date = datetime.now() - timedelta(days=random.randint(365, 365 * 2))
        membership_payment_dates[memberId] = membership_payment_date

        # Membership Fee
        paymentMethod = random.choice(payment_methods)
        paymentStatus = random.choice(payment_statuses)
        payments.append([memberId, membership_payment_date.strftime('%Y-%m-%d'), 5000, paymentMethod, paymentStatus, 'Membership Fee', None, None])

    # Event and Class Fees
    for memberId in memberIds:
        # Use the membership fee date as a reference
        reference_date = membership_payment_dates[memberId]

        # Event Fees
        for eventId in eventIds:
            event_payment_date = reference_date + timedelta(days=random.randint(1, 30))
            paymentMethod = random.choice(payment_methods)
            paymentStatus = random.choice(payment_statuses)
            payments.append([memberId, event_payment_date.strftime('%Y-%m-%d'), 1000, paymentMethod, paymentStatus, 'Event Fee', None, eventId])
    
        # Class Fees (Random 1-6 classes per member)
        selectedClasses = random.sample(classIds, random.randint(1, 6))
        for classId in selectedClasses:
            class_payment_date = reference_date + timedelta(days=random.randint(1, 30))
            paymentMethod = random.choice(payment_methods)
            paymentStatus = random.choice(payment_statuses)
            payments.append([memberId, class_payment_date.strftime('%Y-%m-%d'), 2000, paymentMethod, paymentStatus, 'Class Fee', classId, None])

    return payments

Driver = 'SQL SERVER'
Server = 'Zunaira'
Database = 'SCMS'

connection = f"Driver={{{Driver}}};Server={Server};Database={Database};Trusted_Connection=yes;"   #connection string

insert = """
INSERT INTO PAYMENT (memberID, paymentDate, amount, paymentMethod, paymentStatus, paymentType, classID, eventID) 
VALUES (?, ?, ?, ?, ?, ?, ?, ?)
"""

batch_size = 10

try:
    with odbc.connect(connection) as con:        #"with" closes the connection after insertion
        cursor = con.cursor()
        memberIds = fetch_memberIds(cursor)
        classIds = fetch_classIds(cursor)
        eventIds = fetch_eventIds(cursor)
        records = generate_payments(eventIds, memberIds, classIds) #1,680,000
        for i in range(0, len(records), batch_size):
            batch_record = records[i:i + batch_size]      #1.records[0:100],2.records[100:200]....new list batch_record(subset of records)
            # for record in batch_record:
            #     print(record)
            cursor.executemany(insert, batch_record)
        con.commit()                              #saves the changes to the database
        print("Connection successful:", con)
except Exception as e:
    print("Error occurred:", e)
