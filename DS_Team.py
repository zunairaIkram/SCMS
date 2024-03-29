from faker import Faker
import pyodbc as odbc
from faker.providers import BaseProvider
import random


fake = Faker()

def generate_teams(n):
    teams = []
    teamNameOptions = [
        'Aqua Racers', 'Wave Warriors', 'Speedy Sharks', 'Dolphin Divers', 
        'Blue Wave Barracudas', 'Rapid Raptors', 'Coral Sprinters', 
        'Marine Marlins', 'Tidal Titans', 'Streamline Stingrays', 
        'Oceanic Orcas', 'Ripple Rebels', 'Hydro Hurdles', 
        'Lagoon Legends', 'Seabreeze Sprinters', 'Bursting Barrage', 
        'Mighty Mantas', 'Gliding Guppies', 'Surge Swimmers', 
        'Cascade Champions', 'Tidal Wave Titans', 'Oceanic Eagles', 'Sea Serpent Squad'
    ]
    
    random.shuffle(teamNameOptions)

    # Limit the number of teams to the size of unique names
    n = min(n, len(teamNameOptions))
        
    for i in range(n):
        teamName = teamNameOptions[i]
        ageGroups = random.choice(['Teens', 'Adults', 'All Ages'])
        teams.append([teamName, ageGroups])
    return teams

records = generate_teams(20)


Driver = 'SQL SERVER'
Server = 'Zunaira'
Database = 'SCMS'

connection = f"Driver={{{Driver}}};Server={Server};Database={Database};Trusted_Connection=yes;"   #connection string

insert = "INSERT INTO TEAM (teamName, ageGroups) VALUES (?,?)"

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
