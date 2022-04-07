import requests
import json
res = requests.get('https://ch.tetr.io/api/users/lists/league/all').json()
with open('league.json', 'w') as json_file:
    json.dump(res, json_file)
