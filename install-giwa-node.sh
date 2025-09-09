set -e  

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

GIWA_REPO="https://github.com/giwa-io/node.git"
GIWA_DIR="giwa-node"
DOCKER_COMPOSE_VERSION="2.20.0"

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

check_requirements() {
    log "Checking system requirements..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        error "This script is designed for Linux VPS. You're running on macOS."
        error "Please run this script on a Linux VPS (Ubuntu, Debian, CentOS, RHEL, or Fedora)."
        exit 1
    fi

    if [[ ! -f /etc/os-release ]]; then
        error "Cannot determine OS version. This script requires a Linux system with /etc/os-release."
        exit 1
    fi

    source /etc/os-release
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" && "$ID" != "centos" && "$ID" != "rhel" && "$ID" != "fedora" ]]; then
        warning "This script is designed for Ubuntu/Debian/CentOS/RHEL/Fedora. Proceeding anyway..."
        warning "OS detected: $ID $VERSION_ID"
    else
        info "OS detected: $PRETTY_NAME"
    fi

    info "Skipping disk space check for testing"

    total_ram=$(free -m | awk 'NR==2{print $2}')
    if [[ $total_ram -lt 8192 ]]; then
        warning "Low RAM detected: ${total_ram}MB. Recommended: 8GB+ for optimal performance"
    fi

    cpu_cores=$(nproc)
    if [[ $cpu_cores -lt 4 ]]; then
        warning "Low CPU cores detected: $cpu_cores. Recommended: 4+ cores"
    fi

    log "System requirements check completed"
}

install_dependencies() {
    log "Installing system dependencies..."

    sudo apt update || sudo yum update -y || sudo dnf update -y

    if command -v apt &> /dev/null; then
        sudo apt install -y curl wget git jq unzip
    elif command -v yum &> /dev/null; then
        sudo yum install -y curl wget git jq unzip
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y curl wget git jq unzip
    else
        error "Package manager not supported. Please install curl, wget, git, jq, and unzip manually."
        exit 1
    fi

    log "System dependencies installed successfully"
}

install_docker() {
    log "Installing Docker..."

    if command -v docker &> /dev/null; then
        info "Docker is already installed"
        docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        info "Docker version: $docker_version"
    else

        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh

        sudo usermod -aG docker $USER

        sudo systemctl start docker
        sudo systemctl enable docker

        log "Docker installed successfully"
    fi
}

install_docker_compose() {
    log "Installing Docker Compose..."

    if command -v docker-compose &> /dev/null; then
        info "Docker Compose is already installed"
        compose_version=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
        info "Docker Compose version: $compose_version"
    else

        sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

        log "Docker Compose installed successfully"
    fi
}

clone_repository() {
    log "Cloning Giwa node repository..."

    if [[ -d "$GIWA_DIR" ]]; then
        warning "Directory $GIWA_DIR already exists. Removing it..."
        rm -rf "$GIWA_DIR"
    fi

    git clone "$GIWA_REPO" "$GIWA_DIR"
    cd "$GIWA_DIR"

    log "Repository cloned successfully"
}

