import boto3

from botocore.exceptions import ClientError
from utils.logger import Overwatch
from abc import abstractmethod

logger = Overwatch()


class BucketManager:
    def __init__(self) -> None:
        pass

    @property
    def s3_client(self):
        return boto3.client("s3")

    @property
    def list_buckets(self):
        return [bucket["Name"] for bucket in self.s3_client.list_buckets()["Buckets"]]

    def put_object(self, bucket_name, data, path):
        try:
            logger.logger.info(f"Adding object {path} in bucket {bucket_name}")
            self.s3_client.put_object(Bucket=bucket_name, Body=data, Key=path)
        except ClientError as e:
            logger.logger.error(e)
            return False
        return True

    def delete_object(self, bucket_name, path):
        try:
            logger.logger.info(f"Deleting object {path} in bucket {bucket_name}")
            self.s3_client.delete_object(Bucket=bucket_name, Key=path)
        except ClientError as e:
            logger.logger.error(e)
            return False
        return True


class Ingestor(BucketManager):
    def __init__(self, bucket_name: str) -> None:
        super().__init__()
        self.bucket_name = bucket_name

    def ingest(self, data: [str], object_path: str) -> None:
        self.put_object(bucket_name=self.bucket_name, data=data, path=object_path)
        return None
