#!/bin/bash

# Шаг 1: Terraform - создаём инфраструктуру
echo "=== Initializing Terraform ==="
terraform init

echo "=== Applying Terraform configuration ==="
terraform apply -auto-approve

# Шаг 2: Получаем выходные переменные из Terraform
VM_IP=$(terraform output -raw vm_public_ip)
SSH_USER=$(terraform output -raw vm_ssh_user)

# Шаг 3: Генерируем динамический inventory для Ansible
echo "=== Generating Ansible inventory ==="
cat > inventory.ini << EOF
[web]
nginx_ansible_vm ansible_host=$VM_IP ansible_user=$SSH_USER ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF

# Шаг 4: Ждём пока VM станет полностью доступной
echo "=== Waiting for VM to become available ==="
sleep 30

# Шаг 5: Запускаем Ansible
echo "=== Running Ansible playbook ==="
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini ansible/playbook.yml

# Шаг 6: Показываем результат
echo "=== Deployment complete ==="
echo "Website available at: http://$VM_IP"