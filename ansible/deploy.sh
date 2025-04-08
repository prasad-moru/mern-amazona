#!/bin/bash
# deploy.sh - Script to run the Ansible deployment

# Set variables
ANSIBLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"
PLAYBOOK_FILE="$ANSIBLE_DIR/playbook.yml"

# Check if inventory file exists
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "Inventory file not found at $INVENTORY_FILE"
    exit 1
fi

# Check if playbook file exists
if [ ! -f "$PLAYBOOK_FILE" ]; then
    echo "Playbook file not found at $PLAYBOOK_FILE"
    exit 1
fi

# Parse command line arguments
DEPLOY_TARGET="all"
CLEAN_DEPLOY=false

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --target)
        DEPLOY_TARGET="$2"
        shift
        shift
        ;;
        --clean)
        CLEAN_DEPLOY=true
        shift
        ;;
        *)
        echo "Unknown option: $1"
        echo "Usage: $0 [--target frontend|backend|all] [--clean]"
        exit 1
        ;;
    esac
done

# Set extra vars
EXTRA_VARS="clean_deploy=$CLEAN_DEPLOY"

# Run the deployment
case $DEPLOY_TARGET in
    frontend)
        echo "Deploying frontend..."
        ansible-playbook -i $INVENTORY_FILE $PLAYBOOK_FILE --limit frontend -e "$EXTRA_VARS"
        ;;
    backend)
        echo "Deploying backend..."
        ansible-playbook -i $INVENTORY_FILE $PLAYBOOK_FILE --limit backend -e "$EXTRA_VARS"
        ;;
    all)
        echo "Deploying all components..."
        ansible-playbook -i $INVENTORY_FILE $PLAYBOOK_FILE -e "$EXTRA_VARS"
        ;;
    *)
        echo "Invalid target: $DEPLOY_TARGET"
        echo "Usage: $0 [--target frontend|backend|all] [--clean]"
        exit 1
        ;;
esac

echo "Deployment completed successfully."