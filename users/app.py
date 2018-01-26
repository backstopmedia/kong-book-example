from flask import Flask, make_response
from werkzeug.exceptions import NotFound, ServiceUnavailable
import json
import os
import requests


app = Flask(__name__)


def root_dir():
  """ Returns root director for this project """
  return os.path.dirname(os.path.realpath(__file__))


def nice_json(arg):
  response = make_response(json.dumps(arg, sort_keys=True, indent=4))
  response.headers['Content-type'] = "application/json"
  return response


with open("{}/users.json".format(root_dir()), "r") as f:
  users = json.load(f)


@app.route("/", methods=['GET'])
def hello():
  return nice_json({
      "uri": "/",
      "subresource_uris": {
          "users": "/users",
          "user": "/users/<username>",
          "bookings": "/users/<username>/bookings",
          "suggested": "/users/<username>/suggested"
      }
  })


@app.route("/users", methods=['GET'])
def users_list():
  return nice_json(users)


@app.route("/users/<username>", methods=['GET'])
def user_record(username):
  if username not in users:
    raise NotFound

  return nice_json(users[username])


@app.route("/users/<username>/bookings", methods=['GET'])
def user_bookings(username):
  """
  Gets booking information from the 'Bookings Service' for the user, and
   movie ratings etc. from the 'Movie Service' and returns a list.
  :param username:
  :return: List of Users bookings
  """
  if username not in users:
    raise NotFound("User '{}' not found.".format(username))

  try:
    users_bookings = requests.get(
        "http://bookings:5000/bookings/{}".format(username))
  except requests.exceptions.ConnectionError:
    raise ServiceUnavailable("The Bookings service is unavailable.")

  if users_bookings.status_code == 404:
    raise NotFound("No bookings were found for {}".format(username))

  users_bookings = users_bookings.json()
  print(users_bookings)

  # For each booking, get the rating and the movie title
  result = {}
  for date, movies in users_bookings.items():
    result[date] = []
    for movieid in movies:
      try:
        movies_resp = requests.get(
            "http://movies:5000/movies/{}".format(movieid))
      except requests.exceptions.ConnectionError:
        raise ServiceUnavailable("The Movie service is unavailable.")
      movies_resp = movies_resp.json()
      result[date].append({
          "title": movies_resp["title"],
          "rating": movies_resp["rating"],
          "uri": movies_resp["uri"]
      })

  return nice_json(result)


@app.route("/users/<username>/suggested", methods=['GET'])
def user_suggested(username):
  """
  Returns movie suggestions. The algorithm returns a list of 3 top ranked
  movies that the user has not yet booked.
  :param username:
  :return: Suggested movies
  """
  raise NotImplementedError()


if __name__ == "__main__":
  app.run(host="0.0.0.0", debug=True)
