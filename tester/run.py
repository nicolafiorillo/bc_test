# Usage:
#   python3 run.py

import http.client
import re
import json

a_command_re = r'A(\d+)'
c_command_re = r'C'
cs_command_re = r'CS'

checksums = ""

connection = http.client.HTTPConnection('localhost', 4000)

def log(s):
    #print(s)
    return

def call_a(number):
    log("Command A with {}".format(number))
    connection.request("POST", '/add', json.dumps({'n': number}), {'Content-type': 'application/json'})
    data = connection.getresponse().read().decode()
    assert(data.strip('"') == 'ok')

def call_cs(checksums):
    log("Command CS")
    connection.request("GET", "/checksum")
    data = connection.getresponse().read().decode()
    log("Checksum: {}".format(data))
    return checksums + str(data)

def call_c():
    log("Command C")
    connection.request("POST", "/clear")
    data = connection.getresponse().read().decode()
    assert(data.strip('"') == "ok")

with open("input.txt", "r") as commands:
    for command in commands:
        command = command.strip()
        
        if re.search(a_command_re, command):
            match = re.search(a_command_re, command)
            call_a(match.group(1))
        elif re.search(cs_command_re, command):
            checksums = call_cs(checksums)
        elif re.search(c_command_re, command):
            call_c()
        else:
            log("Unknown command: {}".format(command))
    
    commands.close()

print("Final checksum: {}".format(checksums))
