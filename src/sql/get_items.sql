SELECT *
FROM items
INNER JOIN item_text
    ON items.id = item_text.item_id
WHERE lang = $1