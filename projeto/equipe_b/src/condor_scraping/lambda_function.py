# from main import main
import logging
from main import main

def handler(event, context):
    try:
        print('Executing Main Function')
        logging.getLogger().setLevel(logging.INFO)
        logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)
        print("Hello world")
        main()
        print("Job Runned")
        return 'Job successfully ran'
    except Exception as e:
        return f'Job unsuccessfully ran, error: {e}'    

if __name__ == "__main__":
    handler(None, None)