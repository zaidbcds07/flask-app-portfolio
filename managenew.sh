#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/home/zaid/flask_app_portfolio"
CONTAINER_NAME="flask-portfolio"
LOCAL_APP_URL="http://127.0.0.1:5004"
HEALTH_URL="http://127.0.0.1:5004/health/"

cd "$APP_DIR"

require_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: docker is not installed."
        exit 1
    fi
}

require_tailscale() {
    if ! command -v tailscale >/dev/null 2>&1; then
        echo "Error: tailscale is not installed."
        exit 1
    fi
}

show_status() {
    echo "=== Docker containers ==="
    docker ps -a --filter "name=${CONTAINER_NAME}" || true
    echo
    echo "=== Tailscale Serve ==="
    tailscale serve status || true
}

wait_for_health() {
    echo "Waiting for app health check..."
    for i in {1..20}; do
        if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
            echo "Health check passed."
            return 0
        fi
        sleep 2
    done

    echo "Health check failed. Showing logs:"
    docker compose logs --tail=100
    exit 1
}

case "${1:-}" in
    start)
        require_docker
        require_tailscale

        echo "Starting Flask Docker app..."
        docker compose up -d --build

        wait_for_health

        echo "Enabling HTTPS via Tailscale..."
        tailscale serve --bg --https=443 "$LOCAL_APP_URL"

        echo "Done."
        show_status
        ;;

    stop)
        require_docker
        require_tailscale

        echo "Stopping Flask Docker app..."
        docker compose down

        echo "Disabling Tailscale HTTPS..."
        tailscale serve --https=443 off || true

        echo "Done."
        show_status
        ;;

    restart)
        require_docker
        require_tailscale

        echo "Restarting Flask Docker app..."
        docker compose down
        docker compose up -d --build

        wait_for_health

        echo "Refreshing Tailscale HTTPS proxy..."
        tailscale serve --bg --https=443 "$LOCAL_APP_URL"

        echo "Done."
        show_status
        ;;

    deploy)
        require_docker
        require_tailscale

        echo "Pulling latest code from Git..."
        git pull --ff-only

        echo "Rebuilding and starting app..."
        docker compose up -d --build

        wait_for_health

        echo "Refreshing Tailscale HTTPS proxy..."
        tailscale serve --bg --https=443 "$LOCAL_APP_URL"

        echo "Done."
        show_status
        ;;

    logs)
        require_docker
        docker compose logs -f
        ;;

    status)
        require_docker
        require_tailscale
        show_status
        ;;

    backup)
        exec "$APP_DIR/backup_db.sh"
        ;;

    *)
        echo "Usage: $0 {start|stop|restart|deploy|logs|status|backup}"
        exit 1
        ;;
esac
