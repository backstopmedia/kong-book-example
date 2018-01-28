from flask import Flask, make_response
from werkzeug.exceptions import NotFound
import os
import json


app = Flask(__name__)


def root_dir():
  """ Returns root director for this project """
  return os.path.dirname(os.path.realpath(__file__))


def nice_json(arg):
  response = make_response(json.dumps(arg, sort_keys=True, indent=4))
  response.headers['Content-type'] = "application/json"
  return response


with open("{}/movies.json".format(root_dir()), "r") as f:
  movies = json.load(f)


@app.route("/", methods=['GET'])
def hello():
  return nice_json({
      "uri": "/",
      "subresource_uris": {
          "movies": "/movies",
          "movie": "/movies/<id>"
      }
  })


@app.route("/movies/<movieid>", methods=['GET'])
def movie_info(movieid):
  if movieid not in movies:
    raise NotFound

  result = movies[movieid]
  result["uri"] = "/movies/{}".format(movieid)

  return nice_json(result)


@app.route("/movies", methods=['GET'])
def movie_record():
  return nice_json(movies)


if __name__ == "__main__":
  app.run(host='0.0.0.0', debug=True)
