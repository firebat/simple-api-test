from flask import Flask, request, jsonify, redirect

app = Flask(__name__)

@app.route('/check.jsp')
def check():
    return 'It works'

@app.route('/test/get.json', methods=['GET'])
def get():
    return 'get, ' + request.args['name']

@app.route('/test/post.json', methods=['POST'])
def post_data():
    return 'post, ' + request.form['name']


@app.route('/test/requestbody.json', methods=['POST'])
def requestbody():
    user = request.get_json()
    return jsonify(user)

@app.route('/test/redirect.json')
def _redirect():
    return redirect("http://www.example.com", code=302)

@app.route('/test/file.json', methods=['POST'])
def upload():
    file = request.files['file']
    file.save('./tmp')

    return './tmp'

if __name__ == '__main__':
    app.run(debug=True, port=8080)
