import mysql.connector #To connect to mysql server
import json #To parse json files
import os #Need this to traverse file system
import time #Track duration of program
from dateutil import parser #Because built in string to ISO parser cant detect the time without colons

playerPreviousGP = {} #Dictionary to store the entire parsed json of the previous folder to be used to check if any games played

#Connect to the server
db = mysql.connector.connect(
  host="localhost",
  user="root",
  passwd="Insert your password here",
  database="tl_delta_db",
  auth_plugin="mysql_native_password"
)

#Starts a db cursor https://www.tutorialspoint.com/What-is-MySQL-Cursor-What-are-its-main-properties#:~:text=MySQL%20cursor%20is%20a%20kind,from%20version%205%20or%20greater.
myCursor = db.cursor()

#Prepare dictionary of coefficients for all the regression models
regressionDict = {}
myCursor.execute("SELECT * FROM tl_time_series_regression")
while True:
  try:
    data = myCursor.fetchone()
    regressionDict[data[0].strftime("%Y-%m-%d %H:%M:%S")]=data[1:]
  except:
    print(len(regressionDict))
    break

#For sake of readability
def strTime(a):
  return parser.parse(i).strftime("%Y-%m-%d %H:%M:%S")

#LOBF = Line of best fit
def LOBF(i,k):
  return (regressionDict[strTime(i)][0]
  + regressionDict[strTime(i)][1] * k["league"]['glicko']
  + regressionDict[strTime(i)][2] * k["league"]['glicko']**2
  + regressionDict[strTime(i)][3] * k["league"]['glicko']**3)


#Loop through entire file system
directory = "D:\\tetrio-stats" #Change to your local case

def savePlayer(i, k):
  #Saves into tl_delta_table TABLE
  currentData = [] #Initialize current data that goes away after function successfully called (scoping)
  #Code for saving APM
  if k['league']['apm'] is None:
    currentData.append(0)
  else:
    currentData.append(k["league"]["apm"])
  #Code for saving PPS
  if k['league']['pps'] is None or k['league']['pps'] == 0:
    currentData.append(-2)
  else:
    currentData.append(k["league"]["pps"])
  #Code for saving VS SCORE, RAW EFF AND ADJ EFF
  try:
    currentData.append(k["league"]["vs"])
    if k['league']['vs'] is None:
      currentData.append(None)
      currentData.append(None)
    else:
      currentData.append(k['league']['vs']/k['league']['pps'])
      currentData.append(((2/3)*(k['league']['vs']/currentData[1]))+((1/3)*(k['league']['vs']/currentData[1])*(currentData[1]/LOBF(i,k))))
  except KeyError:
    currentData.append(None)
    currentData.append(None)
    currentData.append(None)
    pass
  #Code for RAW APP
  currentData.append(currentData[0]/(60*currentData[1])) #actually is k["league"]["pps"] and k["league"]["apm"] but because cannot do operations on none so I have to use current Data
  #Code for ADJ APP
  currentData.append(((2/3)*(currentData[0]/(60*currentData[1])))+((1/3)*(currentData[0]/(60*currentData[1]))*(currentData[1]/LOBF(i,k)))/60)
  currentData.append(k["_id"])
  currentData.append(k["username"])
  try:  #Verified status wasnt always there
    currentData.append(k["verified"])
  except KeyError:
    currentData.append(None)
    pass
  currentData.append(k["league"]["rating"])
  currentData.append(k["league"]["rank"])
  currentData.append(k["league"]["glicko"])
  currentData.append(k["league"]["rd"])
  currentData.append(k["league"]["gamesplayed"])
  currentData.append(k["league"]["gameswon"])
  currentData.append(parser.parse(i))
  sql = "INSERT INTO tl_delta_table (apm, pps, vs, raw_eff, adjusted_eff, app, adjusted_app, id, username, verified, tr, tl_rank, glicko, rd, games_played, games_won, delta_date) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
  val = (currentData[0],currentData[1],currentData[2],currentData[3],currentData[4],currentData[5],currentData[6],currentData[7],currentData[8],currentData[9], currentData[10], currentData[11], currentData[12], currentData[13], currentData[14], currentData[15], currentData[16])
  try:
    myCursor.execute(sql,val)
  except Exception as e:
    print(e)
    print(i)
    print(k["username"])
    print(len(k["username"]))

startTime = time.time()

for i in os.listdir(directory): #For every folder in D:\tetrio-stats
  try:
    innerDirectory = os.path.join(directory, i) #f = D:\tetrio-stat\<foldername>
    if os.stat(os.path.join(directory, i, "league.json")).st_size > 2000:
      #Opens the file that want data from
      file = open(os.path.join(directory, i, "league.json"))
      data = json.load(file)
      #Resets current data
      for k in data['users']: #For every player in TL
        #Check for change in GP
        if not (k["_id"] in playerPreviousGP):
          savePlayer(i,k)
          playerPreviousGP[k["_id"]] = k["league"]["gamesplayed"]
          # print("New insert")
        elif playerPreviousGP[k["_id"]] == k["league"]["gamesplayed"]:
          # print("No change in GP")
          continue
        else:
          savePlayer(i,k)
          playerPreviousGP[k["_id"]] = k["league"]["gamesplayed"]
          # print("Updating previous")
      #PRINTS NEXT LINE
      db.commit()
      print(i + " completed")
    else:
      print("File size under 2000 bytes, indicates broken jsonL format which cannot be read easily")
  except FileNotFoundError:
    print("File not found")
  except ValueError as e:
    print("Errorss: "+e)

print(time.time() - startTime) #Just to show how long the whole process took. It took slightly over 2 hours for me.
print("seconds")

# Closing file
file.close()


