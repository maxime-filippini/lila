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
