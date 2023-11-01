import boto3


def get_account_id() -> str:
    client = boto3.client("sts")
    response = client.get_caller_identity()
    account_id = response["Account"]
    return account_id
