import gleam/string

pub type User {
  User(id: String, name: String, email: String)
}

pub fn parse(s: String) -> Result(User, Nil) {
  let split = string.split(s, ";")

  case split {
    [id, name, email] -> Ok(User(id:, name:, email:))
    _ -> Error(Nil)
  }
}
