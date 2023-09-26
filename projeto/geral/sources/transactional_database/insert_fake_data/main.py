from faker import Faker
import jinja2
from pathlib import Path
from dotenv import load_dotenv
import os
import logging
from sqlalchemy import create_engine, text
import boto3
import json
import urllib.parse
from faker import Faker
import random
import os


STATUSES = ["ORDER_ISSUED", "SEPARATING_IN_STOCK", "DELIVERING", "DELIVERED"]

STATES = [
    "AC",
    "AL",
    "AM",
    "AP",
    "BA",
    "CE",
    "DF",
    "ES",
    "GO",
    "MA",
    "MG",
    "MS",
    "MT",
    "PA",
    "PB",
    "PE",
    "PI",
    "PR",
    "RJ",
    "RN",
    "RO",
    "RR",
    "RS",
    "SC",
    "SE",
    "SP",
    "TO",
]

# def retrive_secret_from_secret_manager(key:str, session=boto3.session.Session()):


#     print(os.environ)
#     # Initialize the Secrets Manager client
#     client = session.client(service_name='secretsmanager')

#     # Retrieve the secret value
#     response = client.get_secret_value(SecretId=key)
#     secret_value = response['SecretString']
#     secret_value = json.loads(secret_value)
#     return secret_value


def read_query(path: Path):
    with open(path, "r") as f:
        result = f.read()

    return result


def main():
    logging.info("Loading Env")
    load_dotenv()
    environment = jinja2.Environment(autoescape=True)

    fake = Faker("pt-BR")

    postgres_app_username = os.environ["postgres_app_username"]
    postgres_app_password = os.environ["postgres_app_password"]
    postgres_host = os.environ["postgres_host"]
    postgres_database = os.environ["postgres_database"]
    postgres_port = os.environ["postgres_port"]

    logging.info("Connecting to database")

    # logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)
    connection_string = f"postgresql://{postgres_app_username}:{postgres_app_password}@{postgres_host}:{postgres_port}/{postgres_database}"
    postgres_root_engine = create_engine(connection_string)
    postgres_root_connection = postgres_root_engine.connect()

    logging.info("Successfully connected to database")

    logging.info("Getting query to insert in database")
    raw_query = read_query(Path("./partial_sql_insert.sql"))

    for i in range(200):
        logging.info(f"Preparing to insert {i} row")
        logging.info("Applying jinja formatting in query")
        template = environment.from_string(raw_query)

        address_street = fake.street_name()
        address_number = fake.building_number()
        address_postcode = fake.postcode()
        address_city = fake.city()
        address_state = random.choice(STATES)  # nosec B311 - For test purposes only, not used for production
        supplier_name = fake.company()

        query = template.render(
            order_status=STATUSES[0],
            address_street=address_street,
            address_number=address_number,
            address_postcode=address_postcode,
            address_city=address_city,
            address_state=address_state,
            supplier_name=supplier_name,
        )

        logging.info("Running insert in database")
        postgres_root_connection.execute(text(query))

        logging.info("Successfully inserted in database")

    logging.info("Successfully finished insert_fake_data script")


if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    logging.basicConfig(format="%(asctime)s - %(message)s", level=logging.INFO)
    main()
