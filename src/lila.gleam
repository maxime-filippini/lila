import app/router
import envoy
import gleam/erlang/process
import lila/cli
import lila/web.{Context, db, static_directory}
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  let args = cli.parse_args()

  let assert Ok(_env) = envoy.get("ENVIRONMENT")
  let assert Ok(secret_key_base) = envoy.get("WISP_SECRET_KEY_BASE")

  wisp.configure_logger()

  let ctx = Context(static_directory: static_directory(), db: db())

  let handler = router.route_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(args.port)
    // |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}
