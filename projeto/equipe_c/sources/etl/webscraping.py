import json
import requests
from bs4 import BeautifulSoup
from abc import ABC, abstractmethod
from projeto.equipe_c.sources.utils.utils import get_nested_dict_attr_value


class PaoDeAcucarWebScrapping(ABC):
    def __init__(self) -> None:
        self.base_url = "https://www.paodeacucar.com/"

    def scrapping_data(self, produto: str) -> json:
        url = self.base_url + produto

        response = requests.get(url)

        soup = BeautifulSoup(response.text)

        products = soup.find("div", {"class": "row mb-4"}).findAll("app-product")

        products_data = []
        for product in products:
            products_data.append(get_nested_dict_attr_value(product, 'class'))    

        return json.dumps(products_data)            

