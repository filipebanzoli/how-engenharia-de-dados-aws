#%%
import requests
import logging
import pandas as pd
import json

from scrapping_call import SearchApi
from writers import DataWriter

#%%
busca = ["arroz","feijão","refrigerantes"]
 
#%%
pag =  1
total_pag = 2
while pag < total_pag:
        
    for elem in busca:
        sc = SearchApi(search=elem)
        ret = sc.get_data(pag = 1)
        writer = DataWriter(busca= elem,api= sc.type_)
        writer.write(ret)
        pag+=1
        total_pag = ret["size"]


    










         
         
         


# %%
#if __name__ == "__main__":

    #logging.getLogger().setLevel(logging.INFO)
    #logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
    #main()