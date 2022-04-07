import os
import json
import sys

directory = "D:\\tetrio-stats" #Change according to your local case
problemDirectories = []


#Deletes any folder with no league data (e.g. 2020-04-18T143001). 2nd case
for i in os.listdir(directory):
    innerDirectory = os.path.join(directory, i)
    if len(os.listdir(innerDirectory)) == 0:
        os.rmdir(innerDirectory)
        print("Folder "+innerDirectory+" deleted because it is empty. Case 2")
    else:
        continue
print("Part 1 done")

# Deletes any folder with empty league data (e.g. 2020-07-30T120003). 3rd case
for i in os.listdir(directory):
    innerDirectory = os.path.join(directory, i)
    if os.stat(os.path.join(innerDirectory, "league.json")).st_size == 0:
        # for j in os.listdir(innerDirectory):
        #     os.remove("league.json")
        #     print(j+" league.json deleted successfully")
        # os.rmdir(innerDirectory)
        print("Folder "+innerDirectory+" has an empty league file and hence is deleted. Case 3")
    else:
        continue
print("Part 2 done")

#Checks for any folder with success = false (e.g. 2020-04-18T144001) and any folder with incomplete JSON data (e.g. 2021-11-06T070001). 4th and 5th case.
for i in os.listdir(directory):
    try:
        innerDirectory = os.path.join(directory, i)
        file = open(os.path.join(innerDirectory, "league.json"))
        data = json.load(file)
        if data["success"] is False:
            problemDirectories.append(innerDirectory + ", case 4")
        else:
            continue
    except Exception as e:
        print(e)
        print("Case 5 detected at "+i)
        problemDirectories.append(innerDirectory + ", case 5")
print("Part 3 done")


print(problemDirectories)




