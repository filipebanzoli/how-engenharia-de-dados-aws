import requests
from bs4 import BeautifulSoup
from utils.bs4_utils import get_nested_dict_attr_value
from datetime import datetime
import urllib.parse

class CondorWebsite():

    def __init__(self) -> None:
        self.base_url = "https://www.condor.com.br/pesquisa-usuario/"
        self.build_url_search = None

    def _build_url_search(self, search: str):
        search_converter = search.replace(' ', '-')
        url = urllib.parse.urljoin(self.base_url, search_converter)
        self.build_url_search = url
        return url

    def get_website_data(self, search: str) -> str:
        url = self._build_url_search(search)
        response = requests.get(url)
        return response.text
    
    def parse_website_data(self, response_text :str):
        soup = BeautifulSoup(response_text, 'html.parser')

        # This are the products not in the session "FIND MORE"
        products = soup.find("div", {"class": "row mb-4"}).findAll("app-product")
        products_data = []
        for product in products:
            product_data = get_nested_dict_attr_value(product, 'class')
            product_data = self.add_metadata(product_data)
            products_data.append(product_data)

        return product_data


    def add_metadata(self, 
        d: dict, 
        created_at:datetime =datetime.now().strftime('%Y-%m-%dT%H:%M:%S.%f%z')
    ) -> dict:

        d["created_at"] = created_at
        d["build_url_search"] = self.build_url_search
        return d