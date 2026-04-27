#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/home/zaid/flask_app_portfolio"
CONTAINER_NAME="flask-portfolio"

cd "$APP_DIR"

case "${1:-}" in
    start)
    echo "🚀 Starting Flask Docker app..."

    docker compose up -d --build

    echo "🔐 Enabling HTTPS via Tailscale..."
    tailscale serve --bg --https=443 http://127.0.0.1:5004

    tailscale serve status
    ;;

    stop)
    echo "🛑 Stopping Flask Docker app..."

    docker compose down

    echo "🔐 Disabling Tailscale HTTPS..."
    tailscale serve --https=443 off

    ;;

    restart)
        echo "🔄 Restarting Flask Docker app..."

        docker compose down
        docker compose up -d --build

        echo "✅ App restarted"
        ;;

    logs)
        echo "📜 Showing logs..."
        docker compose logs -f
        ;;

    status)
        echo "📊 Container status:"
        docker ps -a | grep "$CONTAINER_NAME" || echo "Container not found"
        ;;

    *)
        echo "Usage: $0 {start|stop|restart|logs|status}"
        exit 1
        ;;
esac
