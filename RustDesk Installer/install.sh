#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置默认值
DEFAULT_IP=$(hostname -I | awk '{print $1}')
DEFAULT_PORT_HBBR=21117
DEFAULT_PORT_HBBS=21116
DEFAULT_DATA_DIR="/tmp/rustdesk-data"
DOCKER_COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
DEFAULT_MIRROR="rustdesk/rustdesk-server:latest"
MIRROR_REGISTRY="hub.1panel.dev"

# 开屏LOGO
logo='
██████╗ ██╗   ██╗███████╗████████╗██████╗ ███████╗███████╗██╗  ██╗
██╔══██╗██║   ██║██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔════╝██║ ██╔╝
██████╔╝██║   ██║███████╗   ██║   ██║  ██║█████╗  ███████╗█████╔╝ 
██╔══██╗██║   ██║╚════██║   ██║   ██║  ██║██╔══╝  ╚════██║██╔═██╗ 
██║  ██║╚██████╔╝███████║   ██║   ██████╔╝███████╗███████║██║  ██╗
╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝
                              Version 1.0 | Docker-Image-Installer

'

# 安装依赖
install_dependency() {
    local package=$1
    print_message "$YELLOW" "正在安装 $package..."
    if ! sudo apt-get install -y "$package"; then
        print_message "$RED" "错误: 安装 $package 失败"
        exit 1
    fi
}

# 检查并安装依赖
check_dependencies() {
    print_message "$YELLOW" "正在检查依赖..."
    
    # 检查 lsof
    if ! command -v lsof &> /dev/null; then
        print_message "$YELLOW" "未检测到 lsof，正在安装..."
        install_dependency "lsof"
    fi
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        print_message "$YELLOW" "未检测到 Docker，正在安装..."
        curl -fsSL https://get.docker.com | sh
        sudo systemctl enable docker
        sudo systemctl start docker
    fi

    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_message "$YELLOW" "未检测到 Docker Compose，正在安装..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    # 检查 Docker 服务状态
    if ! docker info &> /dev/null; then
        print_message "$RED" "错误: Docker 服务未运行"
        print_message "$YELLOW" "正在启动 Docker 服务..."
        sudo systemctl start docker
    fi

    print_message "$GREEN" "依赖检查完成 ✓"
}

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 检查依赖
check_dependencies() {
    print_message "$YELLOW" "正在检查依赖..."
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        print_message "$RED" "错误: Docker 未安装"
        print_message "$YELLOW" "请先安装 Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi

    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_message "$RED" "错误: Docker Compose 未安装"
        print_message "$YELLOW" "请先安装 Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi

    # 检查 Docker 服务状态
    if ! docker info &> /dev/null; then
        print_message "$RED" "错误: Docker 服务未运行"
        print_message "$YELLOW" "请启动 Docker 服务后重试"
        exit 1
    fi

    print_message "$GREEN" "依赖检查完成 ✓"
}

# 收集基础配置
collect_basic_config() {
    print
    print_message "$YELLOW" "\n=== RustDesk 内网中继服务器配置脚本 ==="
    
    # 收集 IP 地址
    read -p "请输入服务器IP地址 [$DEFAULT_IP]: " RELAY_IP
    RELAY_IP=${RELAY_IP:-$DEFAULT_IP}

    # 收集 HBBS 端口
    read -p "请输入信令服务器端口 [$DEFAULT_PORT_HBBS]: " HBBS_PORT
    HBBS_PORT=${HBBS_PORT:-$DEFAULT_PORT_HBBS}

    # 收集 HBBR 端口
    read -p "请输入中继服务器端口 [$DEFAULT_PORT_HBBR]: " HBBR_PORT
    HBBR_PORT=${HBBR_PORT:-$DEFAULT_PORT_HBBR}

    # 验证端口是否被占用
    if lsof -i :$HBBS_PORT > /dev/null 2>&1; then
        print_message "$RED" "错误: 端口 $HBBS_PORT 已被占用"
        exit 1
    fi
    if lsof -i :$HBBR_PORT > /dev/null 2>&1; then
        print_message "$RED" "错误: 端口 $HBBR_PORT 已被占用"
        exit 1
    fi

    # 询问是否配置高级选项
    read -p "是否配置高级选项? (y/N): " configure_advanced
    if [[ $configure_advanced =~ ^[Yy]$ ]]; then
        collect_advanced_config
    else
        LIMIT_SPEED=0
        DATA_DIR=$DEFAULT_DATA_DIR
    fi
}

