import lila/user.{type User}
import pog
import sql
import wisp.{type Request}
import youid/uuid

pub fn insert_user_if_not_in_db(
  req: Request,
  db: pog.Connection,
  name: String,
  email: String,
) -> User {
  let assert Ok(pog.Returned(_count, rows)) = sql.get_user_by_email(db, email)

  case rows {
    [] -> {
      let uuid = uuid.v4_string()
      let assert Ok(pog.Returned(_count, _rows)) =
        sql.insert_user(db, uuid, name, email)

      insert_user_if_not_in_db(req, db, name, email)
      // Try again
    }
    [v] -> user.User(v.id, v.name, v.email)
    _ -> panic
  }
}
