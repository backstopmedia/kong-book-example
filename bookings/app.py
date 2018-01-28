from flask import Flask, make_response
import json
import os
from werkzeug.exceptions import NotFound


app = Flask(__name__)


def root_dir():
  """ Returns root director for this project """
  return os.path.dirname(os.path.realpath(__file__))


def nice_json(arg):
  response = make_response(json.dumps(arg, sort_keys=True, indent=4))
  response.headers['Content-type'] = "application/json"
  return response


with open("{}/bookings.json".format(root_dir()), "r") as f:
  bookings = json.load(f)


@app.route("/", methods=['GET'])
def hello():
  return nice_json({
      "uri": "/",
      "subresource_uris": {
          "bookings": "/bookings",
          "booking": "/bookings/<username>"
      }
  })


@app.route("/bookings", methods=['GET'])
def booking_list():
  return nice_json(bookings)


@app.route("/bookings/<username>", methods=['GET'])
def booking_record(username):
  if username not in bookings:
    raise NotFound

  return nice_json(bookings[username])


if __name__ == "__main__":
  app.run(host='0.0.0.0', debug=True)
