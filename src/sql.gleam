import gleam/dynamic/decode
import gleam/option.{type Option}
import pog

/// Runs the `insert_user` query
/// defined in `./src/sql/insert_user.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_user(db, arg_1, arg_2, arg_3) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "INSERT INTO users (id, name, email)
VALUES ($1, $2, $3)"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

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

/// A row you get from running the `get_user_by_email` query
/// defined in `./src/sql/get_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByEmailRow {
  GetUserByEmailRow(id: String, name: String, email: String)
}

/// Runs the `get_user_by_email` query
/// defined in `./src/sql/get_user_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_email(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    use name <- decode.field(1, decode.string)
    use email <- decode.field(2, decode.string)
    decode.success(GetUserByEmailRow(id:, name:, email:))
  }

  let query = "SELECT * 
FROM users
WHERE email = $1
LIMIT 1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `insert_action` query
/// defined in `./src/sql/insert_action.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_action(db, arg_1, arg_2, arg_3, arg_4) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "INSERT INTO item_actions (id, item_id, action, user_id)
VALUES ($1, $2, $3, $4)"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(item_action_encoder(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_items_with_status` query
/// defined in `./src/sql/get_items_with_status.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemsWithStatusRow {
  GetItemsWithStatusRow(
    id: String,
    link: Option(String),
    average_price: Float,
    n_interested: Int,
    is_reserved: Bool,
    name: String,
    description: String,
    comment: Option(String),
  )
}

/// Runs the `get_items_with_status` query
/// defined in `./src/sql/get_items_with_status.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_items_with_status(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    use link <- decode.field(1, decode.optional(decode.string))
    use average_price <- decode.field(2, decode.float)
    use n_interested <- decode.field(3, decode.int)
    use is_reserved <- decode.field(4, decode.bool)
    use name <- decode.field(5, decode.string)
    use description <- decode.field(6, decode.string)
    use comment <- decode.field(7, decode.optional(decode.string))
    decode.success(
      GetItemsWithStatusRow(
        id:,
        link:,
        average_price:,
        n_interested:,
        is_reserved:,
        name:,
        description:,
        comment:,
      ),
    )
  }

  let query = "SELECT
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
    lang = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_items_user_is_interested_in` query
/// defined in `./src/sql/get_items_user_is_interested_in.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemsUserIsInterestedInRow {
  GetItemsUserIsInterestedInRow(item_id: String)
}

/// Runs the `get_items_user_is_interested_in` query
/// defined in `./src/sql/get_items_user_is_interested_in.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_items_user_is_interested_in(db, arg_1) {
  let decoder = {
    use item_id <- decode.field(0, decode.string)
    decode.success(GetItemsUserIsInterestedInRow(item_id:))
  }

  let query = "SELECT
    DISTINCT item_id
FROM
    item_actions
WHERE
    1 = 1
    AND item_actions.action = 'interested'
    AND item_actions.user_id = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Enums -------------------------------------------------------------------

/// Corresponds to the Postgres `item_action` enum.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ItemAction {
  NoLongerReserved
  NoLongerInterested
  AskForInfo
  Interested
  Reserve
}

fn item_action_encoder(variant) {
  case variant {
    NoLongerReserved -> "no_longer_reserved"
    NoLongerInterested -> "no_longer_interested"
    AskForInfo -> "ask_for_info"
    Interested -> "interested"
    Reserve -> "reserve"
  }
  |> pog.text
}
