import json
import numpy as np
import os
import codecs
import csv

players = {}
files = []

path = "C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\batting"
for file in os.listdir(path):
    if file.endswith(".csv"):
        files.append(os.path.join(path, file))

for file in files:
        with codecs.open(file,'r','utf-8') as f: 
            reader = csv.reader(f)
            next(reader)
            for row in reader:
                if row[0] in players.keys():

                    if row[4] == '':
                        row[4] = 0
                    if row[3] == '':
                        row[3] = 0
                    
                    players[row[0]][0] += int(row[3])
                    players[row[0]][1] += int(row[4])
                else:
                    if row[4] == '':
                        row[4] = 0
                    if row[3] == '':
                        row[3] = 0

                    players[row[0]] = [int(row[3]), int(row[4])]

# write to csv
filename = "psl_batting_performance_data.csv"
fields = ["Player", "Matches Played", "Runs"]

with open(filename, 'w', newline = '') as csvfile:
    csvwriter = csv.writer(csvfile) 
        
    # writing the fields 
    csvwriter.writerow(fields)

    for key, value in players.items():
        csvwriter.writerow([key, value[0], value[1]])
