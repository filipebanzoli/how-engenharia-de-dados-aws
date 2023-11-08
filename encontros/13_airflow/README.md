# Encontro 13 - Airflow

- O que é o Airflow?
	- [https://airflow.apache.org/docs/apache-airflow/stable/index.html](https://airflow.apache.org/docs/apache-airflow/stable/index.html)
	- [https://hub.docker.com/r/apache/airflow](https://hub.docker.com/r/apache/airflow)
	- [https://docs.astronomer.io/learn/intro-to-airflow](https://docs.astronomer.io/learn/intro-to-airflow)
- História da ferramenta:
	- [https://docs.astronomer.io/learn/intro-to-airflow#history](https://docs.astronomer.io/learn/intro-to-airflow#history)
	- [https://docs.astronomer.io/learn/category/get-started](https://docs.astronomer.io/learn/category/get-started)
- Arquitetura base do Airflow (componentes do Airflow)
	- [https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/overview.html](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/overview.html)
	- Worker
	- Scheduler
	- Webserver
- Executor
	- [https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/executor/index.html](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/executor/index.html)
- Rodando o Airflow local no Docker Compose
	- [https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html).
	- Disponibilizei 3 arquiteturas locais para o Airflow, com docker compose:
       - [celery_executor](./celery_executor): Arquitetura original do Airflow para o Docker Compose, a qual utiliza o [Celery Executor](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/executor/celery.html).
       - [local_executor](./local_executor/): [Arquitetura de exemplo](https://github.com/marclamberti/docker-airflow/tree/main) feita pelo [Marc Lamberti](https://marclamberti.com/) utilizando [Local Executor](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/executor/local.html).
       - [local_executor_aws](./local_executor_aws): Adaptação da arquitetura acima, instalando o provider da AWS.
- Componentes do Airflow:
  - DAG
  	- [https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html)
  - Operator
  	- [https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/operators.html](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/operators.html)
  	- [https://airflow.apache.org/docs/apache-airflow/stable/templates-ref.html#templates-ref](https://airflow.apache.org/docs/apache-airflow/stable/templates-ref.html#templates-ref)
  - Sensor
  	- [https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/sensors.html](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/sensors.html)
  - Dependencies
  	- [https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html#task-dependencies](https://airflow.apache.org/docs/apache-airflow/stable/core-concepts/dags.html#task-dependencies)
  - Connection
  	- [https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html](https://airflow.apache.org/docs/apache-airflow/stable/howto/connection.html)
  - Variables
  	- [https://airflow.apache.org/docs/apache-airflow/stable/howto/variable.html](https://airflow.apache.org/docs/apache-airflow/stable/howto/variable.html)
  - Pool
  	- [https://docs.astronomer.io/learn/airflow-pools](https://docs.astronomer.io/learn/airflow-pools)
  - As diferentes Views do Airflow
    - [https://airflow.apache.org/docs/apache-airflow/stable/ui.html](https://airflow.apache.org/docs/apache-airflow/stable/ui.html)
  - Mostrar configurações do Airflow
    - [https://airflow.apache.org/docs/apache-airflow/stable/howto/set-config.html](https://airflow.apache.org/docs/apache-airflow/stable/howto/set-config.html)
  - Competidores:
    - [Dagster](https://dagster.io/)
    - [Prefect](https://www.prefect.io/)
    - [Mage](https://www.mage.ai/)
- Para deploy em produção:
  - [WMAA](https://aws.amazon.com/pt/managed-workflows-for-apache-airflow/): A versão gerenciada pela AWS do Airflow.
  - [Astronomer](https://www.astronomer.io/): Versão gerenciada (e ampliada) do Airflow pelos maiores commiters do projeto do Airflow.
  - [Kubernetes Helm Chart](https://airflow.apache.org/docs/helm-chart/stable/index.html): Forma recomendada de subir o Airflow por conta própria em produção, eu recomendo utilizar essa opção caso sua equipe possua conhecimentos em Kubernetes.
  - [ECS](https://github.com/andresionek91/airflow-autoscaling-ecs): Um exemplo de arquitetura do Airflow no ECS, mais uma possibilidade. Existe muitas boas práticas nesse projeto, recomendo darem uma olhada.

Tarefa de casa:
- Testar localmente o Airflow Local.

Tarefa de casa opcional:
- Utilizar ele para trigar uma lambda AWS a cada 15 minutos. ([para isso utilize a arquitetura do airflow aonde já está instalado o provider AWS do airflow](./local_executor_aws) (um package adicional, [perceba que ali no Dockerfile](./local_executor_aws/Dockerfile) estamos instalando adicionalmente essa biblioteca).
