# Tatakai MVP - Infraestrutura AWS via CloudFormation

Este diretório contém os arquivos necessários para implantar a infraestrutura inicial do projeto Tatakai MVP na AWS usando CloudFormation. A infraestrutura é projetada para utilizar exclusivamente serviços gratuitos ou no Free Tier da AWS.

## Arquivos

- `main.yaml`: Template CloudFormation principal que define todos os recursos AWS.
- `parameters.json`: Arquivo para definir parâmetros personalizáveis do template (nome do projeto, ambiente).
- `deploy.sh`: Script Bash para facilitar a implantação da stack CloudFormation.
- `README.md`: Este arquivo, com instruções detalhadas.

## Pré-requisitos

Antes de começar, você precisará de:

1.  **Conta AWS**: Se você ainda não tem uma, crie uma conta gratuita em [aws.amazon.com](https://aws.amazon.com/).
2.  **AWS Command Line Interface (CLI)**: Uma ferramenta para interagir com a AWS pelo terminal.
    - **Instalação**: Siga as instruções oficiais para o seu sistema operacional: [Instalar AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    - **Configuração**: Após instalar, configure o CLI com suas credenciais AWS. Execute o comando `aws configure` no seu terminal e siga as instruções. Você precisará do seu `AWS Access Key ID` e `AWS Secret Access Key`. Você pode criá-los no console da AWS em "IAM" > "Users" > "Seu Usuário" > "Security credentials". Escolha uma região padrão (ex: `us-east-1`).

    ```bash
    aws configure
    AWS Access Key ID [None]: SEU_ACCESS_KEY_ID
    AWS Secret Access Key [None]: SEU_SECRET_ACCESS_KEY
    Default region name [None]: us-east-1  # Ou sua região preferida
    Default output format [None]: json
    ```

3.  **Git**: Para clonar o repositório do projeto.

## Passo a Passo para Implantação

### 1. Clonar o Repositório

Se você ainda não clonou o repositório TatakaiProject, faça isso:

```bash
git clone https://github.com/adenildosousa/TatakaiProject.git
cd TatakaiProject
```

### 2. Navegar até o Diretório

Acesse a pasta que contém os scripts do CloudFormation:

```bash
cd ScriptsCloudFormation
```

### 3. Revisar e Personalizar Parâmetros (Opcional)

Abra o arquivo `parameters.json`. Por padrão, ele está configurado para:

- `ProjectName`: "TatakaiProject"
- `Environment`: "Dev"

Se desejar, você pode alterar o valor de `Environment` para "Staging" ou "Prod" se estiver criando outros ambientes, mas para o início, "Dev" é recomendado.

### 4. Tornar o Script de Deploy Executável

No Linux ou macOS, você pode precisar dar permissão de execução ao script:

```bash
chmod +x deploy.sh
```

### 5. Executar o Script de Deploy

Execute o script `deploy.sh` a partir do diretório `ScriptsCloudFormation`:

```bash
./deploy.sh
```

O script fará o seguinte:

- Verificará se o AWS CLI está instalado e configurado.
- Iniciará a criação ou atualização da stack CloudFormation chamada `tatakai-mvp-stack-dev` (ou o nome definido em `STACK_NAME` no script) na região definida (padrão `us-east-1`).
- Usará o template `main.yaml` e os parâmetros de `parameters.json`.
- Solicitará as permissões necessárias (CAPABILITY_IAM) para criar recursos como Roles do IAM.

### 6. Monitorar a Criação da Stack

A criação da infraestrutura pode levar alguns minutos (5 a 15 minutos, dependendo dos recursos).

- **Pelo Terminal**: O script informará que o deploy foi iniciado.
- **Pelo Console AWS**:
    1. Faça login no [Console da AWS](https://aws.amazon.com/console/).
    2. Navegue até o serviço **CloudFormation**.
    3. Selecione a região correta (a mesma usada no `deploy.sh`, padrão `us-east-1`).
    4. Você verá a stack `tatakai-mvp-stack-dev` com o status `CREATE_IN_PROGRESS`.
    5. Clique no nome da stack e vá para a aba "Events" para ver os detalhes da criação de cada recurso.
    6. Aguarde até que o status mude para `CREATE_COMPLETE`.

### 7. Verificar os Recursos Criados e Outputs

Após a conclusão (`CREATE_COMPLETE`), você pode verificar os recursos criados:

- **Cognito**: User Pools
- **S3**: Buckets (`tatakai-frontend`, `tatakai-media` com sufixos)
- **DynamoDB**: Tables (`TatakaiUsers-Dev`, `TatakaiProfiles-Dev`, etc.)
- **Lambda**: Functions (`tatakai-auth-Dev`, `tatakai-profile-Dev`)
- **API Gateway**: APIs (`TatakaiProject-API-Dev`)
- **CloudFront**: Distributions

Os **Outputs** da stack contêm informações importantes, como:

- `UserPoolId` e `UserPoolClientId`: Para configurar a autenticação no frontend.
- `FrontendBucketName` e `MediaBucketName`: Nomes dos buckets S3.
- `ApiGatewayUrl`: O endpoint principal da sua API.
- `CloudFrontDomainName`: O domínio para acessar seu frontend.

Você pode ver os Outputs na aba "Outputs" da sua stack no console CloudFormation ou descomentando as últimas linhas do script `deploy.sh` e executando-o novamente após a criação.

## Próximos Passos Após o Deploy

Com a infraestrutura básica criada, os próximos passos envolvem:

1.  **Configurar o Frontend**: Atualizar as configurações do seu aplicativo React com os IDs do Cognito, URL da API Gateway, etc.
2.  **Desenvolver as Funções Lambda**: Substituir o código placeholder nas funções Lambda pela lógica real da aplicação.
3.  **Configurar Domínio Personalizado (Opcional)**: Associar seu domínio `TatakaiProject` ao CloudFront.
4.  **Configurar Acesso Privado ao S3 (Opcional)**: Configurar Origin Access Identity (OAI) no CloudFront para que o bucket S3 do frontend não precise ser público.

## Solução de Problemas

- **Falha na Criação (ROLLBACK_COMPLETE)**: Verifique a aba "Events" da stack no console CloudFormation para identificar o erro específico. Corrija o template ou os parâmetros e execute o `deploy.sh` novamente.
- **Erro de Permissão**: Certifique-se de que suas credenciais AWS configuradas no CLI têm permissão para criar todos os recursos definidos no template.
- **Nome de Bucket S3 já existe**: Os nomes de bucket S3 precisam ser globalmente únicos. O template tenta criar nomes únicos usando o ID da conta, mas se ainda assim houver conflito, ajuste os nomes `BucketName` no `main.yaml`.

## Excluindo a Infraestrutura

Se precisar remover toda a infraestrutura criada:

1.  **Esvaziar Buckets S3**: Antes de excluir a stack, você precisa esvaziar manualmente os buckets S3 (`tatakai-frontend` e `tatakai-media`) criados por ela.
2.  **Excluir a Stack**: Vá ao console CloudFormation, selecione a stack `tatakai-mvp-stack-dev` e clique em "Delete". Isso removerá todos os recursos criados pelo template.

    Alternativamente, use o comando AWS CLI:
    ```bash
    aws cloudformation delete-stack --stack-name tatakai-mvp-stack-dev --region us-east-1
    ```

