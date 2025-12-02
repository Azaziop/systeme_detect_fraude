# Verifying Postgres connectivity for transaction_service

This file shows quick steps to verify that the `transaction_service` uses the Postgres instance from the repo `docker-compose.yml`.

Prerequisites
- Docker and docker-compose (or `docker compose`) installed and running.

Steps (local with docker-compose)
1. Bring up the stack (the `postgres` container is defined in repo `docker-compose.yml`):

```powershell
# from repo root
docker compose up -d
```

2. Confirm the Postgres container is healthy:

```powershell
docker ps
# check logs or health
docker logs -f postgres-db
# quick readiness probe
docker exec -it postgres-db pg_isready -U postgres
```

3. Check that `transaction-service` container is using Postgres (after compose up):

```powershell
# inspect transaction-service env
docker exec -it transaction-service env | findstr DATABASE_URL
```

4. Verify within the `transaction_service` container that SQLAlchemy can connect

```powershell
# run a simple python check inside the container
docker exec -it transaction-service python -c "from transaction_service import models; print('engine:', models.engine)
from sqlalchemy import text
from sqlalchemy import create_engine
engine = models.engine
with engine.connect() as conn:
    res = conn.execute(text('SELECT version();'))
    print(list(res))"
```

If the command prints a Postgres version, the connection is OK.

Notes
- docker-compose sets the service environment DATABASE_URL to:
  `postgresql://postgres:postgres@postgres:5432/fraud_detection`
  so the transaction service will use the `fraud_detection` database provided by the `postgres` container.
- If you need separate databases, adjust the `postgres` service environment (or add init scripts) and update `DATABASE_URL`.
- When deploying to Kubernetes, prefer using a managed Postgres or add a `StatefulSet` and `Service`, and store DB credentials in `Secrets` rather than environment strings in manifests.
