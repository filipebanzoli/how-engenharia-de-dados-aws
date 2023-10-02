import uuid

from utils.logger import Overwatch
from datetime import datetime
from utils.crawler_tools import WebCrawlerCondor
from utils.s3_tools import Ingestor
from utils.aws_tools import get_account_id


def main(env_mode: str = "dev"):
    aws_account_id = get_account_id()
    bucket = f"{env_mode}-datalake-how-equipe-a-{aws_account_id}"
    products = ["ovo", "pao", "trigo"]
    headers = {
        "accept": "*/*",
        "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36",
    }

    logger = Overwatch()
    ingestor = Ingestor(bucket_name=bucket)
    condor_crawler = WebCrawlerCondor(headers=headers)

    logger.logger.info(f"Starting webcrawler for products: {products}.")
    for product in products:
        data = condor_crawler.get_html(product=product)
        date = datetime.now().strftime("%Y-%m-%d")
        id = uuid.uuid4()
        path = f"condor_products_html/search={product}/date={date}/{id}.html"
        ingestor.ingest(data=data, object_path=path)

    logger.logger.info(f"Webcrawler ended successfully.")


if __name__ == "__main__":
    main()
