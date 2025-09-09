set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

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

VALIDATION_PASSED=true

check_os() {
    log "Checking operating system..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        error "❌ macOS detected. This installer is designed for Linux VPS only."
        error "Please run this on a Linux VPS (Ubuntu, Debian, CentOS, RHEL, or Fedora)."
        VALIDATION_PASSED=false
        return
    fi

    if [[ ! -f /etc/os-release ]]; then
        error "❌ Cannot determine OS version. /etc/os-release not found."
        VALIDATION_PASSED=false
        return
    fi

    source /etc/os-release
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" || "$ID" == "centos" || "$ID" == "rhel" || "$ID" == "fedora" ]]; then
        info "✅ OS supported: $PRETTY_NAME"
    else
        warning "⚠️  OS not officially supported: $ID $VERSION_ID"
        warning "The installer may still work, but it's not tested on this OS."
    fi
}

check_root() {
    log "Checking user privileges..."

    if [[ $EUID -eq 0 ]]; then
        error "❌ Running as root. The installer should be run as a regular user with sudo privileges."
        VALIDATION_PASSED=false
    else
        info "✅ Running as regular user"

        if sudo -n true 2>/dev/null; then
            info "✅ Sudo access confirmed"
        else
            warning "⚠️  Sudo access not confirmed. You may need to enter your password during installation."
        fi
    fi
}

check_resources() {
    log "Checking system resources..."

    cpu_cores=$(nproc)
    if [[ $cpu_cores -ge 4 ]]; then
        info "✅ CPU cores: $cpu_cores (minimum: 4)"
    else
        warning "⚠️  CPU cores: $cpu_cores (minimum: 4, recommended: 8+)"
    fi

    total_ram=$(free -m | awk 'NR==2{print $2}')
    if [[ $total_ram -ge 8192 ]]; then
        info "✅ RAM: ${total_ram}MB (minimum: 8GB)"
    else
        warning "⚠️  RAM: ${total_ram}MB (minimum: 8GB, recommended: 16GB+)"
    fi

    available_space=$(df / | awk 'NR==2 {print $4}')
    available_gb=$((available_space / 1024 / 1024))
    if [[ $available_space -ge 524288000 ]]; then  
        info "✅ Disk space: ${available_gb}GB available (minimum: 500GB)"
    else
        error "❌ Disk space: ${available_gb}GB available (minimum: 500GB required)"
        VALIDATION_PASSED=false
    fi
}

check_network() {
    log "Checking network connectivity..."

    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        info "✅ Internet connectivity confirmed"
    else
        error "❌ No internet connectivity detected"
        VALIDATION_PASSED=false
    fi

    if curl -s --connect-timeout 10 https://github.com >/dev/null; then
        info "✅ GitHub access confirmed"
    else
        warning "⚠️  Cannot reach GitHub. This may affect repository cloning."
    fi

    if curl -s --connect-timeout 10 https://hub.docker.com >/dev/null; then
        info "✅ Docker Hub access confirmed"
    else
        warning "⚠️  Cannot reach Docker Hub. This may affect Docker image downloads."
    fi
}

check_existing() {
    log "Checking for existing installations..."

    if command -v docker &> /dev/null; then
        docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        info "✅ Docker already installed: $docker_version"
    else
        info "ℹ️  Docker not installed (will be installed by the script)"
    fi

    if command -v docker-compose &> /dev/null; then
        compose_version=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
        info "✅ Docker Compose already installed: $compose_version"
    else
        info "ℹ️  Docker Compose not installed (will be installed by the script)"
    fi

    if [[ -d "giwa-node" ]]; then
        warning "⚠️  'giwa-node' directory already exists. The installer will remove it."
    else
        info "✅ No existing giwa-node directory found"
    fi
}

main() {
    echo
    log "=== Giwa Node Installer Validation ==="
    echo

    check_os
    check_root
    check_resources
    check_network
    check_existing

    echo
    log "=== Validation Results ==="

    if [[ "$VALIDATION_PASSED" == true ]]; then
        info "✅ All validations passed! The installer should work on this system."
        echo
        info "You can now run the installer with:"
        echo "  ./install-giwa-node.sh"
    else
        error "❌ Some validations failed. Please address the issues above before running the installer."
        echo
        error "The installer may not work correctly on this system."
    fi

    echo
}

main "$@"