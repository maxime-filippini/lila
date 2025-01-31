SELECT
    id,
    link,
    average_price,
    n_interested,
    is_reserved,
    item_text.name,
    item_text.description,
    item_text.comment
FROM
    items
    LEFT JOIN (
        SELECT
            item_id,
            COUNT(*) FILTER (
                WHERE
                    action = 'interested'
            ) AS n_interested,
            BOOL_OR(action = 'reserve') AS is_reserved
        FROM
            item_actions
        GROUP BY
            item_id
    ) AS actions ON items.id = actions.item_id
    INNER JOIN item_text ON items.id = item_text.item_id
WHERE
    lang = $1