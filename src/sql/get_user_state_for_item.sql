SELECT
    item_actions.action,
    item_actions.action_bool
FROM
    item_actions
    INNER JOIN (
        SELECT
            item_id,
            action,
            MAX(created_at) AS timestamp
        FROM
            item_actions
        WHERE
            user_id = $1
        GROUP BY
            item_id,
            action
    ) AS t ON item_actions.item_id = t.item_id
    AND item_actions.action = t.action
    AND item_actions.created_at = t.timestamp
WHERE
    item_actions.item_id = $2