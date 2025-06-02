#!/bin/bash

# Script para deploy da infraestrutura Tatakai MVP via CloudFormation

# Variáveis (ajuste conforme necessário)
STACK_NAME="tatakai-mvp-stack-dev" # Nome da stack CloudFormation (sugestão: incluir ambiente)
TEMPLATE_FILE="main.yaml" # Caminho para o template principal
PARAMS_FILE="parameters.json" # Caminho para o arquivo de parâmetros
AWS_REGION="us-east-1" # Região AWS onde a stack será criada (ajuste se necessário)

# Verificar se AWS CLI está instalado
if ! command -v aws &> /dev/null
then
    echo "AWS CLI não encontrado. Por favor, instale-o e configure-o antes de continuar."
    echo "Instruções: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Verificar se AWS CLI está configurado
aws sts get-caller-identity > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "AWS CLI não está configurado. Execute 'aws configure' para configurar suas credenciais."
    exit 1
fi

echo "Iniciando deploy da stack CloudFormation: $STACK_NAME na região $AWS_REGION..."

# Verifica se a stack está em ROLLBACK_COMPLETE e a deleta automaticamente
STACK_STATUS=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $AWS_REGION \
  --query "Stacks[0].StackStatus" \
  --output text 2>/dev/null)

if [ "$STACK_STATUS" == "ROLLBACK_COMPLETE" ]; then
  echo "A stack $STACK_NAME está em estado ROLLBACK_COMPLETE. Excluindo antes de recriar..."
  aws cloudformation delete-stack --stack-name $STACK_NAME --region $AWS_REGION
  echo "Aguardando exclusão completa da stack..."
  aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $AWS_REGION
  echo "Stack excluída com sucesso. Continuando com o deploy..."
fi

# Comando de deploy
aws cloudformation deploy \
  --template-file $TEMPLATE_FILE \
  --stack-name $STACK_NAME \
  --parameter-overrides ProjectName=TatakaiProject Environment=Dev \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --region $AWS_REGION

# Verificar status do deploy
if [ $? -eq 0 ]; then
  echo "Deploy iniciado com sucesso. Acompanhe o progresso no console AWS CloudFormation."
  echo "Stack Name: $STACK_NAME"
  echo "Região: $AWS_REGION"
else
  echo "Erro ao iniciar o deploy da stack. Verificando eventos de falha..."
  aws cloudformation describe-stack-events --stack-name $STACK_NAME --region $AWS_REGION \
    --query "StackEvents[?ResourceStatus=='CREATE_FAILED'].[LogicalResourceId,ResourceStatusReason]" \
    --output table
  exit 1
fi

# Opcional: Aguardar a conclusão da stack (pode demorar)
# echo "Aguardando a conclusão da criação/atualização da stack..."
# aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $AWS_REGION
# aws cloudformation wait stack-update-complete --stack-name $STACK_NAME --region $AWS_REGION
# echo "Stack $STACK_NAME criada/atualizada com sucesso!"

# Opcional: Exibir outputs da stack
# echo "Outputs da Stack:"
# aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs" --output table --region $AWS_REGION

exit 0

