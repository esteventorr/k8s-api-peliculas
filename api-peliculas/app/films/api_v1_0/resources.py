from flask import make_response, request, Blueprint
from flask_restful import Api, Resource
from marshmallow import ValidationError

from .schemas import FilmSchema
from ..models import Film, Actor

# Definición del Blueprint y la API
films_v1_0_bp = Blueprint("films_v1_0_bp", __name__)

# Schema para Film
film_schema = FilmSchema()

api = Api(films_v1_0_bp)


class FilmResource(Resource):
    def get(self, film_id):
        film = Film.get_by_id(film_id)
        film_data = film_schema.dump(film)
        response = make_response(film_data)
        response.headers['Content-Type'] = 'application/json; charset=utf-8'
        return response


class FilmListResource(Resource):
    def get(self):
        films = Film.get_all()
        films_data = film_schema.dump(films, many=True)
        response = make_response(films_data)
        response.headers['Content-Type'] = 'application/json; charset=utf-8'
        return response

    def post(self):
        data = request.get_json()

        # film_dict = film_schema.load(data)
        # Carga los datos utilizando el esquema y maneja los errores
        try:
            film_dict = film_schema.load(data)
        except ValidationError as err:
            response = make_response(err.messages, 400)
            response.headers['Content-Type'] = 'application/json; charset=utf-8'
            return response

        # Verifica si film_dict es un diccionario
        if not isinstance(film_dict, dict):
            return {"message": "Invalid input data"}, 400

        film = Film(
            title=film_dict["title"],
            length=film_dict["length"],
            year=film_dict["year"],
            director=film_dict["director"],
        )

        # Aquí también deberías verificar si los actores están presentes y son una lista
        if "actors" in film_dict and isinstance(film_dict["actors"], list):
            for actor_data in film_dict["actors"]:
                actor = Actor(name=actor_data["name"])
                film.actors.append(actor)
        #   for actor in film_dict["actors"]:
        #       film.actors.append(Actor(name=actor["name"])) """

        # Guarda la película en la base de datos
        film.save()
        # Devuelve la película recién creada
        film_data = film_schema.dump(film)
        response = make_response(film_data, 201)
        response.headers['Content-Type'] = 'application/json; charset=utf-8'
        return response


# Adición de recursos a la API
api.add_resource(FilmListResource, "/api/v1.0/films/", endpoint="film_list_resource")
api.add_resource(
    FilmResource, "/api/v1.0/films/<int:film_id>", endpoint="film_resource"
)
