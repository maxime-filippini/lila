import envoy
import gleam/result
import gleam/string
import gleam/string_tree
import lustre/element.{type Element}
import wisp.{type Response}

pub fn page_to_response(elt: Element(a)) -> Response {
  elt
  |> element.to_document_string
  |> string_tree.from_string
  |> wisp.html_body(wisp.ok(), _)
}

pub fn frag_to_response(elt: Element(a)) -> Response {
  elt
  |> element.to_string
  |> string_tree.from_string
  |> wisp.html_body(wisp.ok(), _)
}

pub fn get_env(key: String) {
  envoy.get(key) |> result.map(string.trim_end)
}
