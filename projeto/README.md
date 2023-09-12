
# O Projeto

O projeto de cada equipe está organizado em sua determinado diretório, [equipe_a](./equipe_a/), [equipe_b](./equipe_b/), [equipe_c](./equipe_c/) e [equipe_d](./equipe_d/). Também existe o diretório [geral](./geral/), aonde serão compartilhados recursos gerais utilizados até o momento no bootcamp, enquanto ainda não havíamos separado as equipes.

Começando do fundamento, criação da infraestrutura, estaremos utilizando daqui em diante o [Terraform](https://www.terraform.io/) para esse fim.

Cada equipe deve criar seu projeto e arquitetura baseando-se na arquitetura geral, extendendo-a incluindo a tarefa determinada em cada encontro. Perceba que haverá tarefas obrigatórios, tarefas sugeridas e além disso a equipe terá liberdade de expandir seu projeto da forma que achar melhor.

Visando a otimização de custos, solicito a criação de uma arquitetura efêmera, ou seja, que consiga ser criada e deletada cada vez que formos trabalhar com o projeto. (sem deixar no lifecycle do recurso do terraform alguma trava para deletar o recurso).

Até o momento as tecnologias utilizadas no projeto são:

[Terraform])(https://developer.hashicorp.com/terraform/downloads?product_intent=terraform)
[AWS Cli](https://aws.amazon.com/cli/) (deixe configurado com uma permissão padrão que consiga provisionar os recursos).
[PSQL](https://www.postgresql.org/docs/current/app-psql.html) (para criação de recursos no banco de dados postgres).
[Docker](https://www.docker.com/products/docker-desktop/) (para criação de containers docker)

Após instalado e configurado essas tecnologias, para provisionar a infraestrutura basta executar os comandos tradicionais do terraform para planejar, criar e no final dos seus estudos diários, destruir a arquitetura. No diretório [geral](./geral/), executar:

Para planejar os recursos a serem criados:

`terraform plan`

Para criar os recursos:

`terraform apply`

Para destruir os recursos:

`terraform destroy`


