# Домашние задания по теме «Микросервисная архитектура»

Тексты заданий лежат в корне, решения — в каталоге `solution/` (по одному на каждую лекцию). Обязательные задачи — без звёздочки, задачи со звёздочкой (*) дополнительные.

| Лекция | Текст | Решение |
|---|---|---|
| Введение в микросервисы | [11-microservices-01-intro.md](11-microservices-01-intro.md) | — |
| Принципы | [11-microservices-02-principles.md](11-microservices-02-principles.md) | [solution/02](solution/02/solution.md) |
| Подходы | [11-microservices-03-approaches.md](11-microservices-03-approaches.md) | [solution/03](solution/03/solution.md) |
| Масштабирование | [11-microservices-04-scaling.md](11-microservices-04-scaling.md) | [solution/04](solution/04/solution.md) |

## Как запустить

Любое решение поднимается через Docker Compose, команды запуска — в соответствующих отчётах.

```bash
# solution/02 — API Gateway (нужен и для логирования, и для мониторинга из solution/03)
cd solution/02 && docker compose up --build

# solution/03 — логи (Vector + ELK), мониторинг (Prometheus + Grafana)
cd solution/03 && docker compose -f docker-compose.logs.yaml up --build
cd solution/03 && docker compose -f docker-compose.monitoring.yaml up -d

# solution/04 — Redis Cluster (3 шарда × 3 реплики)
cd solution/04/redis && docker compose up -d
docker compose exec redis-master-01 sh /usr/local/bin/init-cluster.sh
```

Пароли в демо-стендах: Kibana/Grafana — `admin` / `qwerty123456`.