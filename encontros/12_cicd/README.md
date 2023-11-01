
## Tarefa Prático

- Criar um repositório privado no Github para realizar esse teste.
- Criar um job template CI para o Github Actions
	- Criar a role necessária via Terraform
    - Fazer autenticação na AWS via Github Actions
	- Adicionar uma action de sua preferência.
	- Fazer o teste do CI se consegue rodar o Terraform Plan
- Criar um job template CD para o Github Actions
	- Criar a role necessária via Terraform
    - Fazer autenticação na AWS via Github Actions
	- Buildar o projeto no CD do Github Actions (Terraform Apply)


## Recursos úteis

### Entendendo o CI/CD


Ilustração de CI/CD:

![Fluxo CI/CD](https://www.synopsys.com/glossary/what-is-cicd/_jcr_content/root/synopsyscontainer/column_1946395452_co/colRight/image_copy.coreimg.svg/1663683682045/cicd.svg)

![Fluxo CI/CD](https://i.ytimg.com/vi/42UP1fxi2SY/maxresdefault.jpg)

Vídeo CI/CD: [https://www.youtube.com/watch?v=42UP1fxi2SY](https://www.youtube.com/watch?v=42UP1fxi2SY)


Sobre o Github Actions:
https://github.com/features/actions

Exemplos de Github Actions (marketplace):
https://github.com/marketplace?type=actions


A Sintaxe Github Actions Workflow:
- https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsworking-directory

O que vem na Imagem `ubuntu-latest` do Github Actions:

- https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2204-Readme.md

### Exemplo de IAM Role para realizar ações na AWS:

PS: Lembrem de substituir o `repo` pelo repositório de vocês ali em `repo:filipebanzoli/how-engenharia-de-dados-aws-private:*`.

```
resource "aws_iam_role" "cd_github_actions_role" {
  name = "cd_github_actions_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = ["repo:filipebanzoli/how-engenharia-de-dados-aws-private:*"]
          }
        }
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

data "aws_caller_identity" "current" {}
```


### Autenticação AWS via Github Actions


[Clique aqui para mais informações](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/), **nesse link você tem informações para começar a construir seu workflow CI e CD também!**.

[Clique aqui para entender mais sobre o OpenID Connect (OIDC)](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)

### Para utilizar o backend do Terraform no S3:

PS: Subsitituir `187671957427` pelo ID da conta AWS de vocês:

```
resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-backend-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "terraform_backend" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-187671957427"
    key    = "state.tfstate"
    region = "us-east-1"
  }
}
```

### Para Instalar e usar comandos do Terraform dentro do Workflow CI e CD, pode-se fazer:

```
- name: Installing terraform
  uses: hashicorp/setup-terraform@v2

- name: Terraform Init
  run: terraform init
  working-directory: ./projeto/equipe_x

- name: Terraform Plan
  run: terraform plan -no-color
  working-directory: ./projeto/equipe_x
```

### Exemplo de Workflow do Github Actions:

[Clique aqui para acessar o excelente exemplo](https://docs.github.com/en/actions/examples/using-scripts-to-test-your-code-on-a-runner).
