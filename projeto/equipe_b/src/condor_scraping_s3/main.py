import requests
from website.condor import CondorWebsite
import uuid
import json
from datetime import datetime
from pathlib import Path
import boto3
import io

def main():
    print('init scraping v3')

    searches = ['arroz', 'feijão',]

    # Conecte-se ao S3
    s3 = boto3.client('s3')

    bucket_name = "bucket-to-save-the-data"  # Substitua pelo nome do seu bucket

    for search in searches:
        print('searching')
        condor_api = CondorWebsite()
        print('searched')
        website_data = condor_api.get_website_data(search)

        print('data', website_data)
        id = uuid.uuid4()
        date = datetime.now().strftime('%Y-%m-%d')

        # Salvando HTML raw data no bucket S3
        s3_key_html = f'brass/condor_html/search={search}/date={date}/{id}.html'
        print("Start integrating with s3")
        s3.put_object(Bucket=bucket_name, Key=s3_key_html, Body=website_data)
        print(f'Uploaded HTML data to {s3_key_html}')

        parsed_website_data = condor_api.parse_website_data(website_data)
        print('parsed')

        # Salvando dados JSON no bucket S3
        s3_key_json = f'bronze/condor_html/search={search}/date={date}/{id}.json'
        s3.put_object(Bucket=bucket_name, Key=s3_key_json, Body=json.dumps(parsed_website_data))
        print(f'Uploaded JSON data to {s3_key_json}')

if __name__ == "__main__":
    main()


# import requests
# from website.condor import CondorWebsite
# import uuid
# import json
# from datetime import datetime
# from pathlib import Path
# import boto3
# import io



# def main():
#     print('init scraping')
    
#     searches = ['arroz', 'feijão',]

#     # Conecte-se ao S3
#     s3 = boto3.client('s3')

#     dados = "Seus dados de scraping aqui"

#     nome_arquivo = "meu-arquivo-de-scraping.txt"

#     # Nome do bucket S3 onde você deseja salvar os dados
 
#     bucket_nome = "bucket-to-save-the-data"  # Substitua pelo nome do seu bucket

#     # # Upload dos dados para o bucket
#     s3.put_object(Bucket=bucket_nome, Key=nome_arquivo, Body=dados)


#     for search in searches:
#         print('searching')
#         condor_api = CondorWebsite()
#         print('searched')
#         website_data = condor_api.get_website_data(search)

#         print('searched')
#         id = uuid.uuid4()
#         date = datetime.now().strftime('%Y-%m-%d')

#         # Pushing HTML raw data to brass datalake

#         print('creating directory')
#         directory_path = Path(f'downloads/brass/condor_html/search={search}/date={date}/')
#         directory_path.mkdir(parents=True, exist_ok=True)
#         print('created directory')
#         path = directory_path / f'{id}.html'
#         with open(path, 'w+') as f:
#             f.write(website_data)

#         print('wrote')

#         parsed_website_data = condor_api.parse_website_data(website_data)

#         print('parsed')
#         # Pushing JSON data to bronze datalake
        
#         directory_path = Path(f'downloads/bronze/condor_html/search={search}/date={date}/')
#         directory_path.mkdir(parents=True, exist_ok=True)
#         print('creating 2')
#         path = directory_path / f'{id}.json'
#         print('created 2')
#         with open(path, 'w+') as f:
#             json.dump(parsed_website_data, f)
#         print('wrote 2')

    
# if __name__ == "__main__":
#     main()
