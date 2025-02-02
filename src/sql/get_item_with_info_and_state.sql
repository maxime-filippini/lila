SELECT
    t.item_id AS id,
    item_actions.action AS user_action,
    item_actions.action_bool AS user_action_book,
    ttt.n_interested,
    ttt.is_reserved,
    tx.name,
    tx.description,
    tx.comment,
    it.average_price,
    it.link
FROM
    (
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
    )
    LEFT JOIN (
        SELECT
            item_id,
            COUNT(*) FILTER (
                WHERE
                    action = 'interested'
            ) AS n_interested,
            BOOL_OR(action = 'will_buy') AS is_reserved
        FROM
            item_actions
        GROUP BY
            item_id
    ) AS ttt ON t.item_id = ttt.item_id
    INNER JOIN item_text AS tx ON t.item_id = tx.item_id
    INNER JOIN items AS it ON it.id = t.item_id
WHERE
    tx.lang = $2