#!/bin/python3
import serial, os
import numpy as np
import sys
from datetime import date
import json
import requests
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import GaussianNB
from sklearn.neighbors import KNeighborsClassifier
import numpy as np

serverIP = "http://172.21.121.13:8080/"

def getShakiness(data: list):
    total = 0
    for i in range(1, len(data)):
        total += abs(data[i] - data[i - 1])
    return total

ldata = pd.read_csv("training.csv")

from sklearn import preprocessing
le = preprocessing.LabelEncoder()

labels = le.fit_transform(ldata["concern"])
#labels = np.array(data["concern"])
#print(labels)
#lr = GaussianNB()
#lr = KNeighborsClassifier()

lr = LogisticRegression()

features = np.array(ldata["shak"]).reshape(1, -1).transpose()
lr.fit(features, labels)

def getConcern(shakiness: int):
    rawConcern = lr.predict([[shakiness]])
    #Looks like this weirdly sometimes returns an int and sometimes a one-element list so cheat a little bit
    if type(rawConcern) == int:
        concern = rawConcern
    else:
        concern = rawConcern[0]
    #Remove glitchy 0 results
    if concern == 0:
        concern = 1
    print(concern)
    #Convert to an int just in case!
    return int(concern)



userId = 0

fileSuffix = "_tremor_data.csv"

#Find open ttyACM port with trinkey connected
serStream = os.popen("ls /dev/ttyACM*")
serialFile = serStream.read().strip()
if serialFile == "":
    print("No serial in found")
    exit()

day = 1

data = []
failed = False
ser = serial.Serial(serialFile)
while True:
    val = ser.readline().strip()
    val = val.decode("utf-8")
    #when we get the begin token
    if val == 'b':
        failed = False
        data = []
        val = ser.readline().strip()
        val = val.decode("utf-8")
        #keep going until we get the end token
        while val != "e":
            #f is for failure! They took their finger away so handle it appropriately
            if val == "f":
                failed = True
                break
            data.append(int(val))
            val = ser.readline().strip()
            val = val.decode("utf-8")
    if data != [] and not failed:
        shakiness = getShakiness(data)
        concern = getConcern(shakiness)
        stddev = np.std(data)
        requestData = {"uid": userId, "shakiness": shakiness, "concern": concern, "stddev": stddev, "day": day, "month":7, "year":22}
        print(requestData)
        day += 1
        if day > 31:
            day = 0
            month += 1
        requestJson = json.dumps(requestData)

        try:
            req = requests.post(serverIP, data = requestJson)
            print(req)
            print(req.text)
        except:
            print("Request failed!")

        # with open(str(userId) + fileSuffix + ".stat", "r+") as statusFile:
        #     sText = statusFile.read().strip()
        #     #print(sText)
        #     if sText in ["0","1"]:
        #         with open(str(userId) + fileSuffix, "r+") as dataFile:
        #             text = dataFile.read()
        #             #print(text)
        #             dataFile.write(",".join([date.today().strftime("%d/%m/%Y"), str(dev), str(getConcern(dev))]))
        #             dataFile.write("\n")
        #         statusFile.seek(0)
        #         statusFile.write("1")
    if failed:
        print("Failure")

