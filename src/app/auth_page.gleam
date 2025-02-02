import app/common
import gleam/string
import lila/language.{type Language, Croatian, English, French}
import lustre/attribute.{class}
import lustre/element/html

pub fn page(path: String, lang: Language) {
  common.layout(path, lang, [form(lang)])
}

fn form(lang: Language) {
  let #(name, email, confirm) = case lang {
    English -> #("Name", "Email address", "Confirm")
    French -> #("Nom", "Adresse email", "Confirmer")
    Croatian -> #("Ime", "Email adresa", "Potvrdi")
  }

  html.form(
    [attribute.class(""), attribute.method("post"), attribute.action("/auth")],
    [
      html.div([attribute.class("mb-4")], [
        html.label(
          [
            attribute.for("name"),
            attribute.class("block text-gray-700 text-sm font-bold mb-2"),
          ],
          [html.text(name)],
        ),
        html.input([
          attribute.placeholder(name),
          attribute.type_("text"),
          attribute.name("name"),
          attribute.id("name"),
          attribute.class(
            "shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline",
          ),
        ]),
      ]),
      html.div([attribute.class("mb-6")], [
        html.label(
          [
            attribute.for("email"),
            attribute.class("block text-gray-700 text-sm font-bold mb-2"),
          ],
          [html.text(email)],
        ),
        html.input([
          attribute.placeholder(
            name |> string.lowercase |> string.replace(" ", "_")
            <> "@example.com",
          ),
          attribute.type_("email"),
          attribute.name("email"),
          attribute.id("email"),
          attribute.class(
            "shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:shadow-outline",
          ),
        ]),
      ]),
      html.input([
        class(
          "w-full bg-violet-300 rounded-lg py-2 px-4 cursor-pointer hover:bg-violet-500 duration-200",
        ),
        attribute.type_("submit"),
        attribute.value(confirm),
      ]),
    ],
  )
}
