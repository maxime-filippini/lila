import envoy
import gleam/string
import pog
import wisp

pub type Context {
  Context(static_directory: String, db: pog.Connection)
}

pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("lila")
  priv_directory <> "/static"
}

pub fn db() -> pog.Connection {
  let assert Ok(db_url) = envoy.get("DATABASE_URL")
  let assert Ok(cfg) = pog.url_config(string.trim_end(db_url))

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
