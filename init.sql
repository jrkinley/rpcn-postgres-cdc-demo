CREATE TABLE "quotes" (
    "id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    "symbol" text NOT NULL,
    "date" date NOT NULL,
    "close" text NOT NULL,
    "volume" integer NOT NULL,
    "open" text NOT NULL,
    "high" text NOT NULL,
    "low" text NOT NULL
);

\copy quotes(symbol, date, close, volume, open, high, low) from '/docker-entrypoint-initdb.d/data/AAPL_historical_max.csv' csv header;
\copy quotes(symbol, date, close, volume, open, high, low) from '/docker-entrypoint-initdb.d/data/META_historical_max.csv' csv header;
\copy quotes(symbol, date, close, volume, open, high, low) from '/docker-entrypoint-initdb.d/data/MSFT_historical_max.csv' csv header;
