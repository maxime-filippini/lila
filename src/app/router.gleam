import gleam/float
import gleam/http.{Get, Post}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import lila/attributes
import lila/elements
import lila/language.{type Language, Croatian, English, French}
import lila/user.{type User}
import lila/utils
import lila/web
import lustre/attribute.{attribute as attr, class}
import lustre/element.{type Element}
import lustre/element/html
import pog
import sql
import wisp.{type Request, type Response}
import youid/uuid

const id_page_body = "page-body"

pub fn route_request(req: Request, ctx: web.Context) -> Response {
  use req <- web.middleware(req, ctx)

  let target = utils.get_hx_target(req)

  let user = case wisp.get_cookie(req, "user", wisp.Signed) {
    Ok(v) -> {
      case user.parse(v) {
        Ok(w) -> Some(w)
        _ -> None
      }
    }
    _ -> None
  }

  case req.method, wisp.path_segments(req) {
    Get, [] -> wisp.redirect("/en")

    Get, ["en"] -> index(target, ctx.db, English, user)
    Get, ["fr"] -> index(target, ctx.db, French, user)
    Get, ["hr"] -> index(target, ctx.db, Croatian, user)

    Get, [lang, "auth"] -> {
      case language.from_iso(lang) {
        Ok(v) -> auth_route(req, target, v, ["auth"])
        Error(_) -> wisp.not_found()
      }
    }

    // TODO - Find a way to handle this state better (e.g. shift from URL to form submission)
    Post, [lang, "interested", id] -> {
      let assert Ok(lang) = language.from_iso(lang)
      handle_action(req, ctx.db, id, user, lang, sql.Interested, False)
    }

    Post, [lang, "not-interested", id] -> {
      let assert Ok(lang) = language.from_iso(lang)
      handle_action(req, ctx.db, id, user, lang, sql.NoLongerInterested, True)
    }

    Post, [lang, "will-buy", id, "interested"] -> {
      let assert Ok(lang) = language.from_iso(lang)
      handle_action(req, ctx.db, id, user, lang, sql.Reserve, True)
    }
    Post, [lang, "will-buy", id] -> {
      let assert Ok(lang) = language.from_iso(lang)
      handle_action(req, ctx.db, id, user, lang, sql.Reserve, False)
    }

    Post, [lang, "need-info", id] -> {
      let assert Ok(lang) = language.from_iso(lang)
      handle_action(req, ctx.db, id, user, lang, sql.AskForInfo, False)
    }

    Post, [lang, "need-info", id, "interested"] -> {
      let assert Ok(lang) = language.from_iso(lang)
      handle_action(req, ctx.db, id, user, lang, sql.AskForInfo, True)
    }

    Post, [v, "auth"] -> {
      let assert Ok(lang) = language.from_iso(v)
      store_auth(req, ctx.db, lang)
    }
    _, _ -> wisp.not_found()
  }
}

fn insert_user_if_not_in_db(
  req: Request,
  db: pog.Connection,
  name: String,
  email: String,
) -> User {
  let assert Ok(pog.Returned(_count, rows)) = sql.get_user_by_email(db, email)

  case rows {
    [] -> {
      let uuid = uuid.v4_string()
      let assert Ok(pog.Returned(_count, _rows)) =
        sql.insert_user(db, uuid, name, email)

      insert_user_if_not_in_db(req, db, name, email)
      // Try again
    }
    [v] -> user.User(v.id, v.name, v.email)
    _ -> panic
  }
}

