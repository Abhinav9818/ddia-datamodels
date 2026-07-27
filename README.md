# DDIA Ch.2 — Data Models Exercise (Codespaces + Docker)

## 1. Start the databases

In the Codespace terminal:

```bash
docker-compose up -d
```

Wait ~15-30 seconds for all three containers to be ready, then check:

```bash
docker ps
```

You should see `pg_blog`, `mongo_blog`, and `neo4j_blog` running.

## 2. Postgres

Connect:

```bash
docker exec -it pg_blog psql -U postgres -d blog
```

Then paste the contents of `01_postgres_setup.sql` (or run it directly):

```bash
docker exec -i pg_blog psql -U postgres -d blog < 01_postgres_setup.sql
```

## 3. MongoDB

Connect:

```bash
docker exec -it mongo_blog mongosh
```

Then paste the contents of `02_mongo_setup.js`, or run it directly:

```bash
docker exec -i mongo_blog mongosh < 02_mongo_setup.js
```

## 4. Neo4j

Neo4j needs its Browser UI (Cypher doesn't have a simple stdin runner like the others).

1. In Codespaces, go to the **"Ports"** tab (next to Terminal).
2. Find port **7474**, and click the globe icon to open it in your browser — Codespaces auto-forwards it with a public-ish tunnel URL.
3. Log in with `neo4j` / `password` (from the docker-compose.yml).
4. Paste the contents of `03_neo4j_setup.cypher` into the query box at the top and run it (Neo4j Browser runs each statement separated by `;`).

## 5. What to compare

Run "Query A" and "Query B" in each file and compare:
- How many steps/joins/lookups each one needs
- What the result shape looks like
- Try the exercises noted in comments at the bottom of each script (e.g. the 2-hop "friends of friends" query in Neo4j vs. Postgres vs. Mongo)

## 6. Shutting down

```bash
docker-compose down        # stop containers, keep data
docker-compose down -v     # stop containers AND wipe data volumes
```
