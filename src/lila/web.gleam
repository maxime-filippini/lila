import lila/utils
import pog
import wisp

pub type Environment {
  Local
  Dev
  Prod
}

pub fn string_to_env(s: String) {
  case s {
    "PROD" -> Prod
    "DEV" -> Dev
    "LOCAL" -> Local
    _ -> Local
  }
}

pub type Context {
  Context(static_directory: String, db: pog.Connection)
}

pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("lila")
  priv_directory <> "/static"
}

pub fn connect_to_db(env: Environment) -> pog.Connection {
  let db_url = case env {
    Prod -> "PROD_DATABASE_URL"
    Dev -> "DEV_DATABASE_URL"
    Local -> "LOCAL_DATABASE_URL"
  }

  let assert Ok(db_url) = utils.get_env(db_url)
  let assert Ok(cfg) = pog.url_config(db_url)

  cfg
  |> pog.pool_size(15)
  |> pog.connect
}

pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  handle_request(req)
}
