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

/// A row you get from running the `get_unique_item_ids` query
/// defined in `./src/sql/get_unique_item_ids.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUniqueItemIdsRow {
  GetUniqueItemIdsRow(id: String)
}

/// Runs the `get_unique_item_ids` query
/// defined in `./src/sql/get_unique_item_ids.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_unique_item_ids(db) {
  let decoder = {
    use id <- decode.field(0, decode.string)
    decode.success(GetUniqueItemIdsRow(id:))
  }

  let query = "SELECT
    DISTINCT id
FROM
    items"

  pog.query(query)
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
    is_future: Bool,
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
    use is_future <- decode.field(4, decode.bool)
    use item_id <- decode.field(5, decode.string)
    use lang <- decode.field(6, decode.string)
    use name <- decode.field(7, decode.string)
    use description <- decode.field(8, decode.string)
    use comment <- decode.field(9, decode.optional(decode.string))
    decode.success(
      GetItemsRow(
        id:,
        link:,
        average_price:,
        img:,
        is_future:,
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

/// A row you get from running the `get_users_in_waitlist` query
/// defined in `./src/sql/get_users_in_waitlist.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUsersInWaitlistRow {
  GetUsersInWaitlistRow(email: String)
}

/// Runs the `get_users_in_waitlist` query
/// defined in `./src/sql/get_users_in_waitlist.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_users_in_waitlist(db, arg_1) {
  let decoder = {
    use email <- decode.field(0, decode.string)
    decode.success(GetUsersInWaitlistRow(email:))
  }

  let query = "SELECT
    users.email
FROM
    waitlists
    INNER JOIN users ON waitlists.user_id = users.id
WHERE
    item_id = $1"

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
    is_future: Bool,
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
    use is_future <- decode.field(4, decode.bool)
    use item_id <- decode.field(5, decode.string)
    use lang <- decode.field(6, decode.string)
    use name <- decode.field(7, decode.string)
    use description <- decode.field(8, decode.string)
    use comment <- decode.field(9, decode.optional(decode.string))
    decode.success(
      GetSingleItemWithInfoRow(
        id:,
        link:,
        average_price:,
        img:,
        is_future:,
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
    is_future: Bool,
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
    use is_future <- decode.field(4, decode.bool)
    use item_id <- decode.field(5, decode.string)
    use lang <- decode.field(6, decode.string)
    use name <- decode.field(7, decode.string)
    use description <- decode.field(8, decode.string)
    use comment <- decode.field(9, decode.optional(decode.string))
    decode.success(
      GetItemsWithInfoRow(
        id:,
        link:,
        average_price:,
        img:,
        is_future:,
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
