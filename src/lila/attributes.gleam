import gleam/list
import gleam/string
import lustre/attribute

pub type HxSwap {
  InnerHTML
  OuterHTML
}

pub type HxTrigger {
  Load
  Click
  Change
}

fn trigger_to_str(t: HxTrigger) -> String {
  case t {
    Load -> "load"
    Click -> "click"
    Change -> "change"
  }
}

pub fn hx_get(endpoint: String) {
  attribute.attribute("hx-get", endpoint)
}

pub fn hx_post(endpoint: String) {
  attribute.attribute("hx-post", endpoint)
}

pub fn hx_target(id: String) {
  attribute.attribute("hx-target", "#" <> id)
}

pub fn hx_trigger(on: List(HxTrigger)) {
  let s = on |> list.map(trigger_to_str) |> string.join(", ")
  attribute.attribute("hx-trigger", s)
}

pub fn hx_swap(swap: HxSwap) {
  let attr = case swap {
    InnerHTML -> "innerHTML"
    OuterHTML -> "outerHTML"
  }
  attribute.attribute("hx-swap", attr)
}

pub fn hx_push_url() {
  attribute.attribute("hx-push-url", "true")
}

pub fn hx_replace_url() {
  attribute.attribute("hx-replace-url", "true")
}

pub fn hx_swap_oob() {
  attribute.attribute("hx-swap-oob", "true")
}
