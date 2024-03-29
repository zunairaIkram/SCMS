from faker import Faker
import pyodbc as odbc
import random

fake = Faker()

def fetch_eventIds(cursor):
    cursor.execute("SELECT eventID FROM Event")
    return [row[0] for row in cursor.fetchall()]

def fetch_teamIds(cursor):
    cursor.execute("SELECT teamID FROM Team")
    return [row[0] for row in cursor.fetchall()]

def generate_event_teams(n, eventIds, teamIds):
    event_teams = []
    used_pairs = set()  # Keep track of used eventID-teamID pairs
    record_count = 0

    for eventID in eventIds:
        # Select a random number of unique teams (between 7 to 20) for each event
        participating_teams = random.sample(teamIds, random.randint(7, 20))
        for teamID in participating_teams:
            if record_count >= n:
                break  # Stop generating more records once the limit is reached
            if (eventID, teamID) not in used_pairs:
                used_pairs.add((eventID, teamID))
                event_teams.append([eventID, teamID])
                record_count += 1

    return event_teams

Driver = 'SQL SERVER'
Server = 'Zunaira'
Database = 'SCMS'

connection = f"Driver={{{Driver}}};Server={Server};Database={Database};Trusted_Connection=yes;"

insert = "INSERT INTO EventTeam (eventID, teamID) VALUES (?, ?)"

batch_size = 100

try:
    with odbc.connect(connection) as con:        #"with" closes the connection after insertion
        cursor = con.cursor()    
        eventIds = fetch_eventIds(cursor)
        teamIds = fetch_teamIds(cursor)                #"cursor" to execute sql commands
        records = generate_event_teams(480, eventIds, teamIds)
        for i in range(0, len(records), batch_size):
            batch_record = records[i:i + batch_size]      #1.records[0:100],2.records[100:200]....new list batch_record(subset of records)
            # for record in batch_record:
            #     print(record)
            cursor.executemany(insert, batch_record)
        con.commit()                              #saves the changes to the database
        print("Connection successful:", con)
except Exception as e:
    print("Error occurred:", e)
