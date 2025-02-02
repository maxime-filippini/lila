import gleam/dynamic/decode
import gleam/option.{type Option}
import pog

/// A row you get from running the `get_item_waitlist` query
/// defined in `./src/sql/get_item_waitlist.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemWaitlistRow {
  GetItemWaitlistRow(user_id: String)
}

/// Runs the `get_item_waitlist` query
/// defined in `./src/sql/get_item_waitlist.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_item_waitlist(db, arg_1) {
  let decoder = {
    use user_id <- decode.field(0, decode.string)
    decode.success(GetItemWaitlistRow(user_id:))
  }

  let query = "SELECT
    user_id
FROM
    waitlists
WHERE
    item_id = $1
ORDER BY
    timestamp ASC"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `insert_to_waitlist` query
/// defined in `./src/sql/insert_to_waitlist.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_to_waitlist(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "INSERT INTO
    waitlists (item_id, user_id)
VALUES
    ($1, $2)"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

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
    img: String,
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
    use img <- decode.field(3, decode.string)
    use item_id <- decode.field(4, decode.string)
    use lang <- decode.field(5, decode.string)
    use name <- decode.field(6, decode.string)
    use description <- decode.field(7, decode.string)
    use comment <- decode.field(8, decode.optional(decode.string))
    decode.success(
      GetItemsRow(
        id:,
        link:,
        average_price:,
        img:,
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

/// Runs the `remove_user_from_waitlist` query
/// defined in `./src/sql/remove_user_from_waitlist.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn remove_user_from_waitlist(db, arg_1, arg_2) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  let query = "DELETE FROM
    waitlists
WHERE
    1 = 1
    AND user_id = $1
    AND item_id = $2"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
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

/// A row you get from running the `get_items_waitlists` query
/// defined in `./src/sql/get_items_waitlists.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemsWaitlistsRow {
  GetItemsWaitlistsRow(item_id: String, user_id: String)
}

/// Runs the `get_items_waitlists` query
/// defined in `./src/sql/get_items_waitlists.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_items_waitlists(db) {
  let decoder = {
    use item_id <- decode.field(0, decode.string)
    use user_id <- decode.field(1, decode.string)
    decode.success(GetItemsWaitlistsRow(item_id:, user_id:))
  }

  let query = "SELECT
    item_id,
    user_id
FROM
    waitlists
ORDER BY
    timestamp ASC"

  pog.query(query)
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_single_item_with_info` query
/// defined in `./src/sql/get_single_item_with_info.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetSingleItemWithInfoRow {
  GetSingleItemWithInfoRow(
    id: String,
    link: Option(String),
    average_price: Float,
    img: String,
    item_id: String,
    lang: String,
    name: String,
    description: String,
    comment: Option(String),
  )
}

/// Runs the `get_single_item_with_info` query
/// defined in `./src/sql/get_single_item_with_info.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_single_item_with_info(db, arg_1, arg_2) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    use link <- decode.field(1, decode.optional(decode.string))
    use average_price <- decode.field(2, decode.float)
    use img <- decode.field(3, decode.string)
    use item_id <- decode.field(4, decode.string)
    use lang <- decode.field(5, decode.string)
    use name <- decode.field(6, decode.string)
    use description <- decode.field(7, decode.string)
    use comment <- decode.field(8, decode.optional(decode.string))
    decode.success(
      GetSingleItemWithInfoRow(
        id:,
        link:,
        average_price:,
        img:,
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
WHERE
    1=1
    AND items.id = $1
    AND item_text.lang = $2"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_item_with_info_and_state` query
/// defined in `./src/sql/get_item_with_info_and_state.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemWithInfoAndStateRow {
  GetItemWithInfoAndStateRow(
    id: String,
    user_action: ItemActionOld,
    user_action_book: Bool,
    n_interested: Int,
    is_reserved: Bool,
    name: String,
    description: String,
    comment: Option(String),
    average_price: Float,
    link: Option(String),
  )
}

/// Runs the `get_item_with_info_and_state` query
/// defined in `./src/sql/get_item_with_info_and_state.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_item_with_info_and_state(db, arg_1, arg_2) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    use user_action <- decode.field(1, item_action_old_decoder())
    use user_action_book <- decode.field(2, decode.bool)
    use n_interested <- decode.field(3, decode.int)
    use is_reserved <- decode.field(4, decode.bool)
    use name <- decode.field(5, decode.string)
    use description <- decode.field(6, decode.string)
    use comment <- decode.field(7, decode.optional(decode.string))
    use average_price <- decode.field(8, decode.float)
    use link <- decode.field(9, decode.optional(decode.string))
    decode.success(
      GetItemWithInfoAndStateRow(
        id:,
        user_action:,
        user_action_book:,
        n_interested:,
        is_reserved:,
        name:,
        description:,
        comment:,
        average_price:,
        link:,
      ),
    )
  }

  let query = "SELECT
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
    tx.lang = $2"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_items_with_info` query
/// defined in `./src/sql/get_items_with_info.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemsWithInfoRow {
  GetItemsWithInfoRow(
    id: String,
    link: Option(String),
    average_price: Float,
    img: String,
    item_id: String,
    lang: String,
    name: String,
    description: String,
    comment: Option(String),
  )
}

/// Runs the `get_items_with_info` query
/// defined in `./src/sql/get_items_with_info.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_items_with_info(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    use link <- decode.field(1, decode.optional(decode.string))
    use average_price <- decode.field(2, decode.float)
    use img <- decode.field(3, decode.string)
    use item_id <- decode.field(4, decode.string)
    use lang <- decode.field(5, decode.string)
    use name <- decode.field(6, decode.string)
    use description <- decode.field(7, decode.string)
    use comment <- decode.field(8, decode.optional(decode.string))
    decode.success(
      GetItemsWithInfoRow(
        id:,
        link:,
        average_price:,
        img:,
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
WHERE
    item_text.lang = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_state_for_item` query
/// defined in `./src/sql/get_user_state_for_item.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserStateForItemRow {
  GetUserStateForItemRow(action: ItemActionOld, action_bool: Bool)
}

/// Runs the `get_user_state_for_item` query
/// defined in `./src/sql/get_user_state_for_item.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_state_for_item(db, arg_1, arg_2) {
  let decoder = {
    use action <- decode.field(0, item_action_old_decoder())
    use action_bool <- decode.field(1, decode.bool)
    decode.success(GetUserStateForItemRow(action:, action_bool:))
  }

  let query = "SELECT
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
    item_actions.item_id = $2"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Enums -------------------------------------------------------------------

/// Corresponds to the Postgres `item_action_old` enum.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ItemActionOld {
  WillBuy
  Interested
}

fn item_action_old_decoder() {
  use variant <- decode.then(decode.string)
  case variant {
    "will_buy" -> decode.success(WillBuy)
    "interested" -> decode.success(Interested)
    _ -> decode.failure(WillBuy, "ItemActionOld")
  }
}
