import datetime
import os
import logging
from typing import List
import json

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


class DataTypeNotSupportedForIngestionException(Exception):
    def __init__(self,data) -> None:
         self.data = data
         self.message = f"Data type {type(data)} is not supported for ingestion"
         super().__init__(self.message) 

class DataWriter:
    def __init__(self,busca: str , api: str) -> None:
          self.busca = busca 
          self.api = api
          self.filename = f"{self.api}/{self.busca}/{datetime.datetime.now()}.json"
          
    def _write_row (self, row: str) -> None:
          logger.info(f"Iniciando a escrita de linhas")
          os.makedirs(os.path.dirname(self.filename),exist_ok= True)
          with open(self.filename,"a") as f: 
                 f.write(row)
    def write(self,data:(List,dict)):
          if isinstance(data,dict):
                 logger.info(f"Iniciando a escrita do json")
                 self._write_row(json.dumps(data) + "\n")
          elif isinstance(data,List):
              for elem in data:
                logger.info(f"Iniciando a escrita do json")
                self.write(elem)    
          else:
               raise DataTypeNotSupportedForIngestionException(data)      
                           
