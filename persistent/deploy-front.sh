#!/bin/bash

# Configurações iniciais
REPO_DIR="/home/ubuntu/app/persistent-front"   # Caminho do repositório local
DEPLOY_BRANCH="main"            # Branch principal de produção
TEMP_BRANCH="deploy"
DOCKER_COMPOSE_FILE="docker-compose.yml"
SERVICE_NAME="persistent-front-app-1"     # Nome do serviço Docker

# Função de rollback
rollback() {
  echo ">> Erro detectado. Revertendo para a branch $DEPLOY_BRANCH..."
  git checkout $TEMP_BRANCH
  git checkout -b rollback
  docker compose down
  docker compose up -d --build --force-recreate
  echo ">> Rollback concluído!"
  exit 1
}

# Passo 1: Entrar no repositório
cd $REPO_DIR || { echo "Erro: Não foi possível acessar o repositório."; exit 1; }

# Passo 2: Criar branch temporária
git checkout -b $TEMP_BRANCH || { echo "Erro: Não foi possível criar a branch $TEMP_BRANCH."; exit 1; }

# Passo 3: Atualizar branch principal
git checkout $DEPLOY_BRANCH || { echo "Erro: Não foi possível trocar para a branch $DEPLOY_BRANCH."; exit 1; }
git pull || { echo "Erro: Não foi possível atualizar a branch $DEPLOY_BRANCH."; exit 1; }

# Passo 4: Construir e subir containers Docker
echo ">> Construindo e iniciando os containers..."
if ! docker compose up -d --build --force-recreate; then
  rollback
fi

# Passo 5: Verificar se o serviço está rodando
if ! docker ps | grep -q "$SERVICE_NAME"; then
  rollback
fi

# Passo 6: Mesclar alterações e limpar branch temporária
git branch -D $TEMP_BRANCH 2>/dev/null

echo ">> Deploy concluído com sucesso!"
exit 0
