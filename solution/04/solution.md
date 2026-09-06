# ДЗ «Микросервисы: масштабирование»

## Задача 1. Кластеризация

**Выбор: Kubernetes**

| — | Kubernetes | Docker Swarm | Nomad |
|---|---|---|---|
| Контейнеры | + | + | + |
| Сервис-дискавери и маршрутизация | + (Service, Ingress) | + | + (через Consul) |
| Горизонтальный и автоскейлинг | + (HPA/VPA) | − (вручную) | + |
| Внешние/внутренние ресурсы раздельно | + (Service/Ingress/NetworkPolicy) | частично | частично |
| Переменные среды и секреты | + (ConfigMap/Secret) | + | + (Vault) |

**Почему K8s:** закрывает все требования «из коробки» и является стандартом индустрии для микросервисов — гигантская экосистема (Helm, Operators, GitOps: ArgoCD/Flux). Swarm проигрывает в автоматизации (нет автоскейлинга), Nomad придётся дорабатывать самому (Consul, Vault, service mesh). Для крупной компании — однозначно Kubernetes.

## Задача 2. Redis Cluster (3 шарда × 3 реплики) *

Реализация в `solution/04/redis`:
- `docker-compose.yml` — 6 нод Redis 7.2 (3 мастера + 3 реплики), кластерный режим, AOF;
- `init-cluster.sh` — создание кластера (`redis-cli --cluster create --cluster-replicas 1`), монтируется в `redis-master-01`;
- порты на хосте: мастера 7001–7003, реплики 7004–7006.

```bash
cd solution/04/redis
docker compose up -d
docker compose exec redis-master-01 sh /usr/local/bin/init-cluster.sh

# проверка
redis-cli -h 127.0.0.1 -p 7001 cluster info      # cluster_state:ok
redis-cli -h 127.0.0.1 -p 7001 -c set foo bar    # OK
redis-cli -h 127.0.0.1 -p 7001 -c get foo        # bar
```

Проверено: кластер собрался, все 16384 слота распределены между 3 мастерами, запись/чтение через клиент в кластерном режиме работают.