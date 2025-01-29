import envoy
import gleam/io
import lila/cli
import lila/web.{Context, db, static_directory}
import wisp

pub fn main() {
  let _args = cli.parse_args()

  let assert Ok(_env) = envoy.get("ENVIRONMENT")
  let assert Ok(_secret_key_base) = envoy.get("WISP_SECRET_KEY_BASE")

  wisp.configure_logger()

  let ctx = Context(static_directory: static_directory(), db: db())

  io.debug(ctx)
}
