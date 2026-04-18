# Роли в Kubernetes
| Роль                      | Права роли                                                                                                                              | Группы пользователей                                              |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| admin                     | Все права на все ресурсы всего кластера.                                                                                                | DevOps-инженер, управляющий кластером                             |
| namespace-service-updater | Все права обновление ресурсов неймспейса: Deployments, Services, ConfigMaps, Secrets, Pods, Jobs, CronJobs                              | Сервисная роль для установки обновлений из CI/CD                  |
| namespace-developer       | Права на просмотр ресурсов неймспейса: Pods, Deployments, Services, ConfigMaps, Ingress, Events. Запрещён просмотр Secrets.             | Команда разработки проекта: QA, разработчики, системные аналитики |
| security-reader           | Права на просмотр Secrets, Roles, RoleBindings, ClusterRoles, ClusterRoleBindings, NetworkPolicies, PodSecurityPolicies всего кластера. | Специалист ИБ                                                     |

# Инструкция по настройке

Запустить по порядку
```
minikube start
kubectl create namespace prop-development
kubectl apply -f ./users.yaml
kubectl apply -f ./roles.yaml
kubectl apply -f ./role-bindings.yaml
```