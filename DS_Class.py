from faker import Faker
import pyodbc as odbc
from faker.providers import BaseProvider
import random
from datetime import datetime, timedelta

fake = Faker()

def generate_classes(n, poolDetails, trainerCertifications):
    classes = []
    for _ in range(n):
        className = random.choice(['Swimming Classes', 'Diving', 'Water Polo', 'Synchronized Swimming', 'Water Safety and life saving', 'Competitive Swim'])
        class_day_map = {
            'Swimming Classes': 'Monday',
            'Diving': 'Tuesday',
            'Water Polo': 'Wednesday',
            'Synchronized Swimming': 'Thursday',
            'Water Safety and life saving': 'Friday',
            'Competitive Swim': 'Saturday',
            'Practice': 'Sunday'  # Sunday is reserved for practice
        }
        dayOfWeek = class_day_map[className] if className in class_day_map else class_day_map['Practice']        

         # Map class names to certifications
        certificationMapping = {
            'Swimming Classes': 'Swimming',
            'Diving': 'Diving',
            'Water Polo': 'Water Polo',
            'Synchronized Swimming':  ['Leisure', 'Wave', 'Therapy'],
            'Water Safety and life saving': 'Water Safety and life saving',
            'Competitive Swim': 'Competitive Swim Coaching'
        }

        poolTypeMapping = {
            'Swimming Classes': ['Indoor', 'Outdoor', 'Lap'],
            'Diving': ['Diving'],
            'Water Polo': ['Indoor', 'Outdoor'],
            'Synchronized Swimming': 'Synchronized Swimming',
            'Water Safety and life saving': 'Outdoor',
            'Competitive Swim': 'Lap'
        }

        # Generate start time between 9 AM and 5 PM, at minute 00
        start_hour = random.randint(9, 16)  # 16 because the class ends at 17 (5 PM)
        startTime_dt = datetime.now().replace(hour=start_hour, minute=0, second=0, microsecond=0)
        startTime = startTime_dt.strftime('%H:%M:%S')
        # End time is one hour after start time
        endTime_dt = startTime_dt + timedelta(hours=1)
        endTime = endTime_dt.strftime('%H:%M:%S')

        skillLevel = random.choice(['Beginner', 'Intermediate', 'Advanced'])
        ageGroup = random.choice(['Teens', 'Adults', 'All Ages'])
        # Class descriptions based on className
        if className == 'Swimming Classes':
            classDescription = random.choice(['Aqua Beginners: Splash & Learn', 'Freestyle Fundamentals', 'Backstroke Basics', 'Breaststroke for Beginners', 'Adult Swim: Fitness & Technique'])
        elif className == 'Diving':
            classDescription = random.choice(['Springboard Diving: First Dive', 'High Dive Heroes', 'Platform Diving Techniques', 'Youth Diving Discovery', 'Dive into Fitness', 'Competitive Diving Prep'])
        elif className == 'Water Polo':
            classDescription = random.choice(['Water Polo 101: Basics', 'Advanced Water Polo Tactics', 'Youth Water Polo Camp', 'Intro to Goalkeeping', 'Water Polo for Fitness', 'Masters Water Polo'])
        elif className == 'Synchronized Swimming':
            classDescription = random.choice(['Synchronized Swimming Intro', 'Artistic Swimming Advanced', 'Synchrony in Water', 'Rhythmic Water Dance', 'Choreography and Grace', 'Team Sync Performance'])
        elif className == 'Water Safety and Life Saving':
            classDescription = random.choice(['Lifesaving Skills 101', 'Junior Lifeguard Program', 'Water Safety for Kids', 'Advanced Rescue Techniques', 'First Aid and CPR by the Pool', 'Emergency Response in Water'])
        elif className == 'Competitive Swim Coaching':
            classDescription = random.choice(['Speed Swim: Competitive Edge', 'Race Ready: Swim Coaching', 'Championship Swim Training', 'Elite Swimmer\'s Workshop', 'Youth Competitive Swim', 'Masters Swim Coaching'])
        else:
            classDescription = 'General Aquatic Class'

        # Filter pools by type matching the class
        eligiblePoolIds = [poolId for poolId, poolType in poolDetails.items() if poolType in poolTypeMapping.get(className, [])]
        if eligiblePoolIds:
            poolID = random.choice(eligiblePoolIds)
        else:
            continue  # Skip class generation if no eligible pool found

        # Filter trainers by certification matching the class
        eligibleTrainerIds = [trainerId for trainerId, certification in trainerCertifications.items() if certification == certificationMapping.get(className, "")]
        if eligibleTrainerIds:
            trainerId = random.choice(eligibleTrainerIds)
        else:
            continue  

        classes.append([poolID, trainerId, className, dayOfWeek, startTime, endTime, skillLevel, ageGroup, classDescription])
    return classes

def fetch_pool_details(cursor):
    cursor.execute("SELECT poolID, poolType FROM Pool")
    return {row[0]: row[1] for row in cursor.fetchall()}

def fetch_trainer_certifications(cursor):
    cursor.execute("SELECT trainerID, certification FROM Trainer")
    return {row[0]: row[1] for row in cursor.fetchall()}

Driver = 'SQL SERVER'
Server = 'Zunaira'
Database = 'SCMS'

connection = f"Driver={{{Driver}}};Server={Server};Database={Database};Trusted_Connection=yes;"   #connection string

insert = "INSERT INTO CLASS (poolID, trainerId, className, dayOfWeek, startTime, endTime, skillLevel, ageGroup, classDescription) VALUES (?,?,?,?,?,?,?,?,?)"

batch_size = 400

try:
    with odbc.connect(connection) as con:        #"with" closes the connection after insertion
        cursor = con.cursor()                    #"cursor" to execute sql commands
        poolDetails = fetch_pool_details(cursor)
        trainerCertifications = fetch_trainer_certifications(cursor)
        records = generate_classes(2400, poolDetails, trainerCertifications)
        for i in range(0, len(records), batch_size):
            batch_record = records[i:i + batch_size]      #1.records[0:100],2.records[100:200]....new list batch_record(subset of records)
            # for record in batch_record:
            #     print(record)
            cursor.executemany(insert, batch_record)
        con.commit()                              #saves the changes to the database
        print("Connection successful:", con)
except Exception as e:
    print("Error occurred:", {e})
