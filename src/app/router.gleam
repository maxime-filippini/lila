import gleam/float
import gleam/list
import gleam/option.{type Option, None, Some}
import lila/attributes
import lila/elements
import lila/utils
import lila/web
import lustre/attribute.{attribute as attr, class}
import lustre/element/html
import pog
import sql
import wisp.{type Request, type Response}

pub type Language {
  English
  Croatian
  French
}

fn lang_to_iso(lang: Language) -> String {
  case lang {
    English -> "en"
    Croatian -> "hr"
    French -> "fr"
  }
}

fn get_hx_target(req: Request) -> Option(String) {
  case list.key_find(req.headers, "hx-target") {
    Ok(header) -> Some(header)
    _ -> None
  }
}

pub fn route_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)

  let target = get_hx_target(req)

  case wisp.path_segments(req) {
    [] -> index(target, ctx.db, English)
    ["en"] -> index(target, ctx.db, English)
    ["hr"] -> index(target, ctx.db, Croatian)
    ["fr"] -> index(target, ctx.db, French)

    _ -> wisp.not_found()
  }
}

fn index(target: Option(String), db: pog.Connection, lang: Language) {
  let assert Ok(pog.Returned(_count, rows)) =
    sql.get_items(db, lang_to_iso(lang))

  case target {
    Some("item-list") ->
      [item_list(rows, lang), thank_you(lang), footer(lang)]
      |> utils.frags_to_response
    Some(_) -> page(rows, lang) |> utils.page_to_response
    None -> page(rows, lang) |> utils.page_to_response
  }
}

fn single_item(item: sql.GetItemsRow, user_info: Option(Bool), lang: Language) {
  let #(interested, will_buy, need_info) = case lang {
    English -> #("Interested", "Will buy", "Need more information")
    Croatian -> #("Zainteresiran(a)", "Kupit ću", "Treba mi više informacija")
    French -> #("Intéressé(e)", "Va acheter", "Besoin d'informations")
  }

  let actions = case user_info {
    Some(True) -> [
      elements.amber_button([class("flex-1 md:w-full")], [html.text(interested)]),
      elements.green_button([class("flex-1 md:w-full")], [html.text(will_buy)]),
      elements.button([class("flex-1 md:w-full")], [html.text(need_info)]),
    ]
    _ -> [provide_info_button(lang)]
  }

  html.li(
    [
      class(
        "rounded-lg w-full p-4 flex flex-col md:flex-row gap-4 mx-auto bg-violet-50",
      ),
    ],
    [
      html.div(
        [class("md:w-1/6 flex items-center justify-center rounded-lg bg-white")],
        [
          html.img([
            attribute.src("/static/imgs/maxicosi_iora_codod.jpg"),
            class("object-contain rounded-full max-h-32 flex-none"),
          ]),
        ],
      ),
      html.div(
        [class("md:w-4/6 p-4 flex flex-col gap-4 items-start justify-center")],
        [
          html.div([class("flex w-full")], [
            elements.h2([class("mr-auto")], item.name),
            elements.h2([], float.to_string(item.average_price) <> "€"),
          ]),
          elements.p([], item.description),
        ],
      ),
      html.div(
        [
          class(
            "md:w-2/6 p-4 flex md:flex-col flex-wrap items-center justify-center gap-4",
          ),
        ],
        actions,
      ),
    ],
  )
}

fn single_language_button(href: String, file_name: String) {
  html.a(
    [
      attributes.hx_get(href),
      attributes.hx_target("item-list"),
      attributes.hx_push_url(),
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

fn language_section() {
  html.div([class("flex gap-4")], [
    single_language_button("/hr", "Flag_of_Croatia.svg"),
    single_language_button("/fr", "Flag_of_France.svg"),
    single_language_button("/en", "Flag_of_the_United_Kingdom.svg"),
  ])
}

fn page(items: List(sql.GetItemsRow), lang: Language) {
  html.html([attr("lang", "en")], [
    elements.head("Lila's baby list"),
    html.body([class("p-8 max-w-5xl mx-auto flex flex-col gap-8")], [
      html.div(
        [
          class(
            "flex md:h-8 sm:flex-row flex-col gap-4 items-center justify-center flex-1",
          ),
        ],
        [
          elements.h1([class("mr-auto")], "👨‍👩‍👧 Lila's baby list"),
          language_section(),
        ],
      ),
      thank_you(lang),
      html.div([class(""), attribute.id("item-list")], [item_list(items, lang)]),
      footer(lang),
    ]),
  ])
}

fn thank_you(lang: Language) {
  let msg = case lang {
    English -> "Thank you very much for helping us!"
    Croatian -> "Hvala ti puno što nam pomažeš!"
    French -> "Merci beaucoup pour votre aide!"
  }

  html.p(
    [class("italic"), attribute.id("thank-you"), attributes.hx_swap_oob()],
    [html.text(msg)],
  )
}

fn item_list(items: List(sql.GetItemsRow), lang: Language) {
  let items =
    items
    |> list.append(items)
    |> list.append(items)
    |> list.append(items)
    |> list.append(items)
    |> list.append(items)
    |> list.map(single_item(_, Some(True), lang))

  html.ul([class("flex flex-col gap-8")], items)
}

fn provide_info_button(lang: Language) {
  let text = case lang {
    French -> "Clickez ici pour voir vos options"
    Croatian -> "Pogledajte opcije"
    English -> "Click here to see your options"
  }

  html.button(
    [
      class(
        "bg-slate-300 rounded-lg py-2 px-4 cursor-pointer hover:bg-slate-500 duration-200 hover:text-white",
      ),
    ],
    [html.text(text)],
  )
}

fn footer(lang: Language) {
  let msg = case lang {
    English -> "For support, please contact "
    French -> "Besoin d'aide? Contactez "
    Croatian -> "Trebate pomoć? Kontaktirajte "
  }

  html.div([attribute.id("footer"), attributes.hx_swap_oob()], [
    html.div([class("mr-auto border-t border-slate-300 mb-4")], []),
    html.p([class("italic")], [
      html.span([], [html.text(msg)]),
      html.a(
        [
          attribute.href("mailto:maxime.filppini@gmail.com"),
          class(
            "text-violet-300 hover:underline duration-500 underline-offset-4",
          ),
        ],
        [html.text("maxime.filppini@gmail.com")],
      ),
    ]),
  ])
}
