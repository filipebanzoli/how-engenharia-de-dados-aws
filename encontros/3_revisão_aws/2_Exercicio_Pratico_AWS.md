
## Primeira parte - Habilitando IAM Identity Center

O [IAM Identity Center](https://aws.amazon.com/iam/identity-center/) é uma forma prática de gerenciar usuários na AWS e vamos aprender a como usar ela.

Acesse via Console da AWS o portal do IAM Identity Center.

- Clicar em ENABLE.
- Create AWS Organization e habilitar IAM Identity Center

- Crie um User
  - Informe a opção que preferir quanto a criar a senha via e-mail ou gerar senha única.
  - Se optou por receber a senha por e-mail, depois acesse o e-mail e siga o processo para configurar a senha.
- Crie um Grupo Admin.
- Atribua o usuário ao grupo Admin.
- Crie uma Permission Set de Administrador.
- Na Aba AWS Accounts, selecione a conta atual e faça o Assign group, do grupo Admin para a permission Admin.


- Na aba Dashboard você encontrará à direita o AWS access portal URL, entre no link. Recomendo deixar esse link nos favoritos, pois é a forma que recomendo você acessar sua conta da AWS.
- Faça o login, e então você terá acesso a um portal de acesso do usuário.

O portal deve ser como esse abaixo:

![IAM Identity Center](./IAM%20Identity%20Center%201.png)

- Para fins do exercício, vamos criar um novo grupo chamado RestrictedAccess e adicionar o mesmo usuário a ele.
- Em permissions set clique em Create permission set -> Custom permission set, não selecione nada -> Dê ao permission set o nome de RestrictedAccess
- Faça o assign da permission RestrictedAccess com o grupo de usuários RestrictedAccess.


- Deve aparecer agora as duas roles para o seu usário nessa conta da AWS. Quando precisar utilizar permissões Admin, utilize o console e as credenciais programáticas de Admin. Quando quiser utilizar outra role, como por exemplo para fim desse exercício, utilize a outra role.

![IAM Identity Center](./IAM%20Identity%20Center%202.png)

## Segunda Parte - Conhecendo as várias formas de comunicar com a aws

Nessa parte vamos interagir na prática com a AWS com algumas formas diferentes, abaixo está um diagrama de como funciona em alto nível a comunicação das diferentes tecnologias com a AWS:

![Diagrama comunicação com a AWS](./Diagrama%20intera%C3%A7%C3%A3o%20com%20a%20AWS.png)

Conhecendo um pouco melhor essas tecnologias:

- [AWS Console](https://console.aws.amazon.com/console)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/)
- [AWS SDKs](https://aws.amazon.com/developer/tools/)
- [AWS Cloudformation](https://aws.amazon.com/cloudformation/)
- [AWS CDK](https://aws.amazon.com/cdk/). [Outro link](https://github.com/aws/aws-cdk).
- [Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)


*[Nesse link do AWS SDK](https://aws.amazon.com/developer/tools/) na verdade possui diversas ferramentas muito úteis para o desenvolvedor trabalhar com a AWS.


**Minha recomendação é, de forma geral, sempre interagir a primeira vez com algum serviço da AWS via console**, e depois então usá-las com outras tecnologias programáticas. E nesse tutorial vamos fazer exatamente isso.

Já usamos o console na verdade para criar os usuários, agora vamos usá-lo para interagir com o Bucket S3.

## Terceira Parte - Interagindo de várias formas com o serviço S3


### Via Console

_Ao mesmo tempo que aplicamos na prática conhecimentos de permissionamento (IAM)_

Via console, entre no serviço do S3 usando a permission set RestrictedAccess que criamos. Clique em Buckets no menu à esquerda. Perceba que você não tem acesso para listar os buckets. Vamos dar acesso e depois voltar.

Para isso volte a acessar, dessa vez com o usuário Admin.

Para ficarmos todos na mesma página, vamos estar usando a região us-east-1 (N. Virginia)

Vamos adicionar permissões IAM para listar buckets s3. Vamos fazer isso via IAM Identity Center.

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"s3:ListAllMyBuckets"
			],
			"Resource": [
				"*"
			]
		}
	]
}
```
Perceba que agora é possível listar os buckets. Vamos criar um bucket agora.

Mais permissões:

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"s3:Get*",
				"s3:List*",
				"s3:Describe*",
				"s3-object-lambda:Get*",
				"s3-object-lambda:List*"
			],
			"Resource": "*"
		}
	]
}
```

Ainda mais permissões:

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"s3:Get*",
				"s3:List*",
				"s3:Describe*",
				"s3-object-lambda:Get*",
				"s3-object-lambda:List*",
				"s3:Put*",
				"s3:Delete*"
			],
			"Resource": "*"
		}
	]
}
```

### Via AWS Cli

Configure a o AWS Cli usando o comando `aws configure sso`.

Para criar um bucket ([Documentação](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html#synopsis)):

```bash
aws s3api create-bucket --bucket bucket_name
```

Para subir um arquivo no S3
```bash
aws s3 cp arquivo-exemplo.json s3://bucket_name
```

Para verificar se o arquivo subiu certinho, podemos listar os arquivos do bucket s3:

```bash
aws s3 ls s3://bucket_name
```

Para deletar arquivo do bucket s3:

```bash
aws s3 rm s3://bucket_name/arquivo-exemplo.json
```

Para deletar o bucket s3:

```bash
aws s3api delete-bucket --bucket="bucket_name"
```

### Via Boto3

Esse código abaixo foi criado usando o chatGPT. Recomendo o seu uso para tirar dúvidas e aprender de uma maneira mais interativa. [_Link para a conversa que gerou o código abaixo_](https://chat.openai.com/share/d1f1c9cf-d537-4492-b18d-4243fcb5d29f).

```python

import boto3

# Configurações
bucket_name = 'seu-nome-de-bucket-unico'
file_to_upload = 'caminho/do/seu/arquivo.txt'

# Inicializa o cliente S3
s3_client = boto3.client('s3')

# Cria o bucket
s3_client.create_bucket(Bucket=bucket_name)

print(f"Bucket {bucket_name} criado.")

# Faz upload do arquivo para o bucket
with open(file_to_upload, 'rb') as file:
    s3_client.upload_fileobj(file, bucket_name, 'arquivo.txt')

print("Arquivo enviado para o bucket.")

# Lista os objetos no bucket
response = s3_client.list_objects(Bucket=bucket_name)
if 'Contents' in response:
    for obj in response['Contents']:
        print(f"Objeto: {obj['Key']}")

# Deleta o arquivo do bucket
s3_client.delete_object(Bucket=bucket_name, Key='arquivo.txt')
print("Arquivo deletado do bucket.")

# Deleta o bucket
s3_client.delete_bucket(Bucket=bucket_name)
print(f"Bucket {bucket_name} deletado.")
```
