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

def generate_club_members(n):              #generate a list of clubMembers
    members = []
    for _ in range(n):
        firstName = fake.first_name()
        lastName = fake.last_name()
        #customized mobile number
        contactNo = (fake.unique.us_phone_number())  # Generates US phone numbers in the specified format
        address = fake.address()
        email = f"{firstName.lower()}{lastName.lower()}{random.randint(1, 999)}@{random.choice(['gmail.com', 'yahoo.com', 'outlook.com'])}"
       
        max_age = timedelta(days=18*365)  # 18 years
        min_age = timedelta(days=35*365)  # 35 years
        dob_dt = datetime.now() - random.uniform(min_age, max_age)
        dob = dob_dt.strftime('%Y-%m-%d')

        membershipType = random.choice(['Lifetime', 'Guest', 'Student', 'Individual', 'Competitive'])
        status = random.choice(['Active', 'Inactive'])
        members.append([firstName, lastName, contactNo, address, email, dob, membershipType, status])
    return members

records = generate_club_members(500)

Driver = 'SQL SERVER'
Server = 'Zunaira'
Database = 'SCMS'

connection = f"Driver={{{Driver}}};Server={Server};Database={Database};Trusted_Connection=yes;"   #connection string

insert = "INSERT INTO ClubMember (firstName, lastName, contactNo, address, email, dob, membershipType, status) VALUES (?,?,?,?,?,?,?,?)"

batch_size = 200
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
