from faker import Faker
import pyodbc as odbc
from faker.providers import BaseProvider
import random
from datetime import datetime, timedelta

#customized phone number
class USPhoneNumberProvider(BaseProvider):
    def us_phone_number(self):
        # Format: +1 (XXX) XXX-XXXX
        area_code = random.randint(200, 999)
        exchange_code = random.randint(200, 999)
        subscriber_number = random.randint(1000, 9999)
        return f"+1 ({area_code}) {exchange_code}-{subscriber_number}"

fake = Faker()
fake.add_provider(USPhoneNumberProvider)

def generate_trainers(n):
    trainers = []
    for _ in range(n):
        firstName = fake.first_name()
        lastName = fake.last_name()
        contactNo = fake.unique.us_phone_number()
        address = fake.address()
        email = f"{firstName.lower()}{lastName.lower()}{random.randint(1, 999)}@{random.choice(['gmail.com', 'yahoo.com', 'outlook.com'])}"
        
        dob_dt = fake.date_of_birth(minimum_age=26, maximum_age=59)  # Increase the minimum age
        dob = dob_dt.strftime('%Y-%m-%d')

        # Calculate a potential start date for hiring
        # potential_start_date = dob_dt + timedelta(days=9125)

        # # Ensure that the hiring date is between two years ago and today
        # if potential_start_date < datetime.now().date() - timedelta(days=730):
        #     start_date = datetime.now().date() - timedelta(days=730)

        # # hiringDate_dt = fake.date_between(start_date=start_date, end_date='today')
        # hiringDate_dt = fake.date_between(start_date='-2y', end_date='today')

        # hiringDate = hiringDate_dt.strftime('%Y-%m-%d')
        
        
        start_date=dob_dt + timedelta(days=9125)
        if start_date >=  (datetime.now() - timedelta(days=730)).date():
            hiringDate_dt = fake.date_between(start_date=dob_dt + timedelta(days=9125), end_date='today')
        else :
            hiringDate_dt = fake.date_between(start_date= (datetime.now() - timedelta(days=730)).date(), end_date='today')
        
        hiringDate = hiringDate_dt.strftime('%Y-%m-%d')

        certification = random.choice(['Swimming', 'Diving', 'Water Polo', 'Synchronized Swimming', 'Water Safety and life saving', 'Competitive Swim Coaching'])
        trainers.append([firstName, lastName, contactNo, address, email, dob , hiringDate, certification])
    return trainers

records = generate_trainers(30)

Driver = 'SQL SERVER'
Server = 'Zunaira'
Database = 'SCMS'

connection = f"Driver={{{Driver}}};Server={Server};Database={Database};Trusted_Connection=yes;"   #connection string


# insert = "INSERT INTO TRAINER (firstName, lastName, contactNo, address, dob, email, hiringDate, certification) VALUES (?,?,?,?,?,?,?,?)"

insert = """
INSERT INTO TRAINER (firstName, lastName, contactNo, address, email, DOB, hiringDate, certification) 
VALUES (?, ?, ?, ?, ?, CONVERT(DATE, ?, 120), CONVERT(DATE, ?, 120), ?)
"""

batch_size = 10
try:
    with odbc.connect(connection) as con:        #"with" closes the connection after insertion
        cursor = con.cursor()                    #"cursor" to execute sql commands
        for i in range(0, len(records), batch_size):
            batch_record = records[i:i + batch_size]      #1.records[0:100],2.records[100:200]....new list batch_record(subset of records)
            # for record in batch_record:
            #     print(record)
            cursor.executemany(insert, batch_record)
        con.commit()                              #saves the changes to the database
        print("Connection successful:", con)
except Exception as e:
    print("Error occurred:", e)
