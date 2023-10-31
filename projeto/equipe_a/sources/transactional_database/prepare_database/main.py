import jinja2
from pathlib import Path
from dotenv import load_dotenv
import os
import logging
from sqlalchemy import create_engine, text
import boto3
from botocore.exceptions import NoCredentialsError
import json
import urllib.parse


def read_query(path: Path):
    with open(path, "r") as f:
        result = f.read()

    return result


# def retrive_secret_from_secret_manager(key:str, session=boto3.session.Session()):

#     # Initialize the Secrets Manager client
#     client = session.client(service_name='secretsmanager')

#     # Retrieve the secret value
#     response = client.get_secret_value(SecretId=key)
#     secret_value = response['SecretString']
#     secret_value = json.loads(secret_value)
#     return secret_value


def main():
    load_dotenv()
    environment = jinja2.Environment(autoescape=True)
    postgres_root_username = os.environ["postgres_root_user"]
    postgres_root_password = os.environ["postgres_root_password"]
    postgres_app_username = os.environ["postgres_app_user"]
    postgres_app_password = os.environ["postgres_app_password"]
    postgres_host = os.environ["postgres_host"]
    postgres_database = os.environ["postgres_database"]
    postgres_port = os.environ["postgres_port"]

    logging.info("Getting query to create first elements in database")
    query = read_query(Path("./create_first_elements.sql"))
    template = environment.from_string(query)
    logging.info("Applying jinja formatting in query")
    query = template.render(user=postgres_app_username, password=postgres_app_password)

    connection_string = f"postgresql://{postgres_root_username}:{postgres_root_password}@{postgres_host}:{postgres_port}/{postgres_database}"
    postgres_root_engine = create_engine(connection_string, isolation_level="AUTOCOMMIT")
    postgres_root_connection = postgres_root_engine.connect()

    logging.info("Creating (if not exists) user and altering database ownership")
    postgres_root_connection.execute(text(query))
    logging.info("Successfully did previous SQL Command")

    logging.info("Creating (if not exists) partial databases")
    query = read_query(Path("./partial_database_structure.sql"))
    logging.getLogger("sqlalchemy.engine").setLevel(logging.INFO)
    connection_string = f"postgresql://{postgres_app_username}:{postgres_app_password}@{postgres_host}:{postgres_port}/{postgres_database}"
    postgres_root_engine = create_engine(connection_string, isolation_level="AUTOCOMMIT")
    postgres_root_connection = postgres_root_engine.connect()
    postgres_root_connection.execute(text(query))
    logging.info("Successfully did previous SQL Command")


if __name__ == "__main__":
    main()
