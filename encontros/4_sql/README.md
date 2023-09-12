## Encontro 4 SQL

O planejamento do encontro de hoje é criar e alimentar um banco de dados RDS Postgres, usando dados fake gerados por uma AWS Lambda. Ao longo dos exercícios e desenvolvimento do projeto, vamos trabalhar com as seguintes tecnologias hoje:

- AWS RDS (Postgres)
- Python
- AWS Lambda
- AWS Cli
- AWS CloudWatch Events
- AWS CloudWatch Logs


## Reforço de SQL

Caso tenha interesse em fazer um reforço de SQL, [recomendo fazer esse tutorial aqui](https://www.w3schools.com/sql/default.asp).

## Projeto Etapas:

1. Subir banco de Dados RDS
2. Executar script `main.py` em [prepare_database](../../projeto/sources/transactional_database/prepare_database), para criar o usuário e primeiras tabelas. Se quiser, criar tabelas adicionais [descritas aqui](../../projeto/sources/transactional_database/database_structure.dbml) e [aqui](../../projeto/sources/transactional_database/database_structure.png)
3. Executar scripts em [insert_fake_data](../../projeto/sources/transactional_database/insert_fake_data), e depois disso buildar o container e subir como uma função AWS Lambda na AWS.

## Criando um banco de dados RDS Postgres

Segue abaixo um comando do AWS Cli para criar um banco de dados RDS Postgres. [Definição do Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html). Existe um free tier para o uso do AWS RDS, [confira aqui mais detalhes](https://aws.amazon.com/rds/free/).

O banco de dados RDS que eu criar eu quero que fique disponível na internet, para facilitar meu acesso, mas que somente possa ser acessível através do meu IP público. Para isso primeiramente vamos criar um Security Group na VPC.

`aws ec2 create-security-group --group-name my-ip --description "Allow access by my Public IP Address"`

Copie o GroupID gerado para o seu recém criado security group. Substitua ele no próximo comando em YOUR_GROUP_ID

Agora vamos incluir o security group ingress permitindo acesso de entrada do meu IP público. Para saber o seu IP público, [você pode acessar esse site aqui](https://meuip.com.br/). Substitua em YOUR_IP_ADDRESS.

`aws ec2 authorize-security-group-ingress --group-id YOUR_GROUP_ID --protocol tcp --port 5432 --cidr YOUR_IP_ADDRESS/32`

**Linux Command:**
_Um comentário pontual aqui, perceba que a barra invertida (ou back slash) `\` é um sinal para quebra de linha de um mesmo comando no terminal Linux._
_No terminal Windows esse comando `^`, o circunflexo, ou no inglês carret._

```bash
aws rds create-db-instance \
    --db-name transactional \
    --db-instance-identifier transactional \
    --no-multi-az \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --master-username postgres \
    --manage-master-user-password \
    --allocated-storage 20 \
    --backup-retention-period 0 \
    --storage-type gp2 \
    --publicly-accessible \
    --vpc-security-group-ids YOUR_GROUP_ID
```

Segue aqui um exemplo do [retorno JSON](./create_rds.json) do comando SQL de criação do banco de dados Postgres.

Para criar um usuário no banco a ser usado posteriormente para criação de tabelas, execute o seguinte comando SQL,
 substituindo YOUR_PASSWORD por uma senha desejada a ser usada no postgres. Se atente para usar caracteres válidos
 para a senha.

Perceba que o serviço AWS Secrets Manager possui atualmente um free trial de 30 dias a partir da primeira vez que foi
 cadastrado uma chave lá. Depois disso, só de armazenagem da senha se paga 0.40 de dólar por mês.

```bash
aws secretsmanager create-secret \
        --name postgres_transactional_fake_data_app \
        --secret-string '{"username": "fake_data_app", "password": "YOUR_PASSWORD"}'
```

Depois de esperar um momento e o banco de dados estiver disponível, execute a consulta abaixo para pegar o host
 do banco de dados, você irá usar essa informação para inserir no arquivo .env em (`projeto/sources/transactional_database/prepare_database/.env`).

```bash
aws rds describe-db-instances --db-instance-identifier transactional \
        --query 'DBInstances[0].Endpoint.Address' \
        --output text
```

Para fazer o build do container com o código em docker. Eu sugiro utilizar aqui em CONTAINER_NAME
o nome do projeto insert_fake_data ou prepare_database.

_Perceba o uso de uma imagem customizada da AWS do Dockerfile, [veja aqui](https://gallery.ecr.aws/lambda/python/)_

```bash
docker buildx build --platform=linux/arm64 -t CONTAINER_NAME .
```

Para rodar o script localmente:

```bash
docker run --env-file .env CONTAINER_NAME
```

Tutorial para buildar a função Lambda na AWS:

[https://docs.aws.amazon.com/lambda/latest/dg/python-image.html#python-image-clients](https://docs.aws.amazon.com/lambda/latest/dg/python-image.html#python-image-clients)


Criar uma AWS IAM Role para executar a AWS Lambda. Substitua SUA_AWS_ACCOUNT_ID por sua account id.

```json

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:us-east-1:SUA_AWS_ACCOUNT_ID:secret:postgres_transactional_fake_data_app*"
        }
    ]
}

```


Execute o comando abaixo para criar a policy, e copie o ARN da POLICY:
```bash
aws iam create-policy --policy-name read_fake_data_app_secret_key --policy-document file://secrets-manager-policy.json
```

Para criar a IAM Role, copie o ARN da ROLE:

```bash
aws iam create-role --role-name execute_lambda_insert_fake_data --assume-role-policy-document file://trust-policy.json
```

Attach these policies to the Role:

```bash
aws iam attach-role-policy --role-name execute_lambda_insert_fake_data --policy-arn POLICY_ARN
```

```bash
aws iam attach-role-policy --role-name execute_lambda_insert_fake_data --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

Para criar a AWS Lambda, substituta ROLE_ARN pela ARN da ROLE, substitua ECR_URI pelo URI da imagem do ECR.

```bash
aws lambda create-function \
  --function-name insert_fake_data \
  --package-type Image \
  --code ImageUri=ECR_URI \
  --role ROLE_ARN \
  --architectures "arm64" \
  --memory-size 3008 \
  --timeout 60 \
  --region us-east-1 \
  --environment Variables={postgres_app_user_kms_key=postgres_transactional_fake_data_app,postgres_host=transactional.cf6dzsnazmsf.us-east-1.rds.amazonaws.com,postgres_database=transactional,postgres_port=5432}
```