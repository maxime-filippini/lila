import lustre/attribute

pub fn hx_get(endpoint: String) {
  attribute.attribute("hx-get", endpoint)
}

pub fn hx_target(id: String) {
  attribute.attribute("hx-target", "#" <> id)
}

pub fn hx_push_url() {
  attribute.attribute("hx-push-url", "true")
}

pub fn hx_swap_oob() {
  attribute.attribute("hx-swap-oob", "true")
}
