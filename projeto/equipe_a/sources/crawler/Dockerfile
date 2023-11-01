# Dockerfile, Image, Container
FROM public.ecr.aws/lambda/python:3.11

# Copy requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Install the specified packages
RUN pip install --no-cache-dir -r requirements.txt

# Add the rest of the folder to the docker image
COPY . ${LAMBDA_TASK_ROOT}

# run python program
CMD [ "lambda_function.handler" ]
