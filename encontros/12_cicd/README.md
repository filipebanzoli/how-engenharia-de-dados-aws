
## Tarefa Prático

- Criar um repositório privado no Github para realizar esse teste.
- Criar um job template CI para o Github Actions
	- https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
	- https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/
	- Criar a role necessária via Terraform
    - Fazer autenticação na AWS via Github Actions
	- Adicionar uma action de sua preferência.
	- Fazer o teste do CI se consegue rodar o Terraform Plan
- Criar um job template CD para o Github Actions
	- Criar a role necessária via Terraform
    - Fazer autenticação na AWS via Github Actions
	- Buildar o projeto no CD do Github Actions (Terraform Apply)
