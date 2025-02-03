import gleam/list

import lustre/element.{type Element}
import lustre/element/html
import sql

pub fn waitlist(users: List(sql.GetUsersInWaitlistRow)) -> Element(Nil) {
  let lst = case users {
    [] -> [html.li([], [html.text("No one yet!")])]
    v -> v |> list.map(fn(user) { html.li([], [html.text(user.email)]) })
  }

  html.ul([], lst)
}
