import app/common
import gleam/list
import lila/attributes
import lila/language
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import sql

pub fn admin_page(
  path: String,
  lang: language.Language,
  unique_item_ids: List(sql.GetItemsRow),
) -> Element(Nil) {
  let elts = [
    html.select(
      [
        attributes.hx_get("/waitlist"),
        attributes.hx_target("waitlist-table"),
        attributes.hx_trigger([attributes.Load, attributes.Change]),
        attribute.name("id"),
      ],
      unique_item_ids
        |> list.map(fn(item) {
          html.option([attribute.value(item.id)], item.name)
        }),
    ),
    html.div([attribute.id("waitlist-table")], []),
  ]

  common.layout(path, lang, elts)
}
