import app/translations
import lila/attributes
import lila/elements
import lila/language.{type Language, Croatian, English, French}
import lustre/attribute.{attribute as attr, class}
import lustre/element.{type Element}
import lustre/element/html

const id_page_body = "page-body"

fn single_language_button(
  path: String,
  lang: Language,
  file_name: String,
) -> Element(Nil) {
  let iso = language.to_iso(lang)

  html.a(
    [
      attributes.hx_get(path <> "?lang=" <> iso),
      attributes.hx_target(id_page_body),
      attributes.hx_replace_url(),
      class("cursor-pointer hover:scale-110 duration-500"),
    ],
    [
      html.img([
        attribute.src("/static/imgs/" <> file_name),
        class(
          "rounded-full object-cover w-12 h-12 border-2 border-black box-border",
        ),
      ]),
    ],
  )
}

fn language_section(path: String) -> Element(Nil) {
  html.div([class("flex gap-4")], [
    single_language_button(path, Croatian, "Flag_of_Croatia.svg"),
    single_language_button(path, French, "Flag_of_France.svg"),
    single_language_button(path, English, "Flag_of_the_United_Kingdom.svg"),
  ])
}

pub fn layout(
  path: String,
  lang: Language,
  body: List(Element(Nil)),
) -> Element(Nil) {
  html.html([], [
    elements.head("Lila's baby list"),
    html.body([class("p-8 max-w-5xl mx-auto flex flex-col gap-8")], [
      header(path, lang),
      html.div([class("flex flex-col gap-8"), attribute.id(id_page_body)], body),
      footer(lang),
    ]),
  ])
}

pub fn header(path: String, lang: Language) -> Element(Nil) {
  html.div(
    [
      attribute.id("header"),
      attributes.hx_swap_oob(),
      class(
        "flex sm:h-8 sm:flex-row flex-col items-center justify-center flex-1 gap-4",
      ),
    ],
    [
      html.button(
        [
          class(
            "px-8 py-4 bg-violet-50 rounded-xl hover:bg-violet-100 duration-500 sm:mr-auto",
          ),
          attributes.hx_get("/?lang=" <> language.to_iso(lang)),
          attributes.hx_target(id_page_body),
          attributes.hx_push_url(),
          class("cursor-pointer"),
        ],
        [
          html.h1([class("text-3xl font-bold")], [
            html.text("👨‍👩‍👧 Lila's baby list"),
          ]),
        ],
      ),
      language_section(path),
    ],
  )
}

pub fn footer(lang: Language) -> Element(Nil) {
  html.div([attribute.id("footer"), attributes.hx_swap_oob()], [
    html.div([class("mr-auto border-t border-slate-300 mb-4")], []),
    html.p([class("italic")], [
      html.span([], [html.text(translations.if_problem_contact_me(lang))]),
      html.a(
        [
          attribute.href("mailto:maxime.filippini@gmail.com"),
          class(
            "text-violet-300 hover:underline duration-500 underline-offset-4",
          ),
        ],
        [html.text("maxime.filippini@gmail.com")],
      ),
    ]),
  ])
}
