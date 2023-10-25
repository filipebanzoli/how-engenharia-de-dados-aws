## 11º encontro - Transformação de dados com dbt

No encontro de hoje pretendemos abordar de forma abrangente a ferramenta que se tornou a número 1 de processamento (transformação) de dados na modern data stack, o [dbt](https://www.getdbt.com/).

**Para mais informações sobre o dbt, acesse: [O que é o dbt?](https://www.getdbt.com/product/what-is-dbt)**

Para a instalação, recomendo que utilize um ambiente Python 3.8 ou superior, instalando as duas bibliotecas, o [dbt-core](https://pypi.org/project/dbt-core/) e o adaptador [dbt-postgres](https://pypi.org/project/dbt-postgres/), conforme descrito no [requirements.txt](./exemplo_pratico/requirements.txt). Para mais informações, ou em caso de dúvida, consulte [o manual de instalação oficial do dbt](https://docs.getdbt.com/docs/core/installation).

## configuração de acesso pelo dbt

Existe algumas formas de se configurar credenciais de conexão com o banco no dbt. A forma local mais recomendada é modificando o arquivo `~/.dbt/profiles.yml`


### dbt seed

Para começar, iremos utilizar o [dbt Seed](https://docs.getdbt.com/docs/build/seeds), que é uma maneira simplificada de se inserir tabelas no banco de dados, utilizando como base arquivos de texto.

### dbt source

Nesse momento, recomendo o cadastramento dos sources do dbt num arquivo de configuração `.yml` ou `.yaml`. Um exemplo seria chamar `sources.yml`. Para mais informações, consulte [declaring a source](https://docs.getdbt.com/docs/build/sources#declaring-a-source).


### dbt models

Com o dado no banco de dados, e o source cadastrado, já é possível criar seu primeiro modelo do dbt, o qual pode ser feito em SQL e Python, no caso do Postgres precisa ser feito em SQL. Para mais informações [consulte a documentação do dbt](https://docs.getdbt.com/docs/build/sql-models).

Perceba que ao criar um modelo do dbt você utilizará jinja como a função [source](https://docs.getdbt.com/reference/dbt-jinja-functions/source), [config](https://docs.getdbt.com/reference/dbt-jinja-functions/config) e [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref), a qual é considerada a função mais importante do dbt.

### materialized

O dbt suporta algumas formas de materialização da tabela no banco de dados, por padrão 5 materializações:

- Table
- View
- Incremental
- Materialized View
- Ephemeral (não materializa a tabela no banco, só cria a lógica)

Para [mais informações sobre cada tipo de materialização](https://docs.getdbt.com/docs/build/materializations), consulte a documentação do dbt.

### dbt test

Outra funcionalidade muito importante do dbt é a inserção de testes, seja de source ou de models. Agora que você já criou modelos, crie seus primeiros testes. [Segue aqui](https://docs.getdbt.com/docs/build/tests) a documentação informando como fazer isso.


### table descriptions

Governança de dados é um assunto fundamental na área de dados e de crescente importância à medida que aumenta o volume de dados e também a busca de geração de valor a partir deles. Outra questão que aumenta essa importância são as leis de proteção de dados, que exigem as empresas a terem um claro mapeamento de dados.

Nesse sentido, inserir descrição em tabelas e definir owner das tabelas se torna algo fundamental nesse processo. O dbt fornece suporte para inserir [descrição nas tabelas](https://docs.getdbt.com/reference/resource-properties/description), [metadados](https://docs.getdbt.com/reference/resource-configs/meta), etc.

### dbt docs

O dbt fornece um catálogo de dados builtin na ferramenta, [acesse aqui](https://docs.getdbt.com/docs/collaborate/documentation) para mais informações. Inclusive existe uma nova ferramenta exclusiva para o uso com o dbt cloud, que é o [dbt explorer](https://docs.getdbt.com/docs/collaborate/explore-projects).

### dbt manifest

Uma peça fundamental na arquitetura do dbt é o `manifest.json`. Esse é um de alguns artefatos do dbt gerados, o qual possui informações valiosas do dbt, os quais podem ser utilizados para facilitar automações futuras, como por exemplo [automatizar a execução dos modelos usando o Airflow](https://www.astronomer.io/blog/airflow-dbt-1/). Para mais informações sobre o manifest, [clique aqui](https://docs.getdbt.com/reference/artifacts/manifest-json).

### dbt compile

Para gerar o `manifest.json` é necessário rodar ao menos um comando `dbt compile`.

### dbt jinja

Jinja é uma [linguagem de template baseada em Python](https://jinja.palletsprojects.com/en/3.1.x/), e ela usada para compilar os modelos do dbt. Usando isso é possível gerar automações de código, lógicas customizadas (como [macros](https://docs.getdbt.com/docs/build/jinja-macros)), etc!


### dbt snapshot

Outra funcionalidade do dbt é o snapshot, uma funcionalidade que permite trackear mudanças em um source ou modelo. Segue aqui a documentação desta [funcionalidade](https://docs.getdbt.com/docs/build/snapshots).

## dbt --debug

Uma funcionalidade muito bacana do dbt é o modo debug que ele disponibiliza, por onde conseguimos ver exatamente quais comandos o dbt está executando no banco. Para acessar isso basta

# Hora de praticar!

Check list de exercícios:

- Subir um banco de dados postgres [baseado nesse docker-compose](./postgres/docker-compose.yml).
- Criar um usuário para uso do dbt.
- Criar schema bronze, silver e gold para uso do dbt.
- Fazer upload dos dados na camada bronze usando o dbt seed.
- Criar uma camada silver que faça a deduplicação do dado das tabelas.
	- Sobre o que são as camadas do datalake: https://www.databricks.com/glossary/medallion-architecture
	- Criar modelo na camada silver usando tanto a materialização incremental quanto tabela.
- Criar descrição das tabelas no dbt
- Criar tabelas com o dbt run
- Criar testes do dbt
- Rodar os testes com o comando dbt test
- Criar snapshots do dado
- Rodar tabela do snapshot no banco de dados.
