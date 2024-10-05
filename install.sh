#!/bin/bash

# Cập nhật và cài đặt các tiện ích cần thiết
echo "Updating package list and installing necessary packages..."
apt-get update -y >/dev/null
apt-get install -y curl wget git jq software-properties-common ca-certificates apt-transport-https >/dev/null

# Kiểm tra và cài đặt Docker nếu chưa có
echo "Checking Docker installation..."
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed. Installing Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update -y >/dev/null
    apt-get install -y docker-ce docker-ce-cli containerd.io >/dev/null
    systemctl start docker
    systemctl enable docker
else
    echo "Docker is already installed."
fi

# Kiểm tra và cài đặt Docker Compose v2 nếu chưa có
echo "Checking Docker Compose installation..."
if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose v2 is not installed. Installing Docker Compose v2..."
    DOCKER_CONFIG=${DOCKER_CONFIG:-/usr/local/lib/docker}
    mkdir -p $DOCKER_CONFIG/cli-plugins
    curl -SL https://github.com/docker/compose/releases/download/v2.30.0/docker-compose-linux-$(uname -m) -o $DOCKER_CONFIG/cli-plugins/docker-compose
    chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
else
    echo "Docker Compose v2 is already installed."
fi

# Kiểm tra xem Docker daemon đã chạy chưa
echo "Checking if Docker daemon is running..."
if ! systemctl is-active --quiet docker; then
    echo "Docker daemon is not running. Starting Docker..."
    systemctl start docker
else
    echo "Docker daemon is running."
fi

# In cảnh báo điều kiện cần trước khi chạy cài đặt
echo -e "\n======== WARM TIPS ========"
echo -e "Before you submit any github issue, please do the following check:"
echo -e "* make sure the docker daemon is running"
echo -e "* make sure you use docker compose v2: recommend 2.x.x, got not install"
echo -e "* check your internet connection if timeout happens"
echo -e "* check for potential port conflicts if you have local services listening on all interfaces (e.g. another redis container listening on *:6379)"
echo -e "===========================\n"

# Chạy script cài đặt Apitable
echo "Running Apitable install script..."
curl https://apitable.github.io/install.sh | bash