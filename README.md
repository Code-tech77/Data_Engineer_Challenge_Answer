# Data Engineer Challenge

My solution to the Data Engineer Challenge. It uses SQL on three international football datasets.

## Repository contents

| File | Description |
|---|---|
| `results.csv` | Match results (date, teams, score, tournament, venue) |
| `goalscorers.csv` | Individual goals (scorer, minute, own goal, penalty) |
| `shootouts.csv` | Penalty shootouts (winner, first shooter) |
| `queries.sql` | All SQL queries for the objectives |
| `answers` | Queries, results and notes for each objective |

## Objectives completed

1. **Average goals per game (1900–2000)**: 3.07 goals per game across 23,712 matches.
2. **Shootout wins by country**: 163 countries, listed alphabetically.
3. **Reliable join key**: a `match_key` built from `date | home_team | away_team`, trimmed and lower-cased, then saved as an indexed column on all three tables.
4. **Shootout wins after a 1-1 draw**: 225 shootouts, won by 115 different teams.

## Approach

1. **Profile the data.** I checked row counts, date ranges, missing values and duplicates.
2. **Find the grain.** No file has an ID, but `(date, home_team, away_team)` appears in all three, so I tested it as the match key.
3. **Build and validate the key.**
   - All 43,189 goalscorer rows match a result.
   - 561 of the 562 shootouts match a result.
4. **Write and check each query.** I sanity-checked every result before recording it.

## Data quality issues found

- **Duplicate fixtures:** 2 matches appear twice in `results.csv` with different scores (Tahiti v New Caledonia, 1974; Guyana v Barbados, 1977).
- **Orphan shootout:** 1 shootout (Saare County v Åland Islands, 2011-06-29) has no matching result.
- **Inconsistent team names:** the same team appears as both `Åland` and `Åland Islands`.

## How to run

```bash
# Load the CSVs into SQLite
sqlite3 football.db <<'EOF'
.mode csv
.import results.csv results
.import goalscorers.csv goalscorers
.import shootouts.csv shootouts
EOF

# Run the queries
sqlite3 -header -column football.db < queries.sql
```

The SQL is ANSI-style, so it runs on PostgreSQL or SQL Server with small changes.

## Tools

- SQLite
- Python (to load the data and check results)