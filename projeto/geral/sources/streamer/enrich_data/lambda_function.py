import logging
import json
import time
from datetime import datetime
import base64

# Json example
# {
#   "invocationId": "86e400fc-b5ad-4702-a600-56315f7da9b3",
#   "deliveryStreamArn": "arn:aws:firehose:us-east-1:666198551639:deliverystream/enriched-firehose",
#   "region": "us-east-1",
#   "records": [
#     {
#       "recordId": "49645296188931211378799005611102251918785200008403615746000000",
#       "approximateArrivalTimestamp": 1696802680683,
#       "data": "eyJDSEFOR0UiOjEuNiwiUFJJQ0UiOjM0LjQsIlRJQ0tFUl9TWU1CT0wiOiJQSk4iLCJTRUNUT1IiOiJSRVRBSUwifQ=="
#     },
#     {
#       "recordId": "49645296188931211378799005611103460844604814981175705602000000",
#       "approximateArrivalTimestamp": 1696802685853,
#       "data": "eyJDSEFOR0UiOi02LjgsIlBSSUNFIjo2OSwiVElDS0VSX1NZTUJPTCI6IlNMVyIsIlNFQ1RPUiI6IkVORVJHWSJ9"
#     }
#   ]
# }


def handler(event, context):
    try:
        print("Executing Main Function")
        logging.getLogger().setLevel(logging.INFO)
        logging.basicConfig(format="%(asctime)s - %(message)s", level=logging.INFO)
        log = logging.getLogger()
        log.info(event)
        # Iterar sobre os registros recebidos do Firehose
        for record in event["records"]:
            # Decodificar o registro em JSON
            payload = json.loads(base64.b64decode(record["data"]))

            # Adicionar uma coluna de data ao JSON
            payload["timestamp"] = int(time.mktime(datetime.now().timetuple()))

            # Converter o payload de volta para JSON
            new_data = base64.b64encode(json.dumps(payload).encode("utf-8")).decode("utf-8")
            # new_data = base64.b64encode(json.dumps(payload))

            # Preparar o registro para entrega ao Firehose
            record["data"] = new_data
            record["result"] = "Ok"

        # Retornar os registros transformados para o Firehose
        return {"records": event["records"]}
    except Exception as e:
        log.error(f"Job unsuccessfully ran, error: {e}")
        return {"records": event["records"]}
