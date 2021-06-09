import psycopg2 as ps
from psycopg2 import sql
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT


class Database(object):
    def __init__(self, name, user, password, host, port):
        self.dbname = name
        self.user = user
        self.password = password
        self.host = host
        self.port = port
        self.connectDB("postgres")
        self.cursor.execute("SELECT * FROM pg_catalog.pg_database WHERE datname = %s", (self.dbname,))
        flag = self.cursor.fetchone()
        if flag is None:
            self.cursor.execute(sql.SQL("CREATE DATABASE {}").format(sql.Identifier(self.dbname)))
        self.connection.close()
        self.connectDB(self.dbname)
        if flag is None:
            with self.connection.cursor() as cursor_:
                cursor_.execute(open("functions.sql", "r").read())

    def connectDB(self, name):
        self.connection = ps.connect(
            dbname=name,
            user=self.user,
            password=self.password,
            host=self.host,
            port=self.port
        )
        self.connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        self.cursor = self.connection.cursor()

    def delete_database(self):
        self.connectDB("postgres")
        self.cursor.execute(sql.SQL(f"DROP DATABASE {self.dbname}"))
        self.connection.close()
        del self

    def create_database(self):
        self.cursor.callproc("create_database")

    def get_departments(self):
        self.cursor.callproc("get_departments")
        return self.cursor.fetchone()[0]

    def get_persons(self):
        self.cursor.callproc("get_persons")
        return self.cursor.fetchone()[0]

    def add_to_department(self, ID, name):
        self.cursor.callproc("add_to_department", (ID, name,))

    def add_to_person(self, title, FIO, department):
        self.cursor.callproc("add_to_person", (title, FIO, department,))

    def clear_departments(self):
        self.cursor.callproc("clear_departments")

    def clear_persons(self):
        self.cursor.callproc("clear_persons")

    def clear_all(self):
        self.cursor.callproc("clear_all")

    def find_person_by_FIO(self, FIO):
        self.cursor.callproc("find_person", (FIO,))
        return self.cursor.fetchone()[0]

    def find_department(self, FIO):
        self.cursor.callproc("find_department", (FIO,))
        return self.cursor.fetchone()[0]

    def delete_person_by_FIO(self, FIO):
        self.cursor.callproc("delete_person_by_FIO", (FIO,))

    def delete_department_chosen(self, id):
        self.cursor.callproc("delete_department_chosen", (id,))

    def delete_person_chosen(self, id):
        self.cursor.callproc("delete_person_chosen", (id,))

    def update_department_by_ID(self, newID, id):
        self.cursor.callproc("update_department_by_ID", (newID, id,))

    def update_department_by_name(self, newname, id):
        self.cursor.callproc("update_department_by_name", (newname, id,))

    def update_person_by_title(self, newtitle, id):
        self.cursor.callproc("update_person_by_title", (newtitle, id,))

    def update_person_by_FIO(self, newFIO, id):
        self.cursor.callproc("update_person_by_FIO", (newFIO, id,))

    def update_person_by_department(self, newdepartment, id):
        self.cursor.callproc("update_person_by_department", (newdepartment, id,))

    def disconnect(self):
        self.connection.close()
