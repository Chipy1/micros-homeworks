# ДЗ «Микросервисы: подходы»

## Задача 1. Обеспечить разработку

**Выбор: GitLab CE/EE + GitLab CI/CD**

Одной системой закрываются: Git-хостинг, по репозиторию на сервис, сборка по событиям и по кнопке, шаблоны сборок, переменные окружения и секреты (masked/protected), свой container registry, свои раннеры на любых серверах и параллельные сборки. Ставится и в облаке, и на своих серверах — вендор-лок минимален.

Альтернативы: GitHub Actions (удобно, но привязка к GitHub), TeamCity/Jenkins (классика, но обычно приходится докупать части пазла). GitLab — всё в одном месте.

## Задача 2. Логи

**Выбор: Vector → Elasticsearch → Kibana** (реализовано в `docker-compose.logs.yaml`)

- **Vector** — агент: читает stdout контейнеров через Docker API (собираются контейнеры с меткой `logging=vector` — она проставлена сервисам в solution/02) и гарантированно доставляет логи в ES (батчи, ретраи). Сервисы менять не нужно — просто пишут в stdout.
- **Elasticsearch** — центральное хранилище, индекс `logs-YYYY.MM.DD`, поиск. ES запускается с секьюрити, пароль `elastic` = `qwerty123456`, дополнительно создаётся пользователь `admin`.
- **Kibana** — веб-интерфейс на `localhost:8081` (admin / `qwerty123456`): поиск, фильтры, дашборды, сохранённые поиски со ссылками.

```bash
cd solution/03
# сначала поднять API Gateway (solution/02)
docker compose -f docker-compose.logs.yaml up --build
# Kibana: http://localhost:8081, admin / qwerty123456
```

Проверено: логи сервисов (security/uploader/gateway) собираются Vector и ложатся в индекс `logs-*` в ES, видны в Kibana.

## Задача 3. Мониторинг

**Выбор: Prometheus + Grafana** (реализовано в `docker-compose.monitoring.yaml`)

- Prometheus собирает метрики: специфичные для сервиса (в `security`/`uploader` уже есть `/metrics` с RPS, задержками и ошибками); при желании добавляются хостовые метрики (node_exporter на `host.docker.internal:9100`).
- Grafana — запросы, агрегация, настраиваемые панели; готовый дашборд «распределение запросов по сервисам» подключается автоматически через provisioning.

```bash
cd solution/03
# сначала поднять API Gateway (solution/02)
docker compose -f docker-compose.monitoring.yaml up -d
# Grafana: http://localhost:8081, admin / qwerty123456
```

Проверено: Prometheus опрашивает `security:3000/metrics` и `uploader:3000/metrics`, метрики RPS/латентности отдаются и агрегируются (p95).

```bash
cd solution/03
docker compose -f docker-compose.monitoring.yaml up -d
# Grafana: http://localhost:8081, admin / qwerty123456
```

## Задачи 4–5 (реализованы)

| Задача | Что сделано |
|---|---|
| 4. Логи * | `docker-compose.logs.yaml`: Vector + ElasticSearch + Kibana, Kibana на `localhost:8081`, admin/`qwerty123456` |
| 5. Мониторинг * | `docker-compose.monitoring.yaml`: Prometheus + Grafana, Grafana на `localhost:8081`, admin/`qwerty123456`, dashboards через provisioning |