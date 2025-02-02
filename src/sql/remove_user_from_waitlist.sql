DELETE FROM
    waitlists
WHERE
    1 = 1
    AND user_id = $1
    AND item_id = $2