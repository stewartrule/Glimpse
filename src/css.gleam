import gleam/float
import gleam/int

fn top(value: Int, unit: String) {
  #("top", int.to_string(value) <> unit)
}

pub fn translate_x(value: Float, unit: String) {
  #("transform", "translateX(" <> float.to_string(value) <> unit <> ")")
}

pub fn translate_x_px(value: Float) {
  translate_x(value, "px")
}

pub fn top_px(value: Int) {
  top(value, "px")
}

fn left(value: Int, unit: String) {
  #("left", int.to_string(value) <> unit)
}

pub fn left_px(value: Int) {
  left(value, "px")
}

fn height(value: Int, unit: String) {
  #("height", int.to_string(value) <> unit)
}

pub fn height_px(value: Int) {
  height(value, "px")
}

fn width(value: Int, unit: String) {
  #("width", int.to_string(value) <> unit)
}

pub fn width_px(value: Int) {
  width(value, "px")
}
