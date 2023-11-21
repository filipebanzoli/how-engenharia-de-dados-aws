# Dockerfile, Image, Container
FROM public.ecr.aws/lambda/python:3.11

# Copiar requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Instalar os pacotes especificados
RUN pip install --no-cache-dir -r requirements.txt 

# Adicionar o resto da pasta à imagem docker
COPY . ${LAMBDA_TASK_ROOT}

# Executar programa python
CMD [ "lambda_function.handler" ]
