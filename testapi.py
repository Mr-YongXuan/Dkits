from flask import Flask,request

app = Flask(__name__)

@app.route('/DataPort1', methods=['POST'])
def recvData():
    data = request.form.get('data')
    print(data)
    return '{1,2,3}'

app.run('127.0.0.1', 80, debug=True)