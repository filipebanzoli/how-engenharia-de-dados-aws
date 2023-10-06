import requests
import logging
import json
import ratelimit
from abc  import ABC, abstractmethod
from backoff import on_exception,expo
import datetime


logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

ch = logging.StreamHandler()
ch.setFormatter(formatter)
logger.addHandler(ch)


class PaoAcucarApi(ABC):
    def __init__(self,search:str) -> None:
        self.search = search
        self.base_endpoint = "https://api.linximpulse.com/engage/search/v3/"
    
    @abstractmethod    
    def _get_endpoint(self,**kwargs)-> str:
        pass
                          
    @on_exception(expo,ratelimit.exception.RateLimitException,max_tries = 6)
    @on_exception(expo,requests.exceptions.RequestException)   
    @ratelimit.limits(calls=29,period=30)
    @on_exception(expo,requests.exceptions.HTTPError,max_tries=6,logger=logger)
    def get_data(self,**kwargs) -> dict:
        endpoint = self._get_endpoint(**kwargs)
        try:
            response = requests.get(url=endpoint)
            return response.json()
        except requests.RequestException as e:
            logger.error(f"Request failed: {e}")
            raise
class SearchApi(PaoAcucarApi):
    type_ = "search"
    def _get_endpoint(self, pag) -> str:
        complement = f"apikey=paodeacucar&origin=https://www.paodeacucar.com&page={pag}&resultsPerPage=12&terms={self.search}"
        return f"{self.base_endpoint}/{self.type_}?{complement}"     
