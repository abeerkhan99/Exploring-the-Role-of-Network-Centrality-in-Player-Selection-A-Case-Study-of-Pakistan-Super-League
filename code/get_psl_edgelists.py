import json
import numpy as np
import os
import codecs
import csv

def get_psl_players(filename):

    players = {}
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        next(reader)
        for row in reader:
            players[row[0]] = 0

    return players

def get_edge_list(players, path):

    edge_list = {}
    files = []
    for file in os.listdir(path):
        if file.endswith(".json"):
            files.append(os.path.join(path, file))

    for file in files:
        with codecs.open(file,'r','utf-8') as f: 
            data = json.load(f)

            partnership = []

            for key, value in data['info']['players'].items():
                for x in value:
                    if x == "Imran Khan":
                        players["Imran Khan (2)"] = players["Imran Khan (2)"] + 1

                    elif x == "Mohammad Nawaz (3)":
                        players["Mohammad Nawaz"] = players["Mohammad Nawaz"] + 1

                    elif x in players.keys():
                        players[x] = players[x] + 1

            for over in range(len(data['innings'][0]['overs'])):
                for i in data['innings'][0]['overs'][over]['deliveries']:

                    if (i['batter'] == "Imran Khan") and (i['bowler'] in players.keys()):
                        partnership.append(["Imran Khan (2)", i['bowler']])

                    elif (i['batter'] in players.keys()) and (i['bowler'] == "Imran Khan"):
                        partnership.append([i['batter'], "Imran Khan (2)"])

                    elif (i['batter'] == "Mohammad Nawaz (3)") and (i['batter'] in players.keys()):
                        partnership.append(["Mohammad Nawaz", i['bowler']])

                    elif (i['batter'] in players.keys()) and (i['bowler'] == "Mohammad Nawaz (3)"):
                        partnership.append([i['batter'], "Mohammad Nawaz"])

                    elif (i['batter'] in players.keys()) and (i['bowler'] in players.keys()):
                        partnership.append([i['batter'], i['bowler']])
                    
            partnership = np.unique(np.array(partnership), axis=0)

            for x in partnership:
                if (x[0], x[1]) in edge_list.keys():
                    edge_list[(x[0], x[1])] = edge_list[(x[0], x[1])] + 1 
                    if (x[1], x[0]) in edge_list.keys():
                        edge_list[(x[1], x[0])] = edge_list[(x[0], x[1])] + 1 
                else:
                    edge_list[(x[0], x[1])] = 1
                    edge_list[(x[1], x[0])] = 1

    for key, value in edge_list.items():
        for keys in players.keys():
            if key[0] == keys:
                edge_list[key] = edge_list[key] / players[keys]

    return edge_list


def make_csv(fields, filename, edge_list):

    with open(filename, 'w', newline = '') as csvfile:
        csvwriter = csv.writer(csvfile) 
            
        # writing the fields 
        csvwriter.writerow(fields)

        for key, value in edge_list.items():
            csvwriter.writerow([key[0], key[1], value])

    return None
     
fields = ["Player1", "Player2", "Matches"]
filename = "psl2022_edgelist.csv"
players = get_psl_players('psl_players_team_data.csv')

# change paths accordingly
paths = ["C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\all", "C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\2016", "C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\2017", "C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\2018", "C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\2019", "C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\2020", "C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\2021", "C:\\Users\\Abby\\Desktop\\Semester 7\\SNA\\Cricket\\2022"]
edge_list = get_edge_list(players, paths[7])
make_csv(fields, filename, edge_list)
# print(players)