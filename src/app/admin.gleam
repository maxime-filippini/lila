import app/common
import lila/language
import lustre/element.{type Element}
import lustre/element/html

pub fn admin_page(path: String, lang: language.Language) -> Element(Nil) {
  common.layout(path, lang, [])
}
