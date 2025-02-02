SELECT
    user_id
FROM
    waitlists
WHERE
    item_id = $1
ORDER BY
    timestamp ASC