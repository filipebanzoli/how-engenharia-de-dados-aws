import requests
from website.condor import CondorWebsite
import uuid
import json
from datetime import datetime
from pathlib import Path


def main():
    print('init scraping')
    
    searches = ['arroz', 'feijão',]

    for search in searches:
        print('searching')
        condor_api = CondorWebsite()
        print('searched')
        website_data = condor_api.get_website_data(search)

        print('searched')
        id = uuid.uuid4()
        date = datetime.now().strftime('%Y-%m-%d')

        # Pushing HTML raw data to brass datalake

        print('creating directory')
        directory_path = Path(f'downloads/brass/condor_html/search={search}/date={date}/')
        directory_path.mkdir(parents=True, exist_ok=True)
        print('created directory')
        path = directory_path / f'{id}.html'
        with open(path, 'w+') as f:
            f.write(website_data)

        print('wrote')

        parsed_website_data = condor_api.parse_website_data(website_data)

        print('parsed')
        # Pushing JSON data to bronze datalake
        
        directory_path = Path(f'downloads/bronze/condor_html/search={search}/date={date}/')
        directory_path.mkdir(parents=True, exist_ok=True)
        print('creating 2')
        path = directory_path / f'{id}.json'
        print('created 2')
        with open(path, 'w+') as f:
            json.dump(parsed_website_data, f)
        print('wrote 2')

    
if __name__ == "__main__":
    main()
