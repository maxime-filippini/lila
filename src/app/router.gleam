import gleam/list
import gleam/option.{type Option, None, Some}
import lila/elements
import lila/utils
import lila/web
import lustre/attribute.{attribute as attr}
import lustre/element/html
import wisp.{type Request, type Response}

fn get_hx_target(req: Request) -> Option(String) {
  case list.key_find(req.headers, "HX-Target") {
    Ok(header) -> Some(header)
    _ -> None
  }
}

pub fn route_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)

  let target = get_hx_target(req)

  case wisp.path_segments(req) {
    [] -> index(target) |> utils.page_to_response
    _ -> wisp.not_found()
  }
}

fn index(target: Option(String)) {
  html.html([attr("lang", "en")], [
    elements.head("Baby names"),
    html.body([attribute.class("h-screen")], [elements.h1("Hello")]),
  ])
}
