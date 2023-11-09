""" from flask_pymongo import PyMongo

mongo = PyMongo()


class BaseModelMixin:
    @staticmethod
    def get_collection():
        # Puedes sobrescribir este método en tus modelos específicos para retornar la colección que corresponda
        raise NotImplementedError(
            "Define la colección de MongoDB en tu modelo derivado."
        )

    def save(self):
        return self.get_collection().insert_one(self.__dict__)

    def delete(self):
        # Asume que el modelo tiene un campo "_id" que es el identificador en MongoDB
        return self.get_collection().delete_one({"_id": self._id})

    @classmethod
    def get_all(cls):
        return list(cls.get_collection().find())

    @classmethod
    def get_by_id(cls, id):
        return cls.get_collection().find_one({"_id": id})

    @classmethod
    def simple_filter(cls, **kwargs):
        return list(cls.get_collection().find(kwargs)) """


from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


class BaseModelMixin(db.Model):
    __abstract__ = True

    def save(self):
        db.session.add(self)
        db.session.commit()

    def delete(self):
        db.session.delete(self)
        db.session.commit()

    @classmethod
    def get_all(cls):
        return cls.query.all()

    @classmethod
    def get_by_id(cls, id):
        return cls.query.get(id)

    @classmethod
    def simple_filter(cls, **kwargs):
        return cls.query.filter_by(**kwargs).all()
