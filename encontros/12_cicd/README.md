
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


A Sintaxe Github Actions Workflow:
- https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsworking-directory

O que vem na Imagem `ubuntu-latest` do Github Actions:

- https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2204-Readme.md

### Exemplo de IAM Role para realizar ações na AWS:

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

[Clique aqui para mais informações](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)

[Clique aqui para entender mais sobre o OpenID Connect (OIDC)](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