# 收集高级配置
collect_advanced_config() {
    # 带宽限制
    read -p "是否限制带宽? (y/N): " limit_bandwidth
    if [[ $limit_bandwidth =~ ^[Yy]$ ]]; then
        read -p "请输入最大带宽(Mbps): " LIMIT_SPEED
        LIMIT_SPEED=${LIMIT_SPEED:-10}
    else
        LIMIT_SPEED=0
    fi

    # 数据持久化
    read -p "是否启用数据持久化? (y/N): " enable_persistence
    if [[ $enable_persistence =~ ^[Yy]$ ]]; then
        read -p "请输入数据存储路径 [$DEFAULT_DATA_DIR]: " DATA_DIR
        DATA_DIR=${DATA_DIR:-$DEFAULT_DATA_DIR}
        mkdir -p "$DATA_DIR"
    else
        DATA_DIR=$DEFAULT_DATA_DIR
    fi
}

# 配置 Docker 镜像
configure_docker_mirror() {
    print_message "$YELLOW" "\n=== Docker 镜像配置 ==="
    read -p "是否使用加速镜像源? (y/N): " use_mirror
    if [[ $use_mirror =~ ^[Yy]$ ]]; then
        DOCKER_IMAGE="${MIRROR_REGISTRY}/${DEFAULT_MIRROR}"
        print_message "$GREEN" "将使用加速镜像: $DOCKER_IMAGE"
    else
        DOCKER_IMAGE=$DEFAULT_MIRROR
        print_message "$GREEN" "将使用官方镜像: $DOCKER_IMAGE"
    fi
}

# 生成配置文件
generate_config_files() {
    print_message "$YELLOW" "\n正在生成配置文件..."

    # 生成 .env 文件
    cat > $ENV_FILE << EOF
RELAY_IP=$RELAY_IP
HBBS_PORT=$HBBS_PORT
HBBR_PORT=$HBBR_PORT
LIMIT_SPEED=$LIMIT_SPEED
DATA_DIR=$DATA_DIR
EOF

    # 生成 docker-compose.yml 文件
    cat > $DOCKER_COMPOSE_FILE << EOF
version: '3'

networks:
  rustdesk-net:
    external: false

services:
  hbbs:
    container_name: hbbs
    ports:
      - "21115:21115"
      - "\${HBBS_PORT}:21116"
      - "\${HBBS_PORT}:21116/udp"
    image: ${DOCKER_IMAGE}
    command: hbbs
    volumes:
      - "\${DATA_DIR}:/root"
    networks:
      - rustdesk-net
    depends_on:
      - hbbr
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 64M

  hbbr:
    container_name: hbbr
    ports:
      - "\${HBBR_PORT}:21117"
    image: ${DOCKER_IMAGE}
    command: hbbr
    volumes:
      - "\${DATA_DIR}:/root"
    networks:
      - rustdesk-net
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 64M
EOF

    print_message "$GREEN" "配置文件生成完成 ✓"
}

