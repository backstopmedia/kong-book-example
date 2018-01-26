from flask import Flask, make_response
from werkzeug.exceptions import NotFound
import json
import os


app = Flask(__name__)


def root_dir():
  """ Returns root director for this project """
  return os.path.dirname(os.path.realpath(__file__))


def nice_json(arg):
  response = make_response(json.dumps(arg, sort_keys=True, indent=4))
  response.headers['Content-type'] = "application/json"
  return response


with open("{}/showtimes.json".format(root_dir()), "r") as f:
  showtimes = json.load(f)


@app.route("/", methods=['GET'])
def hello():
  return nice_json({
      "uri": "/",
      "subresource_uris": {
          "showtimes": "/showtimes",
          "showtime": "/showtimes/<date>"
      }
  })


@app.route("/showtimes", methods=['GET'])
def showtimes_list():
  return nice_json(showtimes)


@app.route("/showtimes/<date>", methods=['GET'])
def showtimes_record(date):
  if date not in showtimes:
    raise NotFound
  print(showtimes[date])
  return nice_json(showtimes[date])


if __name__ == "__main__":
  app.run(host="0.0.0.0", debug=True)
