from scrapping_call import SearchApi


req = SearchApi(search="refrigerante")
print(req.get_data(pag = 1))