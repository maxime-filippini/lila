import lustre/attribute.{type Attribute, attribute as attr}
import lustre/element.{type Element}
import lustre/element/html

type NavItem {
  Home
  App
  Admin
}

fn to_html(item: NavItem) -> Element(Nil) {
  let #(url, title) = case item {
    Home -> #("/", "Home")
    App -> #("/app", "App")
    Admin -> #("/admin", "Admin")
  }

  html.li([], [html.a([attribute.href(url)], [html.text(title)])])
}

fn nav_items() {
  html.ul(
    [attribute.class("flex p-4 gap-8 border border-gray-100 bg-gray-50")],
    [to_html(Home), to_html(App), to_html(Admin)],
  )
}

pub fn nav_bar() -> Element(Nil) {
  html.nav([attribute.class("")], [nav_items()])
}

pub fn text(s: String) -> Element(Nil) {
  html.p([], [html.text(s)])
}

pub fn stylesheet(file_name: String) -> Element(Nil) {
  html.link([
    attribute.href("static/" <> file_name),
    attribute.rel("stylesheet"),
  ])
}

fn htmx() -> Element(Nil) {
  html.script(
    [attribute.type_("text/javascript"), attribute.src("static/htmx.min.js")],
    "",
  )
}

pub fn head(title: String) -> Element(Nil) {
  html.head([], [
    html.meta([attr("charset", "UTF-8")]),
    html.meta([
      attr("content", "width=device-width, initial-scale=1.0"),
      attribute.name("viewport"),
    ]),
    htmx(),
    emoji_favicon("👶"),
    stylesheet("output.css"),
    html.title([], title),
  ])
}

fn emoji_favicon(emoji: String) -> Element(Nil) {
  let left =
    "data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>"
  let right = "</text></svg>"

  html.link([attribute.href(left <> emoji <> right), attribute.rel("icon")])
}

pub fn h1(text: String) {
  html.h1([attribute.class("text-3xl font-bold")], [html.text(text)])
}

pub fn h2(text: String) {
  html.h2([attribute.class("text-xl font-semibold")], [html.text(text)])
}

pub fn button(attrs: List(Attribute(a)), elts: List(Element(a))) -> Element(a) {
  html.button(
    [
      attribute.class(
        "bg-violet-300 rounded-lg py-2 px-4 cursor-pointer hover:bg-violet-500 duration-200",
      ),
      ..attrs
    ],
    elts,
  )
}
