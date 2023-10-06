from pathlib import Path
import os
import logging
import boto3
import json
import urllib.parse
from botocore import exceptions
from botocore.exceptions import ClientError
from dotenv import load_dotenv
from os import getenv




class S3BucketManager:
    def __init__(self):
        self.s3_client = boto3.client(
                                    "s3"
                                    #,
                                    #aws_access_key_id = getenv("AWS_ID"),
                                    #aws_secret_access_key = getenv("AWS_KEY")
    
)
    def _create_bucket(self, bucket_name):
        try:
            response =  self.s3_client.create_bucket(Bucket=bucket_name)
        except ClientError as e:
            logging.error(e)  
            return False, e
        return True,response

    def list_buckets(self):
        try:
            response = self.s3_client.list_buckets()
            buckets = [bucket['Name'] for bucket in response['Buckets']]
        except ClientError as e:
            logging.error(e)
            return e
        return buckets

    def delete_bucket(self, bucket_name):
        try:
            response = self.s3_client.delete_bucket(Bucket=bucket_name)
        except ClientError as e:
            logging.error(e)
            return False,e
        return True,response
    
    def upload_file_bucket(self,file, bucket_name,name_arq):
        try:
            response =  self.s3_client.upload_fileobj(file,bucket_name,name_arq)
        except ClientError as e:
            logging.error(e)  
            return False, e
        return True,response    
    def list_objbuckets(self,bucket_name):
        try:
            response = self.s3_client.list_objects(Bucket=bucket_name)
            if 'Contents' in response:
                return response['Contents']
            else: logging.exception("Não foi encontrado arquivos")
        except ClientError as e:
            logging.error(e)
            return e
    def delete_file_from_bucket(self, bucket_name,file):
        try:
            response = self.s3_client.delete_object(Bucket=bucket_name, Key=file)
        except ClientError as e:
            logging.error(e)
            return False,e
        return True,response        




s3 = S3BucketManager()        