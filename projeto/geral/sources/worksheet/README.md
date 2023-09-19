
## Objetivo

O objetivo dessa etapa do projeto é trazer dados de uma planilha do Google Sheets para o Data Lake no S3.

Estaremos utilizando ferramentas low-code para tal fim, em corroboração com a mentalidade que tenho ensinado "Utilizar ferramentas prontas aonde já existe e criar soluções novas aonde necessitar". 

Caso a sua equipe ainda assim quiser criar um script para trazer dados do Google Sheets para o S3, pode fazer isso. Uma dica seria daí utilizar a orientação a objeto.

Nessa etapa estaremos:
- criando o nosso data lake no S3
- criando um usuário sistêmico para o Airbyte com permissão para inserir dados no S3
- criando uma service account do Google para trazer dados da planilha
- criando uma conta no [Airbyte Cloud](https://airbyte.com/)
- configurando uma integração de dados entre o Google Sheets e o Data Lake em S3.

## Lembrem de deixar organizado os arquivos da sua equipe [dentro da pasta da sua equipe](../../../) e não no geral.


## Recursos/Data Sources/Providers do Terraform a serem utilizados:

[AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

[Bucket S3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

[aws_s3_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

[aws_iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)

[aws_iam_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key)

[aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)

[aws_iam_user_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy)

## Origem do dado

O dataset utilizado para se trabalhar dados de planilha foi esse aqui abaixo:

https://www.kaggle.com/datasets/lissetteg/ecommerce-dataset

Se prefirir, fique à vontade para clonar a minha planilha com os dados:

https://docs.google.com/spreadsheets/d/1eRs2g8yE922D-6K70n_H9ljp2iVD__ZcFSeYr-LEEEI/edit#gid=206208925

## Google Service Account Tutorial

1. Primeiramente, [habilite a IAM API e crie uma Service Role](https://cloud.google.com/iam/docs/service-accounts-create)
2. [Na tela de services accounts](https://console.cloud.google.com/projectselector2/iam-admin/serviceaccounts), selecione o projeto e a service account criada.
3. Agora clique na aba Chaves, agregar nova Chave e seleciona JSON
4. Pronto, agora você já criou uma Service Account e baixou o chave no formato JSON.

## Airbyte
1. [Source](https://docs.airbyte.com/integrations/sources/google-sheets/)
2. [Destination](https://docs.airbyte.com/integrations/destinations/s3/)
