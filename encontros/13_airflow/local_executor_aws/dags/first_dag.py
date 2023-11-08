import datetime

from airflow import DAG
from airflow.operators.empty import EmptyOperator

with DAG(dag_id="first_dag", start_date=datetime.datetime(2023, 11, 6), schedule="@daily", catchup=False):
    EmptyOperator(task_id="task")