configure_environment() {
    log "Configuring environment..."

    if [[ ! -f ".env.sepolia" ]]; then
        error ".env.sepolia file not found in the repository"
        exit 1
    fi

    echo
    info "=== Network Selection ==="
    echo "Choose your network:"
    echo "1) Mainnet - Coming soon (currently under development)"
    echo "2) Testnet (Sepolia) - Currently supported"
    echo
    
    while true; do
        read -p "Enter your choice (1-2): " network_choice
        case $network_choice in
            1)
                error "Mainnet is not yet available. Please choose Testnet (Sepolia)."
                echo
                ;;
            2)
                info "Selected: Testnet (Sepolia)"
                cp .env.sepolia .env
                break
                ;;
            *)
                error "Invalid choice. Please enter 1 or 2."
                ;;
        esac
    done

    echo
    info "=== L1 RPC Configuration ==="
    echo "You need to provide Ethereum L1 RPC endpoints for the Giwa node to sync."
    echo "You can use services like Infura, Alchemy, or run your own Ethereum node."
    echo
    echo "Popular RPC providers:"
    echo "  • Infura: https://infura.io/"
    echo "  • Alchemy: https://alchemy.com/"
    echo "  • QuickNode: https://quicknode.com/"
    echo "  • Ankr: https://ankr.com/"
    echo

    while true; do
        echo
        read -p "Enter your Ethereum L1 ETH RPC URL: " l1_eth_rpc
        if [[ -n "$l1_eth_rpc" ]]; then

            if [[ "$l1_eth_rpc" =~ ^https?:// ]]; then
                info "✅ ETH RPC URL format looks good"
                break
            else
                warning "⚠️  URL should start with http:// or https://"
                read -p "Do you want to continue anyway? (y/N): " continue_choice
                if [[ "$continue_choice" =~ ^[Yy]$ ]]; then
                    break
                fi
            fi
        else
            error "L1 ETH RPC URL cannot be empty"
        fi
    done

    while true; do
        echo
        read -p "Enter your Ethereum L1 Beacon RPC URL: " l1_beacon_rpc
        if [[ -n "$l1_beacon_rpc" ]]; then

            if [[ "$l1_beacon_rpc" =~ ^https?:// ]]; then
                info "✅ Beacon RPC URL format looks good"
                break
            else
                warning "⚠️  URL should start with http:// or https://"
                read -p "Do you want to continue anyway? (y/N): " continue_choice
                if [[ "$continue_choice" =~ ^[Yy]$ ]]; then
                    break
                fi
            fi
        else
            error "L1 Beacon RPC URL cannot be empty"
        fi
    done

    echo
    info "=== Configuration Summary ==="
    echo "ETH RPC: $l1_eth_rpc"
    echo "Beacon RPC: $l1_beacon_rpc"
    echo
    read -p "Is this configuration correct? (Y/n): " confirm_config
    if [[ "$confirm_config" =~ ^[Nn]$ ]]; then
        info "Restarting configuration..."
        configure_environment
        return
    fi

    sed -i "s|OP_NODE_L1_ETH_RPC=.*|OP_NODE_L1_ETH_RPC=$l1_eth_rpc|" .env
    sed -i "s|OP_NODE_L1_BEACON=.*|OP_NODE_L1_BEACON=$l1_beacon_rpc|" .env

    echo
    info "=== Sync Strategy Configuration ==="
    echo "Choose your sync strategy:"
    echo "1) Snap Sync - Fast & Practical (Recommended for most users)"
    echo "2) Archive Sync - Full History (Requires more disk space)"
    echo "3) Consensus-Driven Sync - Trust-Minimized"
    echo

    while true; do
        read -p "Enter your choice (1-3): " sync_choice
        case $sync_choice in
            1)
                info "Selected: Snap Sync"

                sed -i 's/# SNAP_SYNC_ENABLED=.*/SNAP_SYNC_ENABLED=true/' .env
                break
                ;;
            2)
                info "Selected: Archive Sync"

                sed -i 's/# ARCHIVE_SYNC_ENABLED=.*/ARCHIVE_SYNC_ENABLED=true/' .env
                break
                ;;
            3)
                info "Selected: Consensus-Driven Sync"

                sed -i 's/# CONSENSUS_SYNC_ENABLED=.*/CONSENSUS_SYNC_ENABLED=true/' .env
                break
                ;;
            *)
                error "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done

    log "Environment configured successfully"
}

start_node() {
    log "Building and starting Giwa node..."

    export NETWORK_ENV=".env"

    log "Building Docker containers..."
    docker-compose build --parallel

    log "Starting Giwa node services..."
    docker-compose up -d

    sleep 10

    if docker-compose ps | grep -q "Up"; then
        log "Giwa node started successfully!"
    else
        error "Failed to start Giwa node. Check logs with: docker-compose logs"
        exit 1
    fi
}

show_status() {
    echo
    log "=== Installation Complete! ==="
    echo
    info "Your Giwa node is now running. Here are some useful commands:"
    echo
    echo "Check node status:"
    echo "  docker-compose ps"
    echo
    echo "View logs:"
    echo "  docker-compose logs -f giwa-el    # Execution layer logs"
    echo "  docker-compose logs -f giwa-cl    # Consensus layer logs"
    echo "  docker-compose logs -f            # All logs"
    echo
    echo "Stop the node:"
    echo "  docker-compose down"
    echo
    echo "Restart the node:"
    echo "  docker-compose restart"
    echo
    echo "Update the node:"
    echo "  git pull && docker-compose build --parallel && docker-compose up -d"
    echo
    echo "Clean up (removes all data):"
    echo "  docker-compose down -v && rm -rf ./execution_data"
    echo
    info "Node directory: $(pwd)"
    info "Configuration file: $(pwd)/.env"
    echo
    warning "Important: You may need to log out and back in for Docker group changes to take effect."
    echo
}

main() {
    echo
    log "=== Giwa Node One-Click Installer ==="
    log "Repository: $GIWA_REPO"
    echo

    read -p "Do you want to proceed with the installation? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        info "Installation cancelled."
        exit 0
    fi

    check_root
    check_requirements
    install_dependencies
    install_docker
    install_docker_compose
    clone_repository
    configure_environment
    start_node
    show_status

    log "Installation completed successfully!"
}

main "$@"