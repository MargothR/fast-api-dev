#!/bin/bash
set -e

PROJECT_DIR="$HOME/app"
STATE_FILE="$PROJECT_DIR/current_deploy.env"

echo "==> Desplegando color: $TARGET_COLOR en puerto $ACTIVE_PORT"

export IMAGE_NAME=$(echo $IMAGE_NAME | tr '[:upper:]' '[:lower:]')
export IMAGE_TAG=$IMAGE_TAG

docker pull ghcr.io/${IMAGE_NAME}:${IMAGE_TAG}

cd $PROJECT_DIR

docker-compose -f docker-compose.${TARGET_COLOR}.yml up -d --force-recreate

echo "==> Esperando que el servicio responda..."
for i in {1..15}; do
    if curl -sf http://localhost:${ACTIVE_PORT}/health > /dev/null; then
        echo "==> Servicio listo!"
        break
    fi
    sleep 2
done

export ACTIVE_PORT=$ACTIVE_PORT
envsubst '${ACTIVE_PORT}' < /etc/nginx/templates/nginx.template.conf \
    | sudo tee /etc/nginx/sites-available/default > /dev/null

sudo nginx -t && sudo systemctl reload nginx

echo "CURRENT_COLOR=${TARGET_COLOR}" > $STATE_FILE
echo "==> Estado guardado: $TARGET_COLOR es ahora PRODUCTIVO"

OLD_COLOR=$( [ "$TARGET_COLOR" = "blue" ] && echo "green" || echo "blue" )
docker-compose -f docker-compose.${OLD_COLOR}.yml down || true

echo "==> Pipeline Blue-Green completado!"