import requests
from abc import abstractmethod
from utils.logger import Overwatch

logger = Overwatch()


class WebCrawler:
    def __init__(self, headers: dict = None) -> None:
        self.headers = headers
        pass

    @property
    @abstractmethod
    def _set_base_url(self):
        pass

    @abstractmethod
    def _get_url(self, **kwargs) -> str:
        pass

    def get_html(self, **kwargs) -> str:
        reference_url = self._get_url(**kwargs)
        logger.logger.info(f"Getting html for url {reference_url}.")
        r = requests.get(url=reference_url, headers=self.headers)
        return r.text


class WebCrawlerCondor(WebCrawler):
    def __init__(self, headers: dict) -> None:
        super().__init__(headers)

    @property
    def base_url(self) -> None:
        return "https://www.condor.com.br/pesquisa-usuario"

    def _get_url(self, product: str) -> str:
        return f"{self.base_url}/{product}"
