# ДЗ «Микросервисы: принципы»

## Задача 1. API Gateway

**Выбор: Nginx (opensource)**

| — | Nginx | Kong | Traefik | Envoy | HAProxy | Облачные шлюзы |
|---|---|---|---|---|---|---|
| Маршрутизация по конфигу | + | + | + | + | + | + |
| Проверка токена | + (`auth_request`) | + (плагин jwt) | + | + | − | + |
| HTTPS | + | + | + | + | + | + |
| Динамический конфиг | − (reload) | + | + | + | + | + |
| Вендор-лок | нет | нет | нет | нет | нет | да |
| Сложность | низкая | средняя | низкая | высокая | средняя | низкая |

**Почему Nginx:** бесплатен, не привязывает к вендору, хорошо знаком команде, легко разворачивается в Docker/K8s. Всё, что нужно для API Gateway — маршрутизацию, проверку токена через `auth_request` и TLS — закрывает «из коробки». Kong/Traefik/Envoy для текущего масштаба избыточны, а облачные шлюзы создают вендор-лок.

## Задача 2. Брокер сообщений

**Выбор: RabbitMQ**

| — | RabbitMQ | Kafka | Redis | NATS |
|---|---|---|---|---|
| Кластеризация | + | + | + | + |
| Хранение на диске | + | + | + | partial |
| Скорость | высокая | очень высокая | очень высокая | очень высокая |
| Права на потоки | + (vhosts/queues) | + (ACL) | partial | + |
| Простота эксплуатации | низкая | высокая | низкая | низкая |

**Почему RabbitMQ:** покрывает все требования (кластеризация, персистентность на диск, скорость, права), при этом самый простой в эксплуатации среди «взрослых» брокеров — легче поднять, отличная документация и понятная веб-консоль. Kafka оправдана для больших потоков и stream-обработки, но администрировать её заметно сложнее — для текущих задач избыточно.

## Задача 3. Реализация API Gateway

Сервисы: `gateway` (Nginx), `security` (авторизация), `uploader` (загрузка файлов), `storage` (MinIO, бакет `images`). Запуск — `docker compose up --build`.

**Маршруты:**

| Эндпоинт | Токен | Куда |
|---|---|---|
| `POST /v1/register`, `POST /v1/token` (+ `/token`) | не нужен | `security` |
| `GET /v1/user` | нужен (через `auth_request`) | `security` |
| `POST /v1/upload` (+ `/upload`) | нужен (через `auth_request`) | `uploader` |
| `GET /v1/user/{img}` | нужен (через `auth_request`) | `storage` |
| `GET /images/{img}` | не нужен | `storage` |

Проверка токена: Nginx на защищённых маршрутах делает внутренний запрос `auth_request /auth` → `security GET /v1/token/validation`; ответ, отличный от 2xx, блокирует доступ.

**Что добавлено в сервисы относительно заглушек:**
- `security`: эндпоинты `POST /v1/user` (регистрация) и `GET /v1/user`; валидация токена теперь отдаёт 401 вместо 200.
- бакет MinIO — `images` (по заданию).

**Проверка:**
```bash
# логин
curl -X POST -d '{"login":"bob","password":"qwe123"}' -H 'Content-Type: application/json' http://localhost/token
TOKEN=<...>

# загрузка файла
curl -X POST -H "Authorization: Bearer $TOKEN" -H 'Content-Type: octet/stream' \
  --data-binary @photo.png http://localhost/v1/upload

# без токена -> 401
curl -o /dev/null -w '%{http_code}' --data-binary @photo.png http://localhost/upload
```