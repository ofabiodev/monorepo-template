-- name: CreateGreeting :one
INSERT INTO greetings (message)
VALUES ($1)
RETURNING *;

-- name: ListGreetings :many
SELECT *
FROM greetings
ORDER BY created_at DESC;
