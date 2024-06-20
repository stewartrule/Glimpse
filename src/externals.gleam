import lustre/effect.{type Effect}

// scroll_to_top
pub fn scroll_to_top(selector: String, offset: Int) -> Effect(msg) {
  effect.from(fn(_) { do_scroll_to_top(selector, offset) })
}

@external(javascript, "./externals.ffi.mjs", "scroll_to_top")
fn do_scroll_to_top(_selector: String, _offset: Int) -> Nil {
  Nil
}

// set_scroll_top
pub fn set_scroll_top(selector: String, offset: Int) -> Effect(msg) {
  effect.from(fn(_) { do_set_scroll_top(selector, offset) })
}

@external(javascript, "./externals.ffi.mjs", "set_scroll_top")
fn do_set_scroll_top(_selector: String, _offset: Int) -> Nil {
  Nil
}

// set_scroll_left
pub fn set_scroll_left(selector: String, offset: Int) -> Effect(msg) {
  effect.from(fn(_) { do_set_scroll_left(selector, offset) })
}

@external(javascript, "./externals.ffi.mjs", "set_scroll_left")
fn do_set_scroll_left(_selector: String, _offset: Int) -> Nil {
  Nil
}

// set_translate_x
pub fn set_translate_x(selector: String, offset: Float) -> Effect(msg) {
  effect.from(fn(_) { do_set_translate_x(selector, offset) })
}

@external(javascript, "./externals.ffi.mjs", "set_translate_x")
fn do_set_translate_x(_selector: String, _offset: Float) -> Nil {
  Nil
}
