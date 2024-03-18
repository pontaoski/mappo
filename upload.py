#!/usr/bin/env python3

from time import sleep
import requests
import json

k = None
with open('config.json') as f:
    k = json.load(f)

url = f"https://discord.com/api/v10/applications/{k['appID']}/commands"

commands = [
    {"type":1, "options":[{
        "name": "language",
        "description": "The game language",
        "required": True,
        "type": 3,
        "choices": [
            { "name": "Toki Pona", "value": "toki_pona" },
            { "name": "English", "value": "english" },
        ],
    },{
        "name": "speed",
        "description": "The game speed",
        "required": False,
        "type": 3,
        "choices": [
            { "name": "Fast", "value": "fast" },
            { "name": "Normal", "value": "normal" },
            { "name": "Manual", "value": "manual" },
        ],
    }],"description":"Creates a new game","default_permission":True,"name":"create"},
    {"type":1,"options":[],"description":"Join a lobby","default_permission":True,"name":"join"},
    {"type":1,"options":[],"description":"Leave a lobby","default_permission":True,"name":"leave"},
    {"type":1,"options":[],"description":"View the current party","default_permission":True,"name":"party"},
    {"type":1,"options":[],"description":"Lists all roles","default_permission":True,"name":"roles"},
    {"type":1,"options":[],"description":"Instantly completes the current wait","default_permission":True,"name":"continue"},
    {"type":1,"options":[{
        "name": "role",
        "description": "The role whose information to get",
        "required": True,
        "type": 3,
    }],"description":"Gets information about a role","default_permission":True,"name":"role"},
    {"type":1,"options":[{
        "name": "user",
        "description": "The user to remove from the party",
        "required": True,
        "type": 6,
    }],"description":"Removes a user from the party","default_permission":True,"name":"remove"},
    {"type":1,"options":[{
        "name": "user",
        "description": "The user to promote to party leader",
        "required": True,
        "type": 6,
    }],"description":"Promotes a user to party leader","default_permission":True,"name":"promote"},
]

headers = {
    "Authorization": f"Bot {k['token']}",
}

resp = requests.put(url, headers=headers, json=commands)
print(resp)
sleep(4.5)

for cmd in ["1013538476844658799", "1013538497132498945", "1013538517881720832"]:
    resp = requests.delete(url + "/" + cmd, headers=headers)
    print(resp)
    sleep(4.5)
