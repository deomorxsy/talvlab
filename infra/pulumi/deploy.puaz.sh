# Azure CLI infrastructure settings
## VNET and Network Security Group generation
az group create -n kubek3s -l westus2

az network vnet create \
    --resource-group vnetgroupk3s \
    --name vnetnamek3s \
    --address-prefix 192.168.0.0/16 \
    --subnet-name k3s \
    --subnet-prefix 192.168.0.0/16

az network nsg create \
    --resource-group kubek3s \
    --name kubek3s

az network nsg rule create \
    --resource-group nsgsshk3s \
    --nsg-name nsgsshk3s \
    --name sshk3s \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

az network nsg rule create \
    --resource-group nsgwebgroupk3s \
    --nsg-name nsgnamewebk3s \
    --name nsgk3sWeb \
    --protocol tcp \
    --priority 1001 \
    --destination-port-range 6443 \
    --access allow

az network vnet subnet update \
    -g k3s \
    -n vnetsubk3s \
    --vnet-name vnetnamek3s \
    --network-security-group kubeadm

## VM creation

az vm create -n k3s-server-1 -g kubeadm \
--image UbuntuLTS \
--vnet-name vnetnamek3s --subnet k3s \
--admin-username k3sadmin \
--ssh-key-value @~/.ssh/id_rsa.pub \
--size Standard_D2ds_v4 \
--nsg kubeadm \
--public-ip-sku Standard --no-wait

az vm create -n k3s-server-2 -g kubeadm \
--image UbuntuLTS \
--vnet-name kubeadm --subnet k3s \
--admin-username nilfranadmin \
--ssh-key-value @~/.ssh/id_rsa.pub \
--size Standard_D2ds_v4 \
--nsg kubeadm \
--public-ip-sku Standard --no-wait

az vm create -n k3s-agent-1 -g kubeadm \
--image UbuntuLTS \
--vnet-name kubeadm --subnet k3s \
--admin-username k3sasari \
--ssh-key-value @~/.ssh/id_rsa.pub \
--size Standard_D2ds_v4 \
--nsg kubeadm \
--public-ip-sku Standard --no-wait

az vm create -n k3s-agent-2 -g kubeadm \
--image UbuntuLTS \
--vnet-name kubeadm --subnet k3s \
--admin-username k3sasari \
--ssh-key-value @~/.ssh/id_rsa.pub \
--size Standard_D2ds_v4 \
--nsg kubeadm \
--public-ip-sku Standard

## load balancer bit
