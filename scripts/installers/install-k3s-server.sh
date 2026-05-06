# 直接运行（无需保存文件）—— 自动处理 IP、清理、校验、安装、启动、验证
export INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_SKIP_START=true
NODE_IP=$(ip -4 route get 1 | awk '{print $7;exit}' 2>/dev/null) && \
[ -z "$NODE_IP" ] && NODE_IP=$(hostname -I | awk '{print $1}') && \
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
  INSTALL_K3S_VERSION=v1.31.3+k3s2 \
  INSTALL_K3S_MIRROR=cn \
  INSTALL_K3S_EXEC="server \
    --disable servicelb,traefik,local-storage,metrics-server \
    --tls-san $NODE_IP \
    --tls-san $(hostname) \
    --write-kubeconfig-mode 644 \
    --node-label role.kubernetes.io/control-plane=true \
    --kube-apiserver-arg=max-requests-inflight=50 \
    --kube-apiserver-arg=memlock=1" \
  sh - && \
k3s server > /var/log/k3s.log 2>&1 & && \
timeout 120s bash -c 'while ! k3s kubectl get nodes >/dev/null 2>&1; do sleep 5; done && curl -k -f https://'$NODE_IP':6443/healthz >/dev/null 2>&1' && \
echo -e "\n✅ K3s 控制面部署成功！\n📋 API: https://$NODE_IP:6443\n🔑 kubeconfig: /etc/rancher/k3s/k3s.yaml"
