SELECT *
FROM items
INNER JOIN item_text
ON items.id = item_text.item_id
WHERE
    1=1
    AND items.id = $1
    AND item_text.lang = $2