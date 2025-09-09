# Giwa Node One-Click Installer

This repository contains a one-click installer script for deploying the [Giwa node](https://github.com/giwa-io/node) on your Linux VPS. Giwa is an Ethereum Layer 2 network built on Optimism's OP Stack.

## 🚀 Quick Start

### Prerequisites

- **Linux VPS** (Ubuntu/Debian/CentOS/RHEL/Fedora recommended)
  - ⚠️ **Important:** This installer is designed for Linux VPS only
  - Will not work on macOS, Windows, or other operating systems
- Minimum 4 CPU cores, 8GB RAM, 500GB storage
- Sudo privileges
- Internet connection

## 📚 Complete Setup Tutorial

### Step 1: Set Up Your VPS

If you're starting with a fresh VPS, follow these steps:

#### 1.1 Connect to Your VPS
```bash
ssh root@your-vps-ip-address
# or
ssh username@your-vps-ip-address
```

#### 1.2 Update Your System
```bash
# For Ubuntu/Debian:
sudo apt update && sudo apt upgrade -y

# For CentOS/RHEL:
sudo yum update -y

# For Fedora:
sudo dnf update -y
```

#### 1.3 Create a Non-Root User (Recommended)
```bash
# Create a new user
adduser giwa-user

# Add user to sudo group
usermod -aG sudo giwa-user  # Ubuntu/Debian
# or
usermod -aG wheel giwa-user  # CentOS/RHEL/Fedora

# Switch to the new user
su - giwa-user
```

### Step 2: Install Docker (Manual Method)

If you prefer to install Docker manually before running the installer:

#### 2.1 For Ubuntu/Debian:
```bash
# Remove old Docker versions
sudo apt remove docker docker-engine docker.io containerd runc

# Install prerequisites
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add your user to docker group
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
```

#### 2.2 For CentOS/RHEL:
```bash
# Install prerequisites
sudo yum install -y yum-utils

# Add Docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker $USER
```

#### 2.3 For Fedora:
```bash
# Install prerequisites
sudo dnf install -y dnf-plugins-core

# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Install Docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker $USER
```

### Step 3: Install Docker Compose (Manual Method)

If you need to install Docker Compose separately:

```bash
# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Create symlink
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installation
docker-compose --version
```

### Step 4: Verify Docker Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Test Docker (you may need to log out and back in for group changes)
docker run hello-world

# Check if Docker daemon is running
sudo systemctl status docker
```

### Step 5: Set Up RPC Endpoints

Before running the installer, you'll need RPC endpoints. Here are some options:

#### 5.1 Using Infura (Free tier available)
1. Go to [https://infura.io/](https://infura.io/)
2. Sign up for a free account
3. Create a new project
4. Get your Project ID
5. Your endpoints will be:
   - ETH RPC: `https://mainnet.infura.io/v3/YOUR_PROJECT_ID`
   - Beacon RPC: `https://beacon.infura.io/v3/YOUR_PROJECT_ID`

#### 5.2 Using Alchemy (Free tier available)
1. Go to [https://alchemy.com/](https://alchemy.com/)
2. Sign up for a free account
3. Create a new app
4. Get your API key
5. Your endpoints will be:
   - ETH RPC: `https://eth-mainnet.alchemyapi.io/v2/YOUR_API_KEY`
   - Beacon RPC: `https://eth-beacon-mainnet.alchemyapi.io/v2/YOUR_API_KEY`

#### 5.3 Using QuickNode
1. Go to [https://quicknode.com/](https://quicknode.com/)
2. Sign up and create an endpoint
3. Get your endpoint URL
4. Use the same URL for both ETH and Beacon RPC

### Step 6: Run the Giwa Node Installer

Now you're ready to run the installer:

```bash
# Download the installer
curl -fsSL https://raw.githubusercontent.com/0xfush1guro/giwa-node-installer/main/install-giwa-node.sh -o install-giwa-node.sh

# Make it executable
chmod +x install-giwa-node.sh

# Run the installer
./install-giwa-node.sh
```

### Step 7: Post-Installation

After the installer completes:

```bash
# Log out and back in to apply Docker group changes
exit
ssh your-username@your-vps-ip-address

# Navigate to the node directory
cd giwa-node

# Check if the node is running
docker-compose ps

# View logs
docker-compose logs -f
```

### Installation

1. **Download and run the installer:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/0xfush1guro/giwa-node-installer/main/install-giwa-node.sh -o install-giwa-node.sh
   chmod +x install-giwa-node.sh
   ./install-giwa-node.sh
   ```

2. **Or clone this repository:**
   ```bash
   git clone https://github.com/0xfush1guro/giwa-node-installer.git
   cd giwa-node-installer
   chmod +x install-giwa-node.sh
   ./install-giwa-node.sh
   ```

3. **Follow the interactive console prompts:**
   - **Enter your Ethereum L1 RPC endpoints** (the installer will ask you to type them in)
   - **Choose your sync strategy** (1, 2, or 3)
   - **Confirm your configuration**
   - Wait for the installation to complete

## 📋 What the Installer Does

The installer automatically:

- ✅ Checks system requirements (CPU, RAM, disk space)
- ✅ Updates system packages
- ✅ Installs Docker and Docker Compose
- ✅ Clones the Giwa node repository
- ✅ Configures environment variables
- ✅ Sets up L1 RPC endpoints
- ✅ Builds and starts the node containers
- ✅ Provides useful management commands

## 🔧 Configuration

### Required L1 RPC Endpoints

**The installer will prompt you to enter these via console input:**

1. **Ethereum L1 ETH RPC** - Your Ethereum mainnet RPC endpoint
   - Example: `https://mainnet.infura.io/v3/YOUR_KEY`
   - Or: `https://eth-mainnet.alchemyapi.io/v2/YOUR_KEY`

2. **Ethereum L1 Beacon RPC** - Your Ethereum beacon chain RPC endpoint
   - Example: `https://beacon.infura.io/v3/YOUR_KEY`
   - Or: `https://eth-beacon-mainnet.alchemyapi.io/v2/YOUR_KEY`

**Popular RPC Providers:**
- **Infura**: https://infura.io/
- **Alchemy**: https://alchemy.com/
- **QuickNode**: https://quicknode.com/
- **Ankr**: https://ankr.com/

### Example Console Interaction

When you run the installer, you'll see prompts like this:

```bash
=== L1 RPC Configuration ===
You need to provide Ethereum L1 RPC endpoints for the Giwa node to sync.
You can use services like Infura, Alchemy, or run your own Ethereum node.

Popular RPC providers:
  • Infura: https://infura.io/
  • Alchemy: https://alchemy.com/
  • QuickNode: https://quicknode.com/
  • Ankr: https://ankr.com/

Enter your Ethereum L1 ETH RPC URL: https://mainnet.infura.io/v3/YOUR_KEY
✅ ETH RPC URL format looks good

Enter your Ethereum L1 Beacon RPC URL: https://beacon.infura.io/v3/YOUR_KEY
✅ Beacon RPC URL format looks good

=== Configuration Summary ===
ETH RPC: https://mainnet.infura.io/v3/YOUR_KEY
Beacon RPC: https://beacon.infura.io/v3/YOUR_KEY

Is this configuration correct? (Y/n): y
```

### Sync Strategies

Choose from three sync strategies:

1. **Snap Sync** (Recommended)
   - Fastest to get online
   - Downloads recent state snapshot
   - Suitable for RPC nodes and followers

2. **Archive Sync**
   - Full historical state retention
   - Slower but complete history
   - Required for indexers and research

3. **Consensus-Driven Sync**
   - Trust-minimized approach
   - Consensus client drives execution
   - Good for L2 verifiers

## 🛠️ Management Commands

After installation, use these commands to manage your node:

```bash
# Navigate to the node directory
cd giwa-node

# Check node status
docker-compose ps

# View logs
docker-compose logs -f giwa-el    # Execution layer logs
docker-compose logs -f giwa-cl    # Consensus layer logs
docker-compose logs -f            # All logs

# Stop the node
docker-compose down

# Restart the node
docker-compose restart

# Update the node
git pull && docker-compose build --parallel && docker-compose up -d

# Clean up (removes all data)
docker-compose down -v && rm -rf ./execution_data
```

## 📊 System Requirements

### Minimum Requirements (Testnet)
- **CPU:** 4 cores
- **RAM:** 8 GB
- **Storage:** 500 GB (NVMe SSD recommended)
- **OS:** Ubuntu 20.04+, Debian 11+, CentOS 8+, RHEL 8+, Fedora 34+

### Recommended Requirements
- **CPU:** 8+ cores
- **RAM:** 16+ GB
- **Storage:** 1+ TB NVMe SSD
- **Network:** Stable internet connection with low latency

## 🔍 Troubleshooting

### Common Issues

1. **Docker permission denied:**
   ```bash
   # Log out and back in, or run:
   newgrp docker
   
   # Or restart the Docker service:
   sudo systemctl restart docker
   ```

2. **Docker not starting:**
   ```bash
   # Check Docker service status:
   sudo systemctl status docker
   
   # Start Docker service:
   sudo systemctl start docker
   
   # Enable Docker to start on boot:
   sudo systemctl enable docker
   ```

3. **Insufficient disk space:**
   - Ensure you have at least 500GB free space
   - Check disk usage: `df -h`
   - Consider using a larger VPS or external storage

4. **Node not syncing:**
   - Check your L1 RPC endpoints are working
   - Test RPC endpoints: `curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' YOUR_RPC_URL`
   - Verify network connectivity
   - Check logs: `docker-compose logs -f`

5. **Out of memory:**
   - Increase VPS RAM or add swap space
   - Monitor with: `docker stats`
   - Check memory usage: `free -h`

6. **Port conflicts:**
   - Check if ports are in use: `sudo netstat -tulpn | grep :PORT_NUMBER`
   - Stop conflicting services or change ports in docker-compose.yaml

7. **Git clone fails:**
   - Check internet connectivity: `ping github.com`
   - Try cloning manually: `git clone https://github.com/giwa-io/node.git`

8. **Docker build fails:**
   - Check Docker daemon is running: `sudo systemctl status docker`
   - Try building manually: `docker-compose build --no-cache`

### VPS Provider Specific Issues

#### DigitalOcean
- Ensure you have enough resources in your droplet
- Check if you need to configure firewall rules

#### AWS EC2
- Configure security groups to allow necessary ports
- Ensure instance has sufficient EBS storage

#### Linode
- Check if you need to configure firewall
- Ensure adequate resources in your plan

#### Vultr
- Verify your VPS plan meets minimum requirements
- Check network connectivity

### Getting Help

- Check the [official Giwa documentation](https://github.com/giwa-io/node)
- View container logs for detailed error messages: `docker-compose logs -f giwa-el` and `docker-compose logs -f giwa-cl`
- Ensure your L1 RPC endpoints are accessible and have sufficient rate limits
- Test your RPC endpoints independently before running the installer
- Ensure your L1 RPC endpoints are accessible and have sufficient rate limits

## 🔒 Security Notes

- The installer runs as a regular user (not root)
- Docker containers run with appropriate security contexts
- Environment files contain sensitive RPC keys - keep them secure
- Consider using a firewall to restrict access to your VPS

## 📝 Environment File

The installer creates a `.env` file in the `giwa-node` directory with your configuration. Key variables include:

```bash
OP_NODE_L1_ETH_RPC=your_eth_rpc_url
OP_NODE_L1_BEACON=your_beacon_rpc_url
NETWORK_ENV=.env
```

## 🌐 Network Information

- **Testnet:** Sepolia (currently supported)
- **Mainnet:** Coming soon
- **Network Type:** Ethereum Layer 2 (OP Stack)

## 📄 License

This installer script is provided under the MIT License. The Giwa node itself is also MIT licensed.

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## ⚠️ Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND. By running this installer and node, you are responsible for your infrastructure, security, and compliance.

## 📋 Quick Reference

### Essential Commands
```bash
# Check node status
docker-compose ps

# View all logs
docker-compose logs -f

# View execution layer logs
docker-compose logs -f giwa-el

# View consensus layer logs
docker-compose logs -f giwa-cl

# Stop the node
docker-compose down

# Start the node
docker-compose up -d

# Restart the node
docker-compose restart

# Update the node
git pull && docker-compose build --parallel && docker-compose up -d

# Clean up everything
docker-compose down -v && rm -rf ./execution_data
```

### System Monitoring
```bash
# Check disk usage
df -h

# Check memory usage
free -h

# Check CPU usage
top

# Check Docker stats
docker stats

# Check running containers
docker ps
```

### RPC Testing
```bash
# Test ETH RPC endpoint
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  YOUR_ETH_RPC_URL

# Test Beacon RPC endpoint
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false],"id":1}' \
  YOUR_BEACON_RPC_URL
```

---

**Need help?** Check the [Giwa community](https://github.com/giwa-io/node) for support and updates.