fn store_auth(req: Request, db: pog.Connection, lang: Language) -> Response {
  use formdata <- wisp.require_form(req)
  io.debug(formdata.values)

  let result = {
    use name <- result.try(list.key_find(formdata.values, "name"))
    use email <- result.try(list.key_find(formdata.values, "email"))

    Ok(#(name, email))
  }

  case result {
    Ok(#(name, email)) -> {
      let user = insert_user_if_not_in_db(req, db, name, email)
      let cookie = string.join([user.id, user.name, email], ";")

      wisp.redirect("/" <> language.to_iso(lang))
      |> wisp.set_cookie(req, "user", cookie, wisp.Signed, 24 * 60 * 60 * 180)
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}

// ---------------------------------------------------------------

/// Render the index page
fn index(
  target: Option(String),
  db: pog.Connection,
  lang: Language,
  user: Option(User),
) {
  let assert Ok(pog.Returned(_count, rows)) =
    sql.get_items_with_status(db, language.to_iso(lang))

  let user_id = case user {
    Some(u) -> u.id
    None -> "_"
  }

  let assert Ok(pog.Returned(_count, interested_rows)) =
    sql.get_items_user_is_interested_in(db, user_id)

  let items_interested = interested_rows |> list.map(fn(item) { item.item_id })

  case target {
    Some("page-body") ->
      [
        thank_you(lang),
        item_list(rows, lang, user, items_interested),
        footer(lang),
      ]
      |> utils.frags_to_response
    Some(_) ->
      page(rows, lang, user, [], items_interested) |> utils.page_to_response
    None ->
      page(rows, lang, user, [], items_interested) |> utils.page_to_response
  }
}

fn single_item(
  item: sql.GetItemsWithStatusRow,
  user_info: Option(User),
  lang: Language,
  user_interested: Bool,
) {
  let price = item.average_price |> float.to_precision(2) |> float.to_string

  let price = case string.split_once(price, ".") {
    Ok(#(int, rem)) -> {
      case string.length(rem) {
        1 -> string.join([int, rem <> "0"], ".")
        _ -> price
      }
    }
    _ -> price <> ".00"
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
            elements.h2([], price <> "€"),
          ]),
          elements.p([], item.description),
          case item.link {
            Some(link) ->
              html.a(
                [
                  attribute.href(link),
                  class(
                    "text-violet-300 hover:underline duration-500 underline-offset-4 italic",
                  ),
                ],
                [html.text(link)],
              )
            None -> html.div([], [])
          },
        ],
      ),
      user_actions(item.id, user_info, lang, user_interested),
    ],
  )
}

fn user_actions(
  item_id: String,
  user_info: Option(User),
  lang: Language,
  user_interested: Bool,
) {
  let #(interested, not_interested, will_buy, need_info) = case lang {
    English -> #(
      "Interested",
      "No longer interested",
      "Will buy",
      "Need more information",
    )
    Croatian -> #(
      "Zainteresiran(a)",
      "Nisam zainteresiran(a)",
      "Kupit ću",
      "Treba mi više informacija",
    )
    French -> #(
      "Intéressé(e)",
      "Plus intéressé(e)",
      "Va acheter",
      "Besoin d'informations",
    )
  }

  let iso = language.to_iso(lang)
  let interested_url = case user_interested {
    True -> "interested"
    False -> ""
  }

  let interested_action = case user_interested {
    True -> {
      elements.red_button(
        [
          class("flex-1 md:w-full"),
          attributes.hx_post("/" <> iso <> "/not-interested/" <> item_id),
          attributes.hx_target("actions-" <> item_id),
        ],
        [html.text(not_interested)],
      )
    }
    False -> {
      elements.amber_button(
        [
          class("flex-1 md:w-full"),
          attributes.hx_post("/" <> iso <> "/interested/" <> item_id),
          attributes.hx_target("actions-" <> item_id),
        ],
        [html.text(interested)],
      )
    }
  }

  html.div(
    [
      class(
        "md:w-2/6 p-4 flex md:flex-col flex-wrap items-center justify-center gap-4",
      ),
      attribute.id("actions-" <> item_id),
      attributes.hx_swap(attributes.OuterHTML),
    ],
    case user_info {
      Some(_) -> [
        interested_action,
        elements.green_button(
          [
            class("flex-1 md:w-full"),
            attributes.hx_post(
              "/" <> iso <> "/will-buy/" <> item_id <> "/" <> interested_url,
            ),
            attributes.hx_target("actions-" <> item_id),
          ],
          [html.text(will_buy)],
        ),
        elements.button(
          [
            class("flex-1 md:w-full"),
            attributes.hx_post(
              "/" <> iso <> "/need-info/" <> item_id <> "/" <> interested_url,
            ),
            attributes.hx_target("actions-" <> item_id),
          ],
          [html.text(need_info)],
        ),
      ]
      _ -> [provide_info_button(lang)]
    },
  )
}

