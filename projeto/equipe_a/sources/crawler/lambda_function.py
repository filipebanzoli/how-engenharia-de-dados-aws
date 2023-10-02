import logging
from crawler_condor import main

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    try:
        logger.info("Executing Main Function")
        main(env_mode="dev")
        return "Job successfully ran"
    except Exception as e:
        return f"Job unsuccessfully ran, error: {e}"
