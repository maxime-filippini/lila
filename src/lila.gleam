import app/router
import gleam/erlang/process
import gleam/io
import lila/cli
import lila/utils
import lila/web.{Context, connect_to_db, static_directory}
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  let args = cli.parse_args()

  let assert Ok(env) = utils.get_env("ENVIRONMENT")
  let env = web.string_to_env(env)

  io.debug(env)

  let assert Ok(secret_key_base) = utils.get_env("WISP_SECRET_KEY_BASE")
  let assert Ok(admin_password) = utils.get_env("LILA_ADMIN_PASSWORD")

  wisp.configure_logger()

  let ctx =
    Context(
      static_directory: static_directory(),
      db: connect_to_db(env),
      admin_password:,
    )

  let handler = router.route_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(args.port)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}