fn single_language_button(href: String, file_name: String) {
  html.a(
    [
      attributes.hx_get(href),
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

fn language_section(endpoint: String) {
  html.div([class("flex gap-4")], [
    single_language_button("/hr/" <> endpoint, "Flag_of_Croatia.svg"),
    single_language_button("/fr/" <> endpoint, "Flag_of_France.svg"),
    single_language_button("/en/" <> endpoint, "Flag_of_the_United_Kingdom.svg"),
  ])
}

fn header(lang: Language, endpoint: String) {
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
          attributes.hx_get("/" <> language.to_iso(lang)),
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
      language_section(endpoint),
    ],
  )
}

fn layout(lang: Language, body: List(Element(Nil)), path_segments: List(String)) {
  let endpoint = path_segments |> string.join("/")

  html.html([attr("lang", "en")], [
    elements.head("Lila's baby list"),
    html.body([class("p-8 max-w-5xl mx-auto flex flex-col gap-8")], [
      header(lang, endpoint),
      html.div([class("flex flex-col gap-8"), attribute.id(id_page_body)], body),
      footer(lang),
    ]),
  ])
}

fn page(
  items: List(sql.GetItemsWithStatusRow),
  lang: Language,
  user: Option(User),
  path_segments: List(String),
  items_interested: List(String),
) {
  layout(
    lang,
    [
      thank_you(lang),
      html.div([class("")], [item_list(items, lang, user, items_interested)]),
    ],
    path_segments,
  )
}

fn thank_you(lang: Language) {
  let msg = case lang {
    English -> "Thank you very much for helping us!"
    Croatian -> "Hvala ti puno što nam pomažeš!"
    French -> "Merci beaucoup pour votre aide!"
  }

  html.p([class("italic"), attribute.id("thank-you")], [html.text(msg)])
}

fn item_list(
  items: List(sql.GetItemsWithStatusRow),
  lang: Language,
  user: Option(User),
  items_interested: List(String),
) {
  let items =
    items
    |> list.map(fn(item) {
      let user_interested = items_interested |> list.contains(item.id)
      single_item(item, user, lang, user_interested)
    })

  html.ul([class("flex flex-col gap-8")], items)
}

fn provide_info_button(lang: Language) {
  let text = case lang {
    French -> "Nous avons besoin de votre nom avant de continuer"
    Croatian -> "Pogledajte opcije"
    English -> "Provide your info before continuing"
  }

  html.button(
    [
      class(
        "bg-slate-300 rounded-lg py-2 px-4 cursor-pointer hover:bg-slate-500 duration-200 hover:text-white",
      ),
      attributes.hx_get("/" <> language.to_iso(lang) <> "/auth"),
      attributes.hx_target(id_page_body),
      attributes.hx_push_url(),
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

fn form(lang: Language) {
  let #(name, email, confirm) = case lang {
    English -> #("Name", "Email address", "Confirm")
    French -> #("Nom", "Adresse email", "Confirmer")
    Croatian -> #("Ime", "Email adresa", "Potvrdi")
  }

  html.form(
    [
      attribute.class(""),
      attribute.method("post"),
      attribute.action("/" <> language.to_iso(lang) <> "/auth"),
    ],
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

fn auth_route(
  req: Request,
  target: Option(String),
  lang: Language,
  path_segments: List(String),
) -> Response {
  let form = form(lang)
  let endpoint = "/" <> path_segments |> string.join("/")

  let user = wisp.get_cookie(req, "user", wisp.Signed)

  case user {
    Ok(_) -> wisp.redirect("/" <> language.to_iso(lang))
    _ -> {
      case target {
        Some("page-body") ->
          [header(lang, endpoint), form, footer(lang)]
          |> utils.frags_to_response
        Some(_) -> layout(lang, [form], path_segments) |> utils.page_to_response
        None -> layout(lang, [form], path_segments) |> utils.page_to_response
      }
    }
  }
}

fn handle_action(
  _req: Request,
  db: pog.Connection,
  id: String,
  maybe_user: Option(User),
  lang: Language,
  action: sql.ItemAction,
  interested: Bool,
) -> Response {
  case maybe_user {
    None -> wisp.response(401)
    Some(u) -> {
      let assert Ok(pog.Returned(_count, _rows)) =
        sql.insert_action(db, uuid.v4_string(), id, action, u.id)

      let interested = case action {
        sql.Interested -> True
        sql.NoLongerInterested -> False
        _ -> interested
      }

      user_actions(id, Some(u), lang, interested)
      |> utils.frag_to_response
    }
  }
}
