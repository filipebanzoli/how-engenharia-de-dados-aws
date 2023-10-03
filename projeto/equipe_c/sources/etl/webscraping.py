import json
import requests
from bs4 import BeautifulSoup
from abc import ABC, abstractmethod
from projeto.equipe_c.sources.utils.utils import get_nested_dict_attr_value


class PaoDeAcucarWebScrapping(ABC):
    def __init__(self, produto: str) -> None:
        self.base_url = "https://www.paodeacucar.com/busca?terms="
        self.produto = produto
        self.url = self.base_url + self.produto

    def scrapping_data(self) -> json:
        response = requests.get(self.url)

        soup = BeautifulSoup(response.text)

        products = soup.find("div", {"class": "product-cardstyles__CardStyled-sc-1uwpde0-0 bTCFJV cardstyles__Card-yvvqkp-0 gXxQWo"}).findAll("product-cardstyles__Link-sc-1uwpde0-9 bSQmwP hyperlinkstyles__Link-j02w35-0 coaZwR")

        products_data = []
        for product in products:
            products_data.append(get_nested_dict_attr_value(product, 'class'))    

        return json.dumps(products_data)            

