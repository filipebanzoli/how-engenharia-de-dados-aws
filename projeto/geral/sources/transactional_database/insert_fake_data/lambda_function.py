from main import main
import logging


def handler(event, context):
    try:
        print("Executing Main Function")
        logging.getLogger().setLevel(logging.INFO)
        logging.basicConfig(format="%(asctime)s - %(message)s", level=logging.INFO)
        main()
        return "Job successfully ran"
    except Exception as e:
        return f"Job unsuccessfully ran, error: {e}"
