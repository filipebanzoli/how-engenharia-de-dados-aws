#%%
import requests
import logging
import pandas as pd
import json

from scrapping_call import ApiPaoAcucar


#%%
busca = ["arroz","feijão"]

url = "https://api.linximpulse.com/engage/search/v3/search?apikey=paodeacucar&origin=https://www.paodeacucar.com&page=1&resultsPerPage=12&terms=feijão"
ret = requests.get(url=url)
nome_arquivo = "pao-acucar-arroz.json"

try: 
    with open(file=nome_arquivo,mode="w")  as f:
            f.write(ret.text)
except KeyError as e:
    print(e)         

try:        
    with open(file=nome_arquivo , mode="r") as f:
        data = json.load(fp=f)    
except KeyError as e:
    print(e)

item_id_list = []
nome_list = []
price_list = []
url_prod_list = []
images_list = []
category_name_list = []


# Iterar sobre os dados e adicionar os valores às listas
for produto in data["products"]:
    try:
        item_id = produto["id"]
    except KeyError:
        item_id = None
    item_id_list.append(item_id)

    try:
        nome = produto["name"]
    except KeyError:
        nome = None
    nome_list.append(nome)

    try:
        price = produto["price"]
    except KeyError:
        price = None
    price_list.append(price)

    try:
        url_prod = produto["url"]
    except KeyError:
        url_prod = None
    url_prod_list.append(url_prod)

    try:
        images = produto["images"]["default"]
    except (KeyError, TypeError):
        images = None
    images_list.append(images)
    
    try:
        category_name = produto["details"]["categoryName"][0]
    except KeyError:
        category_name = None
    category_name_list.append(category_name)

# Criar o DataFrame com as listas de dados
df = pd.DataFrame({
    "item_id": item_id_list,
    "nome_produto": nome_list,
    "price": price_list,
    "url_prod": url_prod_list,
    "images": images_list,
    "category_name": category_name_list
})

# Exibir o DataFrame
#%%
df.head()






         
         
         


# %%
if __name__ == "__main__":

    logging.getLogger().setLevel(logging.INFO)
    logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
    main()