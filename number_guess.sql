DROP TABLE IF EXISTS games, players;

CREATE TABLE players (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE games (
    game_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES players(user_id) ON DELETE CASCADE,
    number_of_guesses INTEGER,
    secret_number INTEGER
);

SELECT pg_catalog.setval('players_user_id_seq', 1, false);
SELECT pg_catalog.setval('games_game_id_seq', 1, false);
