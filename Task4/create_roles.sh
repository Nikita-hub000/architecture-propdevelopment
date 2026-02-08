#!/bin/bash

# Скрипт для создания ролей Kubernetes с помощью RBAC
# PropDevelopment - Создание ролей для RBAC в Kubernetes

set -e

echo "=== Создание ролей Kubernetes для PropDevelopment ==="

echo "Создание ClusterRole: cluster-admin"
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-admin
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
- nonResourceURLs: ["*"]
  verbs: ["*"]
EOF

echo "Создание ClusterRole: security-auditor"
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: security-auditor
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
EOF

echo "Создание ClusterRole: monitoring"
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring
rules:
- apiGroups: [""]
  resources: ["pods", "services", "nodes", "endpoints"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["metrics.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list"]
- apiGroups: ["monitoring.coreos.com"]
  resources: ["*"]
  verbs: ["get", "list", "create", "update", "patch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch"]
EOF

echo "Создание ClusterRole: viewer"
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: viewer
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "persistentvolumeclaims"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets"]
  verbs: ["get", "list", "watch"]
EOF

create_namespace_role() {
    local role_name=$1
    local namespace=$2
    local rules=$3
    
    echo "Создание Role: $role_name в namespace: $namespace"
    kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $role_name
  namespace: $namespace
rules:
$rules
EOF
}

echo "=== Создание namespace-admin ролей для каждого namespace ==="

create_namespace_role "namespace-admin" "propdevelopment" "
- apiGroups: [\"\"]
  resources: [\"pods\", \"services\", \"secrets\", \"configmaps\", \"persistentvolumeclaims\"]
  verbs: [\"*\"]
- apiGroups: [\"apps\"]
  resources: [\"deployments\", \"replicasets\", \"statefulsets\"]
  verbs: [\"*\"]
- apiGroups: [\"networking.k8s.io\"]
  resources: [\"ingresses\", \"networkpolicies\"]
  verbs: [\"*\"]
"

create_namespace_role "namespace-admin" "client-services" "
- apiGroups: [\"\"]
  resources: [\"pods\", \"services\", \"secrets\", \"configmaps\", \"persistentvolumeclaims\"]
  verbs: [\"*\"]
- apiGroups: [\"apps\"]
  resources: [\"deployments\", \"replicasets\", \"statefulsets\"]
  verbs: [\"*\"]
- apiGroups: [\"networking.k8s.io\"]
  resources: [\"ingresses\", \"networkpolicies\"]
  verbs: [\"*\"]
"

create_namespace_role "namespace-admin" "hku-services" "
- apiGroups: [\"\"]
  resources: [\"pods\", \"services\", \"secrets\", \"configmaps\", \"persistentvolumeclaims\"]
  verbs: [\"*\"]
- apiGroups: [\"apps\"]
  resources: [\"deployments\", \"replicasets\", \"statefulsets\"]
  verbs: [\"*\"]
- apiGroups: [\"networking.k8s.io\"]
  resources: [\"ingresses\", \"networkpolicies\"]
  verbs: [\"*\"]
"

create_namespace_role "namespace-admin" "finance-services" "
- apiGroups: [\"\"]
  resources: [\"pods\", \"services\", \"secrets\", \"configmaps\", \"persistentvolumeclaims\"]
  verbs: [\"*\"]
- apiGroups: [\"apps\"]
  resources: [\"deployments\", \"replicasets\", \"statefulsets\"]
  verbs: [\"*\"]
- apiGroups: [\"networking.k8s.io\"]
  resources: [\"ingresses\", \"networkpolicies\"]
  verbs: [\"*\"]
"

create_namespace_role "namespace-admin" "data-services" "
- apiGroups: [\"\"]
  resources: [\"pods\", \"services\", \"secrets\", \"configmaps\", \"persistentvolumeclaims\"]
  verbs: [\"*\"]
- apiGroups: [\"apps\"]
  resources: [\"deployments\", \"replicasets\", \"statefulsets\"]
  verbs: [\"*\"]
- apiGroups: [\"networking.k8s.io\"]
  resources: [\"ingresses\", \"networkpolicies\"]
  verbs: [\"*\"]
"

echo "=== Создание developer ролей ==="

create_namespace_role "developer" "client-services" "
- apiGroups: [\"\"]
  resources: [\"pods\", \"services\", \"configmaps\", \"persistentvolumeclaims\"]
  verbs: [\"get\", \"list\", \"create\", \"update\", \"patch\", \"delete\"]
- apiGroups: [\"apps\"]
  resources: [\"deployments\", \"replicasets\"]
  verbs: [\"get\", \"list\", \"create\", \"update\", \"patch\", \"delete\"]
"

create_namespace_role "developer" "hku-services" "
- apiGroups: [\"\"]
  resources: [\"pods\", \"services\", \"configmaps\", \"persistentvolumeclaims\"]
  verbs: [\"get\", \"list\", \"create\", \"update\", \"patch\", \"delete\"]
- apiGroups: [\"apps\"]
  resources: [\"deployments\", \"replicasets\"]
  verbs: [\"get\", \"list\", \"create\", \"update\", \"patch\", \"delete\"]
"

create_namespace_role "developer" "finance-services" "
- apiGroups: [\"\"]
  resources: [\"pods\", \"services\", \"configmaps\", \"persistentvolumeclaims\"]
  verbs: [\"get\", \"list\", \"create\", \"update\", \"patch\", \"delete\"]
- apiGroups: [\"apps\"]
  resources: [\"deployments\", \"replicasets\"]
  verbs: [\"get\", \"list\", \"create\", \"update\", \"patch\", \"delete\"]
"

create_namespace_role "developer" "data-services" "
- apiGroups: [\"\"]
  resources: [\"pods\", \"services\", \"configmaps\", \"persistentvolumeclaims\"]
  verbs: [\"get\", \"list\", \"create\", \"update\", \"patch\", \"delete\"]
- apiGroups: [\"apps\"]
  resources: [\"deployments\", \"replicasets\"]
  verbs: [\"get\", \"list\", \"create\", \"update\", \"patch\", \"delete\"]
"

echo "=== Все роли созданы успешно ==="
echo ""
echo "Созданные ClusterRole:"
echo "- cluster-admin"
echo "- security-auditor"
echo "- monitoring"
echo "- viewer"
echo ""
echo "Созданные Role в namespace'ах:"
echo "- namespace-admin (в каждом namespace)"
echo "- developer (в каждом namespace)"
echo ""
echo "Для проверки ролей используйте:"
echo "kubectl get clusterroles"
echo "kubectl get roles --all-namespaces"
