import json
import numpy as np
import os
import codecs
import csv

def extract_players():
    players = []
    files = []

    path = "C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\all"
    for file in os.listdir(path):
        if file.endswith(".json"):
            files.append(os.path.join(path, file))

    for file in files:
        with codecs.open(file,'r','utf-8') as f: 
            data = json.load(f)
            p = []

            for key, value in data['info']['players'].items():
                for x in value:
                    p.append(x)

            for key, value in data['info']['registry'].items():
                for x, y in value.items():
                    if x in p:
                        if (x, y) in players:
                            pass
                        else:
                            players.append((x, y))

    # write to csv file
    fields = ["Player Name", "ID"]
    filename = "psl_players.csv"

    with open(filename, 'w', newline = '') as csvfile:
        csvwriter = csv.writer(csvfile) 
            
        # writing the fields 
        csvwriter.writerow(fields)

        for x in players:
            csvwriter.writerow([x[0], x[1]])

def get_all_data(path):

    fields = ["Player Name", "ID"]
    players = {}

    with open('psl_all_players.csv', 'r') as file:
        reader = csv.reader(file)
        next(reader)
        for row in reader:
            players[row[0]] = [row[1]]

    files = []
    for file in os.listdir(path):
        if file.endswith(".json"):
            files.append(os.path.join(path, file))

    for file in files:
        with codecs.open(file,'r','utf-8') as f: 
            data = json.load(f)
                    
        year = data['info']['dates'][0][0:4] 
        if year not in fields:
            fields.append(year)
            for p in players.keys():
                players[p].append([year,"NA"])
                

        for key, value in data['info']['players'].items():
            for player in value:

                if player == "Imran Khan":
                    for x in range(len(players["Imran Khan (2)"])):
                        try:
                            if players["Imran Khan (2)"][x][0] == year:
                                players["Imran Khan (2)"][x][1] = key  
                        except:
                            pass

                elif player == "Mohammad Nawaz (3)":
                    for x in range(len(players["Mohammad Nawaz"])):
                        try:
                            if players["Mohammad Nawaz"][x][0] == year:
                                players["Mohammad Nawaz"][x][1] = key  
                        except:
                            pass

                elif player in players.keys():
                    for x in range(len(players[player])):
                        try:
                            if players[player][x][0] == year:
                                players[player][x][1] = key  
                        except:
                            pass

    # write to csv file
    filename = "psl_players_team_data.csv"

    with open(filename, 'w', newline = '') as csvfile:
        csvwriter = csv.writer(csvfile) 
            
        # writing the fields 
        csvwriter.writerow(fields)

        for key, value in players.items():
            csvwriter.writerow([key, value[0], value[1][1], value[2][1], value[3][1], value[4][1], value[5][1], value[6][1], value[7][1]])

# change path accordingly
get_all_data("C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\all")