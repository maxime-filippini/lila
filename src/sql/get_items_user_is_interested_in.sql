SELECT
    DISTINCT item_id
FROM
    item_actions
WHERE
    1 = 1
    AND item_actions.action = 'interested'
    AND item_actions.user_id = $1