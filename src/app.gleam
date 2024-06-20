import lustre
import lustre/effect

import model.{type Msg, type State, State}
import state.{get_initial_state}
import update.{update}
import view.{view}

fn init(_flags) -> #(State, effect.Effect(Msg)) {
  #(get_initial_state(), effect.none())
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
