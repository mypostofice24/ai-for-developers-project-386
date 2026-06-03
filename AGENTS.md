# AGENTS.md

## Project Context

This is a учебный Design First проект календарного бронирования. API-контракт
фиксируется до реализации и остается источником правды для фронтенда и бэкенда.

Основной контракт:

- TypeSpec: `spec/main.tsp`
- Описание домена и покрытия сценариев: `docs/api-contract.md`
- Генерация OpenAPI: `npm run compile:spec`
- Генерация frontend-типов: `npm run generate:web-types`
- Mock API по контракту: `npm run mock:api`

## Frontend Stack Decision

Фронтенд реализуется как отдельная часть приложения.

Выбранный стек:

- Nuxt 4
- Vue 3
- TypeScript
- Nuxt UI
- REST composables для работы с API
- API base через env-переменную, например `NUXT_PUBLIC_API_BASE`
- generated TypeScript types from OpenAPI через `openapi-typescript`

Dev defaults:

- frontend: `http://localhost:3000`
- API mock/backend: `http://localhost:3001`
- если порт занят, временно использовать `WEB_PORT` или `MOCK_API_PORT`

Не переносить из других проектов без отдельного решения:

- `/api/v1` prefix
- backend workspace/monorepo инфраструктуру
- Pinia, если нет сложного состояния
- auth
- SSE
- Docker, Redis, BullMQ, PostgreSQL, Prisma, NestJS

Backend stack на этом шаге не выбран. Не добавлять backend framework, базу
данных, auth, очереди, Docker или API prefix без отдельного решения.

## API Usage Rules

Фронтенд должен работать только через API по контракту:

- `GET /event-types`
- `GET /event-types/{eventTypeId}/slots`
- `POST /bookings`
- `GET /admin/event-types`
- `POST /admin/event-types`
- `GET /admin/bookings`

Не добавлять новые endpoints и не менять wire-format без предварительного
обновления TypeSpec-контракта.

Если UI или backend требует новое поле, endpoint или статус ответа, сначала
обновить `spec/main.tsp`, затем выполнить:

- `npm run compile:spec`
- `npm run generate:web-types`

Prism используется как контрактный mock server, а не как stateful backend.
После `POST` UI может показывать успешное состояние из response, но не должен
ожидать, что Prism сохранит созданную запись в последующих `GET`.

## Documentation Language

Идентификаторы API, URL, имена моделей, поля и error codes остаются на
английском. Человекочитаемая документация и пояснения могут быть на русском.
