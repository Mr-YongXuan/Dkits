from flask import Flask,request

app = Flask(__name__)

commands = ["1", "2", "3", "4", "5", "6", "7"]

@app.route('/DataPort1', methods=['POST'])
def recvData():
    data = request.form.get('data')
    print(data)
    return '{1,2,3}'

@app.route('/dcs', methods=['POST'])
def dcs():
    if commands:
        print(commands)
        return commands.pop()
    return ''

app.run('127.0.0.1', 80, debug=True)