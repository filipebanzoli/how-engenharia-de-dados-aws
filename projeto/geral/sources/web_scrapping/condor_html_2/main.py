import requests
from bs4 import BeautifulSoup, Tag
from pathlib import Path
from datetime import datetime
import uuid



search = "arroz"
url = f"https://www.condor.com.br/pesquisa-usuario/{search}"

result = requests.get(url)
result_str = result.text

date = datetime.now().strftime('%Y-%m-%d')
id = uuid.uuid4()

directory_path = Path(f'downloads/brass/condor_html/search={search}/date={date}/')

# Por padrão não se cria uma cadeia de diretórios ao criar um arquivo,
# o comando abaixo faz isso

directory_path.mkdir(parents=True, exist_ok=True)

path = directory_path / f'{id}.html'

with open(path, 'w+') as f:
    f.write(result_str)

def get_nested_dict_attr_value(tag: Tag, attr: str):
    attr_dict = {}
    if hasattr(tag, 'children'):
        for subtag in tag.children:
            if hasattr(subtag, 'attrs') and attr in subtag.attrs:
                classes = " ".join(subtag.attrs[attr])
                attr_dict[classes] = subtag.get_text()
            attr_dict.update(get_nested_dict_attr_value(subtag, attr))
    return attr_dict

soup = BeautifulSoup(result_str)

products = soup.findAll("div", {"class": "col-md-4"})

# Perceba aqui as estruturas de dados. As listas
# seriam como as linhas de uma tabela
products_data = []
for product in products:
    # Enquanto que as colunas seriam os dicionários
    # como o dicionário gerado pela função get_nested_dict_attr_value
    products_data.append(get_nested_dict_attr_value(product, 'class'))

# Essa estrutura de lista de python como linha e dicionário
# de python como coluna é um padrão muito comumente utilizado
# em programas de python para dados.

# Acredito que JSON seja o tipo de dado mais usado e mais útil
# no universo WEB. Perceba que Python possui suporte nativo
# ao tipo de dado JSON por meio da biblioteca JSON

# Com ela é possível ler com facilidade dados em JSON (convertendo
# em dicionário Python) e o caminho contrario também (de dicionário
# python para JSON).

# Inclusive uma lista de dicionários é possível se converter em JSON
# é o que faremos agora.

import json

directory_path = Path(f'downloads/bronze/muffato_html/search={search}/date={date}/')
directory_path.mkdir(parents=True, exist_ok=True)
path = directory_path / f'{id}.json'
with open(path, 'w+') as f:
    json.dump(products_data, f)