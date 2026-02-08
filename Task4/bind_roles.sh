#!/bin/bash

# Скрипт для связывания пользователей с ролями с помощью RBAC
# PropDevelopment - Создание RoleBinding и ClusterRoleBinding для RBAC 

set -e

echo "=== Связывание пользователей с ролями для PropDevelopment ==="

create_cluster_role_binding() {
    local name=$1
    local role=$2
    local users=$3
    
    echo "Создание ClusterRoleBinding: $name"
    kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $name
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: $role
subjects:
$users
EOF
}

create_role_binding() {
    local name=$1
    local role=$2
    local namespace=$3
    local users=$4
    
    echo "Создание RoleBinding: $name в namespace: $namespace"
    kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $name
  namespace: $namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $role
subjects:
$users
EOF
}

echo "=== Связывание DevOps команды с cluster-admin ==="
create_cluster_role_binding "devops-cluster-admin" "cluster-admin" "
- kind: User
  name: devops-1
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: devops-2
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: security-admin
  apiGroup: rbac.authorization.k8s.io
"

echo "=== Связывание Security Audit команды с security-auditor ==="
create_cluster_role_binding "security-audit-binding" "security-auditor" "
- kind: User
  name: auditor-1
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: security-admin
  apiGroup: rbac.authorization.k8s.io
"

echo "=== Связывание Monitoring команды с monitoring ==="
create_cluster_role_binding "monitoring-binding" "monitoring" "
- kind: User
  name: sre-1
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: sre-2
  apiGroup: rbac.authorization.k8s.io
"

echo "=== Связывание Management команды с viewer ==="
create_cluster_role_binding "management-viewer-binding" "viewer" "
- kind: User
  name: manager-1
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: manager-2
  apiGroup: rbac.authorization.k8s.io
"

echo "=== Связывание PropDevelopment команды с namespace-admin ==="
create_role_binding "propdev-namespace-admin" "namespace-admin" "propdevelopment" "
- kind: User
  name: team-lead-1
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: senior-dev-1
  apiGroup: rbac.authorization.k8s.io
"
echo "=== Связывание Client Services команды с developer ==="
create_role_binding "client-developer-binding" "developer" "client-services" "
- kind: User
  name: dev-1
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: dev-2
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: qa-1
  apiGroup: rbac.authorization.k8s.io
"
echo "=== Связывание HKU Services команды с developer ==="
create_role_binding "hku-developer-binding" "developer" "hku-services" "
- kind: User
  name: dev-3
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: dev-4
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: qa-2
  apiGroup: rbac.authorization.k8s.io
"
echo "=== Связывание Finance Services команды с developer ==="
create_role_binding "finance-developer-binding" "developer" "finance-services" "
- kind: User
  name: dev-5
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: qa-3
  apiGroup: rbac.authorization.k8s.io
"
echo "=== Связывание Data Services команды с developer ==="
create_role_binding "data-developer-binding" "developer" "data-services" "
- kind: User
  name: dev-6
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: qa-4
  apiGroup: rbac.authorization.k8s.io
"

echo "=== Создание дополнительных namespace-admin привязок ==="

create_role_binding "client-namespace-admin" "namespace-admin" "client-services" "
- kind: User
  name: team-lead-1
  apiGroup: rbac.authorization.k8s.io
"

create_role_binding "hku-namespace-admin" "namespace-admin" "hku-services" "
- kind: User
  name: team-lead-1
  apiGroup: rbac.authorization.k8s.io
"

create_role_binding "finance-namespace-admin" "namespace-admin" "finance-services" "
- kind: User
  name: team-lead-1
  apiGroup: rbac.authorization.k8s.io
"

create_role_binding "data-namespace-admin" "namespace-admin" "data-services" "
- kind: User
  name: team-lead-1
  apiGroup: rbac.authorization.k8s.io
"

echo "=== Все привязки созданы успешно ==="
echo ""
echo "Созданные ClusterRoleBinding:"
echo "- devops-cluster-admin (cluster-admin)"
echo "- security-audit-binding (security-auditor)"
echo "- monitoring-binding (monitoring)"
echo "- management-viewer-binding (viewer)"
echo ""
echo "Созданные RoleBinding:"
echo "- propdev-namespace-admin (namespace-admin в propdevelopment)"
echo "- client-developer-binding (developer в client-services)"
echo "- hku-developer-binding (developer в hku-services)"
echo "- finance-developer-binding (developer в finance-services)"
echo "- data-developer-binding (developer в data-services)"
echo "- namespace-admin привязки для team-lead-1 в каждом namespace"
echo ""
echo "Для проверки привязок используйте:"
echo "kubectl get clusterrolebindings"
echo "kubectl get rolebindings --all-namespaces"
echo ""
echo "Для проверки прав пользователя используйте:"
echo "kubectl auth can-i <verb> <resource> --as=<username>"
echo "kubectl auth can-i get pods --as=dev-1"
