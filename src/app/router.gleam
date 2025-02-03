import app/admin
import app/auth_page
import app/crud
import app/list_page
import gleam/http.{Get, Post}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/uri
import lila/language.{type Language}
import lila/user.{type User}
import lila/utils
import lila/web
import pog
import sql
import wisp.{type Request, type Response}

// Route handlers -----------------------------------------

pub fn route_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)
  use req, query_params <- web.with_query_params(req)
  use req, maybe_user <- web.with_user(req)

  case req.method, wisp.path_segments(req), query_params {
    // Index page
    Get, [], [#("lang", lang)] -> handle_index_route(req, ctx, lang)
    Get, [], _ -> wisp.redirect("/?lang=en")

    // Auth
    Get, ["auth"], [#("lang", lang)] -> handle_auth_route(req, lang)
    Get, ["auth"], _ -> wisp.redirect("/auth?lang=en")
    Post, ["auth"], _ -> {
      store_auth(req, ctx.db, query_params)
    }

    // Item
    _, ["item", ..segments], _ -> {
      handle_item_routes(req, ctx, segments:, query_params:, maybe_user:)
    }

    // Admin
    _, ["admin", ..segments], [#("lang", lang)] ->
      handle_admin_route(req, ctx, segments, lang)

    _, _, _ -> wisp.not_found()
  }
}

fn handle_item_routes(
  req: Request,
  ctx: web.Context,
  segments segments: List(String),
  query_params query_params: List(#(String, String)),
  maybe_user maybe_user: Option(User),
) -> Response {
  case req.method, segments, query_params {
    Post, [item_id, "add-to-wait-list"], [#("lang", lang_iso)] -> {
      use req, lang <- web.validate_lang(req, lang_iso)
      handle_add_to_waitlist(req:, ctx:, item_id:, maybe_user:, lang:)
    }

    Post, [item_id, "remove-from-wait-list"], [#("lang", lang_iso)] -> {
      use req, lang <- web.validate_lang(req, lang_iso)
      handle_remove_from_waitlist(req:, ctx:, item_id:, maybe_user:, lang:)
    }

    Get, [item_id, "user-actions"], [#("lang", lang_iso)] -> {
      handle_user_actions(req, ctx, item_id, lang_iso)
    }
    _, _, _ -> wisp.not_found()
  }
}

fn handle_admin_route(
  req: Request,
  ctx: web.Context,
  segments: List(String),
  lang_iso: String,
) -> Response {
  use req, lang <- web.validate_lang(req, lang_iso)

  case segments {
    [] -> admin.admin_page(req.path, lang) |> utils.page_to_response
    _ -> panic
  }
}

fn handle_user_actions(
  req: Request,
  ctx: web.Context,
  item_id: String,
  lang_iso: String,
) -> Response {
  use req, user_info <- web.with_user(req)
  use req, lang <- web.validate_lang(req, lang_iso)
  use req, item <- web.get_item_info(req, ctx, item_id, lang)

  let assert Ok(pog.Returned(_count, items_waitlists_rows)) =
    sql.get_items_waitlists(ctx.db)

  let waitlist =
    items_waitlists_rows |> list.filter(fn(wl) { wl.item_id == item.id })
  let n_users_in_waitlist = waitlist |> list.length

  let user_pos_in_waitlist = {
    case user_info {
      None -> None
      Some(u) -> {
        waitlist
        |> utils.find_index(fn(item) { item.user_id == u.id })
      }
    }
  }
  list_page.user_actions(
    item_id:,
    item_name: item.name,
    user_info:,
    lang:,
    n_users_in_waitlist:,
    user_pos_in_waitlist:,
  )
  |> utils.frag_to_response
}

fn handle_auth_route(req: Request, lang_iso: String) -> Response {
  use req, lang <- web.validate_lang(req, lang_iso)
  auth_page.page(req.path, lang) |> utils.page_to_response
}

fn handle_index_route(
  req: Request,
  ctx: web.Context,
  lang_iso: String,
) -> Response {
  use req, lang <- web.validate_lang(req, lang_iso)
  use req, _target <- web.with_hx_target(req)
  use req, maybe_user <- web.with_user(req)

  let assert Ok(pog.Returned(_count, items_rows)) =
    sql.get_items_with_info(ctx.db, lang_iso)

  let assert Ok(pog.Returned(_count, items_waitlists_rows)) =
    sql.get_items_waitlists(ctx.db)

  list_page.page(req.path, lang, maybe_user, items_rows:, items_waitlists_rows:)
  |> utils.page_to_response
}

fn store_auth(
  req: Request,
  db: pog.Connection,
  query_params: List(#(String, String)),
) -> Response {
  use formdata <- wisp.require_form(req)
  io.debug(formdata.values)

  let result = {
    use name <- result.try(list.key_find(formdata.values, "name"))
    use email <- result.try(list.key_find(formdata.values, "email"))

    Ok(#(name, email))
  }

  case result {
    Ok(#(name, email)) -> {
      let user = crud.insert_user_if_not_in_db(req, db, name, email)
      let cookie = string.join([user.id, user.name, email], ";")
      let qry_params = case uri.query_to_string(query_params) {
        "" -> ""
        v -> "?" <> v
      }

      wisp.redirect("/" <> qry_params)
      |> wisp.set_cookie(req, "user", cookie, wisp.Signed, 24 * 60 * 60 * 180)
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}

pub fn handle_add_to_waitlist(
  req req: Request,
  ctx ctx: web.Context,
  item_id item_id: String,
  maybe_user maybe_user: Option(User),
  lang lang: Language,
) -> Response {
  use req, user <- web.require_user(req, maybe_user)
  use _req, _item_info <- web.get_item_info(req, ctx, item_id, lang)

  let assert Ok(pog.Returned(_count, _rows)) =
    sql.insert_to_waitlist(ctx.db, item_id, user.id)

  wisp.redirect(
    "/item/" <> item_id <> "/user-actions?lang=" <> language.to_iso(lang),
  )
}

// TODO - Move derived calculations in request handlers instead of view functions

pub fn handle_remove_from_waitlist(
  req req: Request,
  ctx ctx: web.Context,
  item_id item_id: String,
  maybe_user maybe_user: Option(User),
  lang lang: Language,
) -> Response {
  use _req, user <- web.require_user(req, maybe_user)
  let assert Ok(pog.Returned(_count, _rows)) =
    sql.remove_user_from_waitlist(ctx.db, user.id, item_id)

  wisp.redirect(
    "/item/" <> item_id <> "/user-actions?lang=" <> language.to_iso(lang),
  )
}
