import app/common
import app/translations
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/uri
import lila/attributes
import lila/elements
import lila/language.{type Language, Croatian, English, French}
import lila/user.{type User}
import lila/utils
import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html
import pog
import sql
import wisp.{type Request, type Response}
import youid/uuid

const id_page_body = "page-body"

pub fn page(
  path: String,
  lang: Language,
  maybe_user: Option(User),
  items_rows item_rows: List(sql.GetItemsWithInfoRow),
  items_waitlists_rows items_waitlists_rows: List(sql.GetItemsWaitlistsRow),
) -> Element(Nil) {
  common.layout(path, lang, [
    thank_you(lang),
    html.div([], [item_list(item_rows, lang, maybe_user, items_waitlists_rows)]),
  ])
}

fn thank_you(lang: Language) {
  html.p([class("italic"), attribute.id("thank-you")], [
    lang |> translations.thank_you |> html.text,
  ])
}

fn item_list(
  items: List(sql.GetItemsWithInfoRow),
  lang: Language,
  user: Option(User),
  items_waitlists: List(sql.GetItemsWaitlistsRow),
) {
  let items =
    items
    |> list.map(fn(item) {
      let waitlist =
        items_waitlists |> list.filter(fn(wl) { wl.item_id == item.id })

      single_item(item, user, lang, waitlist)
    })

  html.ul([class("flex flex-col gap-8")], items)
}

fn single_item(
  item: sql.GetItemsWithInfoRow,
  user_info: Option(User),
  lang: Language,
  waitlist: List(sql.GetItemsWaitlistsRow),
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
            attribute.src("/static/imgs/" <> item.img),
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
      user_actions(
        item.id,
        item.name,
        user_info,
        n_users_in_waitlist:,
        user_pos_in_waitlist:,
        lang:,
      ),
    ],
  )
}

pub fn user_actions(
  item_id item_id: String,
  item_name item_name: String,
  user_info user_info: Option(User),
  n_users_in_waitlist n_wait: Int,
  user_pos_in_waitlist pos_wait: Option(Int),
  lang lang: Language,
) {
  let button_text =
    case n_wait, pos_wait {
      0, _ -> translations.i_will_buy(lang)
      _, Some(_) -> translations.cancel_my_participation(lang)
      _, None -> translations.put_me_on_waitlist(lang)
    }
    |> html.text

  let waitlist_text = case n_wait {
    0 -> ""
    1 -> "1 " <> lang |> translations.people_in_waitlist(multiple: False)
    n ->
      int.to_string(n)
      <> lang |> translations.people_in_waitlist(multiple: True)
  }

  let my_spot_text = case pos_wait {
    None -> ""
    Some(v) -> " (" <> translations.position_in_waitlist(lang, v + 1) <> ")"
  }

  let waitlist_text = waitlist_text <> my_spot_text

  let endpoint =
    case pos_wait {
      None -> "/item/" <> item_id <> "/add-to-wait-list"
      Some(_) -> "/item/" <> item_id <> "/remove-from-wait-list"
    }
    <> "?lang="
    <> language.to_iso(lang)

  let waitlist_elt = case waitlist_text {
    "" -> html.div([], [])
    v -> {
      html.p([class("text-center italic")], [html.text(v)])
    }
  }

  let button = case pos_wait {
    None ->
      elements.green_button(
        [
          class("w-full h-full"),
          attributes.hx_post(endpoint),
          attributes.hx_target("actions-" <> item_id),
        ],
        [button_text],
      )
    Some(_) ->
      elements.red_button(
        [
          class("w-full h-full"),
          attributes.hx_post(endpoint),
          attributes.hx_target("actions-" <> item_id),
        ],
        [button_text],
      )
  }

  let waitlist_button = {
    html.div(
      [
        class(
          "flex-1 md:w-full flex flex-col gap-2 items-center justify-center",
        ),
      ],
      [button, waitlist_elt],
    )
  }

  html.form(
    [
      class(
        "md:w-2/6 p-4 flex md:flex-col flex-wrap items-center justify-center gap-4",
      ),
      attribute.id("actions-" <> item_id),
      attributes.hx_swap(attributes.OuterHTML),
    ],
    case user_info {
      Some(_) -> [
        waitlist_button,
        elements.button([class("flex-1 md:w-full")], [
          html.a(
            [
              attribute.href(email_href_for_more_info(lang, item_name)),
              class("py-2 px-4 w-full h-full"),
            ],
            [lang |> translations.i_need_more_info |> html.text],
          ),
        ]),
      ]
      _ -> [provide_info_button(lang)]
    },
  )
}

fn provide_info_button(lang: Language) {
  html.button(
    [
      class(
        "bg-slate-300 rounded-lg py-2 px-4 cursor-pointer hover:bg-slate-500 duration-200 hover:text-white",
      ),
      attributes.hx_get("/auth?lang=" <> language.to_iso(lang)),
      attributes.hx_target(id_page_body),
      attributes.hx_push_url(),
    ],
    [lang |> translations.we_need_your_info |> html.text],
  )
}

fn email_href_for_more_info(lang: Language, item_name: String) {
  let recipient = "maxime.filippini@gmail.com"
  let subject = translations.i_need_more_info_on_item(lang) <> item_name

  // translations.i_need_more_info_on_item
  "mailto:"
  <> recipient
  <> "?"
  <> uri.query_to_string([#("subject", subject), #("body", "")])
}
