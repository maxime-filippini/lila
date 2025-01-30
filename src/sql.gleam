import gleam/dynamic/decode
import gleam/option.{type Option}
import pog

/// A row you get from running the `get_items` query
/// defined in `./src/sql/get_items.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemsRow {
  GetItemsRow(
    id: String,
    link: Option(String),
    average_price: Float,
    item_id: String,
    lang: String,
    name: String,
    description: String,
    comment: Option(String),
  )
}

/// Runs the `get_items` query
/// defined in `./src/sql/get_items.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_items(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    use link <- decode.field(1, decode.optional(decode.string))
    use average_price <- decode.field(2, decode.float)
    use item_id <- decode.field(3, decode.string)
    use lang <- decode.field(4, decode.string)
    use name <- decode.field(5, decode.string)
    use description <- decode.field(6, decode.string)
    use comment <- decode.field(7, decode.optional(decode.string))
    decode.success(
      GetItemsRow(
        id:,
        link:,
        average_price:,
        item_id:,
        lang:,
        name:,
        description:,
        comment:,
      ),
    )
  }

  let query = "SELECT *
FROM items
INNER JOIN item_text
    ON items.id = item_text.item_id
WHERE lang = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}
