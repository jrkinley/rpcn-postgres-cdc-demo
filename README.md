# Redpanda Connect Postgres CDC Demo

### Spin up the environment

```bash
docker compose up -d
[+] Running 8/8
 ✔ Network rpcn-postgres-cdc-demo_redpanda_network  Created
 ✔ Volume "rpcn-postgres-cdc-demo_redpanda"         Created
 ✔ Volume "rpcn-postgres-cdc-demo_postgres_data"    Created
 ✔ Container postgres_db                            Healthy
 ✔ Container redpanda                               Healthy
 ✔ Container redpanda-register-schema               Started
 ✔ Container redpanda-console                       Started
 ✔ Container redpanda-connect                       Started
```

### Check data files have been copied into Postgres database

```bash
docker exec -it postgres_db psql -U postgres

SELECT * FROM quotes WHERE symbol = 'AAPL' ORDER BY date DESC LIMIT 5;

 id | symbol |    date    |  close  |  volume  |   open   |  high   |   low
----+--------+------------+---------+----------+----------+---------+---------
  1 | AAPL   | 2024-12-05 | $243.04 | 40033880 | $243.99  | $244.54 | $242.13
  2 | AAPL   | 2024-12-04 | $243.01 | 44383940 | $242.87  | $244.11 | $241.25
  3 | AAPL   | 2024-12-03 | $242.65 | 38861020 | $239.81  | $242.76 | $238.90
  4 | AAPL   | 2024-12-02 | $239.59 | 48137100 | $237.27  | $240.79 | $237.16
  5 | AAPL   | 2024-11-29 | $237.33 | 28481380 | $234.805 | $237.81 | $233.97
(5 rows)

SELECT symbol, min(date) AS min_date, max(date) AS max_date, count(*) FROM quotes GROUP BY symbol;

 symbol |  min_date  |  max_date  | count
--------+------------+------------+-------
 AAPL   | 2014-12-08 | 2024-12-05 |  2516
 MSFT   | 2014-12-08 | 2024-12-05 |  2516
 META   | 2014-12-08 | 2024-12-05 |  2516
(3 rows)
```

### Check database snapshot has been streamed into Redpanda topics:

http://localhost:8080/topics

### Insert new record to trigger change capture

```bash
INSERT INTO quotes VALUES (default, 'AAPL', '2024-12-06', '$243.00', 36870620, '$242.905', '$244.63', '$242.08');
UPDATE quotes SET close='$242.84' WHERE date='2024-12-06';

SELECT * FROM quotes WHERE symbol = 'AAPL' ORDER BY date DESC LIMIT 5;

  id  | symbol |    date    |  close  |  volume  |   open   |  high   |   low
------+--------+------------+---------+----------+----------+---------+---------
 7549 | AAPL   | 2024-12-06 | $242.84 | 36870620 | $242.905 | $244.63 | $242.08
    1 | AAPL   | 2024-12-05 | $243.04 | 40033880 | $243.99  | $244.54 | $242.13
    2 | AAPL   | 2024-12-04 | $243.01 | 44383940 | $242.87  | $244.11 | $241.25
    3 | AAPL   | 2024-12-03 | $242.65 | 38861020 | $239.81  | $242.76 | $238.90
    4 | AAPL   | 2024-12-02 | $239.59 | 48137100 | $237.27  | $240.79 | $237.16
```

### Check change has been captured in Redpanda:

http://localhost:8080/topics/quotes_AAPL

```bash
rpk topic consume quotes_AAPL -o -1 -n 1 --use-schema-registry

{
  "topic": "quotes_AAPL",
  "value": "{\"date\":\"2024-12-06T00:00:00Z\",\"close\":\"$242.84\",\"volume\":36870620,\"open\":\"$242.905\",\"high\":\"$244.63\",\"low\":\"$242.08\",\"id\":7549,\"symbol\":\"AAPL\"}",
  "timestamp": 1748369377706,
  "partition": 0,
  "offset": 2516
}
```

### Shutdown and cleanup

```bash
docker compose down -v
```
