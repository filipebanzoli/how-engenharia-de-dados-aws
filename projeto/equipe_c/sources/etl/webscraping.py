import requests
from bs4 import BeautifulSoup


def get_nested_dict_attr_value(tag, attr):
    attr_dict = {}
    if hasattr(tag, 'children'):
        for subtag in tag.children:
            if hasattr(subtag, 'attrs') and attr in subtag.attrs:
                classes = " ".join(subtag.attrs[attr])
                attr_dict[classes] = subtag.get_text()
            attr_dict.update(get_nested_dict_attr_value(subtag, attr))
    return attr_dict



search = 'arroz'
search_converter = search.replace(' ', '-')
url = f'https://www.condor.com.br/pesquisa-usuario/{search_converter}'

response = requests.get(url)

soup = BeautifulSoup(response.text)
products = soup.find("div", {"class": "row mb-4"}).findAll("app-product")


products_data = []
for product in products:
    products_data.append(get_nested_dict_attr_value(product, 'class'))


products_data

