#!/usr/bin/env python3

from time import sleep
import requests
import json

k = None
with open('config.json') as f:
    k = json.load(f)

url = f"https://discord.com/api/v10/applications/{k['appID']}/commands"

commands = [
    {"type":1,"options":[],"description":"Join a lobby","default_permission":True,"name":"join"},
    {"type":1,"options":[],"description":"Leave a lobby","default_permission":True,"name":"leave"},
    {"type":1,"options":[],"description":"View the current party","default_permission":True,"name":"party"},
    {"type":1,"options":[],"description":"Set up a game, making it ready to play","default_permission":True,"name":"setup"},
    {"type":1,"options":[],"description":"Un-set up a game, making it not ready to play, allowing people to leave","default_permission":True,"name":"unsetup"},
    {"type":1,"options":[],"description":"Start a game","default_permission":True,"name":"start"},
    {"type":1,"options":[],"description":"Lists all roles","default_permission":True,"name":"roles"},
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

for cmd in commands:
    resp = requests.post(url, headers=headers, json=cmd)
    print(resp)
    sleep(4.5)
