## Sobre tipos de replicação.

A atualização incremental de mudanças feitas num banco de dados pode ser feita por meio de queries incrementais (por exemplo baseado em data ou id da tabela), ou baseado na captura dos eventos que acontecem no banco de dados (INSERT, DELETE, UPDATE). No banco de dados Mysql se fala para isso no Binary Log, e no banco de dados Postgres se fala no Logical Replication.

[Aqui existe um excelente artigo](https://datacater.io/blog/2021-09-02/postgresql-cdc-complete-guide.html) que informa as formas de se fazer CDC num banco de dados Postgres, no artigo ele cita 3, via triggers, via queries ou via logical replication. [Outro link, da documentação oficial](https://www.postgresql.org/docs/current/logical-replication-quick-setup.html),   referenciando configuração de Logical Replication.

Como dito no artigo, perceba que a logical replication é, de fato, apenas um log em disco, que armazena todos os eventos que alteram o banco de dados, como INSERT, UPDATE e DELETE.

Para um maior entendimento do que acontece por baixo dos panos, confira a parte "Under the Hood" [do artigo do Crunchy Data](https://www.crunchydata.com/blog/data-to-go-postgres-logical-replication).


## Vendo na prática a replicação, utilizando dessa vez um output plugin para o logical decoding.

[- Sobre a forma de decodificar o WAL (Write-Ahead Log) binário](https://stackoverflow.com/a/55829005)
[- A biblioteca do brasileiro que printa o output do logical decoding](https://github.com/eulerto/wal2json), inclusive essa biblioteca é usada na [imagem postgres de exemplo da biblioteca do Debezium](https://hub.docker.com/r/debezium/postgres), [veja aqui o Docker File da imagem](https://github.com/debezium/container-images/blob/023a7da62f802051b15e3991e2a28f8d705e8d40/postgres/14/Dockerfile).


Para subir a arquitetura:
`docker compose up`

Alterar no arquivo pg_hba.conf:
`local   replication     all                                     trust`

(reiniciar database)

Para iniciar um terminal, executar:
`docker exec -it local_debezium_postgres_replication-db-1 /bin/bash`

Comandos a serem executados em um terminal:

```bash
pg_recvlogical -d postgres --slot test_slot --create-slot -U postgres -W -P wal2json
pg_recvlogical -d postgres --slot test_slot -U postgres -W --start -o pretty-print=1 -f -
```

Comandos a serem executados em outro terminal:

```bash
psql -U postgres -W -At -f /tmp/example1.sql postgres
```

Fique à vontade para criar tabelas usando um cliente SQL e verificar o funcionamento do plugin também.

