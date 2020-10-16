import convert
import flask
from flask import request, jsonify

app = flask.Flask(__name__)
app.config["DEBUG"] = True

# Create some test data for our catalog in the form of a list of dictionaries.

@app.route('/', methods=['GET'])
def home():
    return '''<h1>I heard you like jokes</h1>
<p>That's why I have prepared 100 jokes form bash.org.pl so you can enjoy your time</p>'''


@app.route('/api/v1/resources/jokes/all', methods=['GET'])
def api_all():
    results = convert.get_jokes()
    return jsonify(results)

app.run(host='0.0.0.0')
