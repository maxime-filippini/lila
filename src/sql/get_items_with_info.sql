SELECT *
FROM items
INNER JOIN item_text
ON items.id = item_text.item_id
WHERE
    item_text.lang = $1