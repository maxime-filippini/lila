import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/uri
import lila/language.{type Language}
import lila/user.{type User}
import lila/utils
import pog
import sql
import wisp.{type Request, type Response}

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
  Context(static_directory: String, db: pog.Connection, admin_password: String)
}

pub fn static_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("lila")
  priv_directory <> "/static"
}

pub fn connect_to_db(env: Environment) -> pog.Connection {
  let db_url_key = case env {
    Prod -> "PROD_DATABASE_URL"
    Dev -> "DEV_DATABASE_URL"
    Local -> "LOCAL_DATABASE_URL"
  }

  let assert Ok(db_url) = utils.get_env(db_url_key)
  let assert Ok(cfg) = pog.url_config(db_url)

  cfg
  |> pog.pool_size(15)
  |> pog.connect
}

pub fn middleware(
  req: Request,
  ctx: Context,
  handle_request: fn(Request) -> Response,
) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  handle_request(req)
}

pub fn parse_query_params(req: Request) -> Result(List(#(String, String)), Nil) {
  case req.query {
    None -> Ok([])
    Some(query) -> uri.parse_query(query)
  }
}

fn or_400(result: Result(value, error), next: fn(value) -> Response) -> Response {
  case result {
    Ok(value) -> next(value)
    Error(_) -> wisp.bad_request()
  }
}

pub fn with_query_params(
  req: Request,
  next handler: fn(wisp.Request, List(#(String, String))) -> Response,
) -> Response {
  use params <- or_400(parse_query_params(req))
  handler(req, params)
}

pub fn with_hx_target(
  req: Request,
  next handler: fn(wisp.Request, Option(String)) -> Response,
) -> Response {
  let target = case list.key_find(req.headers, "hx-target") {
    Ok(header) -> Some(header)
    _ -> None
  }

  handler(req, target)
}

pub fn with_user(
  req: Request,
  next handler: fn(Request, Option(User)) -> Response,
) -> Response {
  let user = case wisp.get_cookie(req, "user", wisp.Signed) {
    Ok(v) -> {
      case user.parse(v) {
        Ok(w) -> Some(w)
        _ -> None
      }
    }
    _ -> None
  }

  handler(req, user)
}

pub fn validate_lang(
  req: Request,
  lang_iso: String,
  next handler: fn(Request, Language) -> Response,
) -> Response {
  case language.from_iso(lang_iso) {
    Ok(v) -> handler(req, v)
    Error(_) -> wisp.redirect(req.path <> "?lang=en")
  }
}

pub fn get_item_info(
  req: Request,
  ctx: Context,
  id: String,
  lang: Language,
  next handler: fn(Request, sql.GetSingleItemWithInfoRow) -> Response,
) -> Response {
  let assert Ok(pog.Returned(_count, rows)) =
    sql.get_single_item_with_info(ctx.db, id, language.to_iso(lang))

  io.debug(rows)

  case rows {
    [] -> wisp.not_found()
    [v, ..] -> handler(req, v)
  }
}

pub fn require_user(
  req: Request,
  maybe_user: Option(User),
  next handler: fn(Request, User) -> Response,
) -> Response {
  case maybe_user {
    Some(u) -> handler(req, u)
    None -> wisp.response(401)
  }
}
