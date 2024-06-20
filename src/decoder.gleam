import gleam/dynamic.{decode8, field, float}
import model.{type DomRect, DomRect}

pub fn dom_rect_decoder() {
  decode8(
    DomRect,
    field("x", float),
    field("y", float),
    field("width", float),
    field("height", float),
    field("top", float),
    field("right", float),
    field("bottom", float),
    field("left", float),
  )
}
