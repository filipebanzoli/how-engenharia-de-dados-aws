# Informações para entender melhor o terraform


OBS: não esqueça de criar o .env com as credenciais!

### Provedores

1. **AWS**: Este é o provedor da AWS, e você especificou a região como "us-west-2". Também configurou tags padrão.
2. **HTTP**: Este provedor faz uma solicitação HTTP para obter seu endereço IP público.
3. **Random**: Gera senhas aleatórias.
4. **Docker**: Utilizado para lidar com imagens Docker.
5. **Null**: Provedor que permite configurações personalizadas, muitas vezes usadas para depuração ou acionamentos condicionais.

### Blocos `data`

1. **my_public_ip**: Faz uma chamada HTTP para obter seu endereço IP público.
2. **aws_caller_identity**: Obtém informações sobre a identidade do chamador na AWS.
3. **aws_ecr_authorization_token**: Pega o token de autorização para o ECR (Elastic Container Registry).
4. **aws_vpc**: Obtém informações sobre o VPC padrão.
5. **aws_subnets**: Obtém informações sobre todas as sub-redes no VPC especificado.

### Recursos AWS

1. **aws_security_group**: Define um grupo de segurança na AWS.
2. **aws_vpc_security_group_ingress_rule**: Define regras de entrada para os grupos de segurança.
3. **aws_db_instance**: Cria uma instância de banco de dados Postgres na AWS.
4. **aws_iam_role**: Cria uma função IAM com políticas associadas.
5. **aws_security_group**: Outro grupo de segurança para a função Lambda.
6. **aws_vpc_security_group_egress_rule**: Define uma regra de saída para o grupo de segurança da função Lambda.

### Recursos Random

1. **random_password**: Gera senhas aleatórias.

### Recursos Null

1. **null_resource**: Este é mais um gatilho. Ele vai executar o comando especificado no provisionador `local-exec` após a criação do recurso `aws_db_instance`.

### Módulos

1. **docker_image**: Módulo para construir uma imagem Docker e enviá-la para o ECR.
2. **lambda_function**: Módulo para criar uma função Lambda na AWS.

### Locais

O bloco `locals` define variáveis locais que são usadas em várias partes do seu script.

### Curiosidade

Já que você é um entusiasta de aprendizado de máquina e arquitetura de sistemas, você pode achar interessante saber que o Terraform também pode ser usado para criar infraestruturas específicas para aprendizado de máquina, como clusters Kubernetes otimizados para ML ou infraestruturas de data lake para armazenar grandes volumes de dados.

Espero que essa explicação tenha sido útil! Se tiver mais perguntas, fique à vontade para perguntar.