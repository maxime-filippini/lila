SELECT
    users.email
FROM
    waitlists
    INNER JOIN users ON waitlists.user_id = users.id
WHERE
    item_id = $1