# 显示部署结果
show_result() {
    print_message "$GREEN" "\n=== 部署成功 ==="
    echo -e "\nRustDesk 服务器已成功启动"
    echo -e "服务器地址: ${YELLOW}${RELAY_IP}${NC}"
    echo -e "信令端口: ${YELLOW}${HBBS_PORT}${NC}"
    echo -e "中继端口: ${YELLOW}${HBBR_PORT}${NC}"
    
    # 获取并显示公钥
    echo -e "\n${YELLOW}服务器公钥:${NC}"
    if ! docker exec -i hbbs /bin/sh -c "cat /root/id_ed25519.pub 2>/dev/null"; then
        # 如果第一次尝试失败，等待几秒后重试
        sleep 3
        if ! docker exec -i hbbs /bin/sh -c "cat /root/id_ed25519.pub 2>/dev/null"; then
            print_message "$RED" "警告: 无法读取服务器公钥，请手动执行以下命令查看:"
            echo -e "${YELLOW}docker exec -i hbbs /bin/sh -c 'cat /root/id_ed25519.pub'${NC}"
            print_message "$RED" "内网环境无需配置公钥，如需要外网部署，请忽略此提示。"
        fi
    fi
    
    echo -e "\n${YELLOW}客户端配置步骤:${NC}"
    echo "1. 打开 RustDesk 客户端"
    echo "2. 进入 设置 -> 网络"
    echo -e "3. 在ID服务器中输入: ${YELLOW}${RELAY_IP}:21116${NC}"
    echo -e "4. 在中继服务器中输入: ${YELLOW}${RELAY_IP}:21117${NC}"
    echo -e "5. 在Key中粘贴上面显示的公钥内容"
    echo "6. 点击确定保存配置"
    
    # 显示防火墙建议
    echo -e "\n${YELLOW}防火墙配置建议:${NC}"
    echo "请确保以下端口已开放:"
    echo "- TCP: 21115, 21116, 21117"
    echo "- UDP: 21116"
    echo -e "示例命令:"
    echo "sudo ufw allow 21115/tcp"
    echo "sudo ufw allow 21116/tcp"
    echo "sudo ufw allow 21116/udp"
    echo -e "sudo ufw allow 21117/tcp\n"

    # 显示可以安装1panel管理服务
    echo -e "\n${YELLOW}推荐安装1panle可视化管理面板${NC}"
    echo -e "1panel是一款开源的可视化管理面板，它可以帮助您更方便地管理和部署各种服务。\n"
    echo -e "Ubuntu 安装命令:"
    print_message "$GREEN" "curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sudo bash quick_start.sh"
    echo -e "Debian 安装命令:"
    print_message "$GREEN" "curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && bash quick_start.sh"
}

# 清理函数
cleanup() {
    print_message "$YELLOW" "正在清理..."
    docker-compose down
    rm -f $DOCKER_COMPOSE_FILE $ENV_FILE
    print_message "$GREEN" "清理完成"
}

# 删除重复的 check_dependencies 函数，只保留带自动安装功能的版本

# 部署服务
deploy_service() {
    print_message "$YELLOW" "\n正在部署服务..."

    # 拉取镜像
    if ! docker-compose pull; then
        print_message "$RED" "错误: 镜像拉取失败"
        cleanup
        exit 1
    fi

    # 启动服务
    if ! docker-compose up -d; then
        print_message "$RED" "错误: 服务启动失败"
        cleanup
        exit 1
    fi

    # 等待服务启动
    sleep 5

    # 验证服务状态
    if ! docker ps | grep -q "hbbs" || ! docker ps | grep -q "hbbr"; then
        print_message "$RED" "错误: 服务启动验证失败"
        cleanup
        exit 1
    fi

    print_message "$GREEN" "服务部署完成 ✓"
}

# 主函数
main() {
    # 显示欢迎信息
    echo -e "$logo"
    print_message "$GREEN" "=== RustDesk Installer ==="
    print_message "$YELLOW" "本脚本将帮助您快速部署内网专用的RustDesk中继服务器\n"

    # 检查依赖
    check_dependencies

    # 配置 Docker 镜像
    configure_docker_mirror

    # 收集配置
    collect_basic_config

    # 生成配置文件
    generate_config_files

    # 确认安装
    echo -e "\n=== 安装确认 ==="
    echo "服务器IP: $RELAY_IP"
    echo "信令端口: $HBBS_PORT"
    echo "中继端口: $HBBR_PORT"
    echo "带宽限制: ${LIMIT_SPEED}Mbps (0表示无限制)"
    echo "数据目录: $DATA_DIR"
    
    read -p "确认安装? (Y/n): " confirm
    if [[ $confirm =~ ^[Nn]$ ]]; then
        print_message "$YELLOW" "安装已取消"
        cleanup
        exit 0
    fi

    # 部署服务
    deploy_service

    # 显示结果
    show_result
}

# 错误处理
set -e
trap 'print_message "$RED" "错误: 安装过程中断"; cleanup; exit 1' ERR

# 运行主函数
main