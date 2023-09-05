import sys
from main import main
def handler(event, context):
    try:
        main()
        return 'Job successfully ran'
    except Exception as e:
        return f'Job unsuccessfully ran, error: {e}'