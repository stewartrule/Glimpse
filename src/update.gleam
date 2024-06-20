import birl
import externals.{
  scroll_to_top, set_scroll_left, set_scroll_top, set_translate_x,
}
import gleam/float
import gleam/int
import gleam/io.{debug}
import gleam/list
import lustre/effect.{type Effect}
import time.{get_total_minutes}

import model.{
  type DomRect, type Event, type Msg, type State, Event,
  MountedCalendarHorizontally, MountedCalendarVertically, ResizedCalendar,
  ScrolledCalendarHorizontally, State, Task, UserClickedEventInSidebar,
  UserDeselectedEvent, UserDeselectedEvents, UserFilteredEventsByUser,
  UserSearchedEvent, UserSelectedEvent, UserToggledTask, UserUpdatedEndTime,
}

const vertical_scroll_id = "#vertical-scroll"

const horizontal_scroll_id = "#horizontal-scroll"

pub fn update(state: State, msg: Msg) -> #(State, Effect(Msg)) {
  case msg {
    UserSelectedEvent(event) -> #(
      State(
        ..state,
        events: list.map(state.events, fn(e) {
          case e.id == event.id {
            True -> Event(..e, selected: True, was_selected: True)
            False -> e
          }
        }),
      ),
      effect.none(),
    )

    UserDeselectedEvents -> #(
      State(
        ..state,
        events: list.map(state.events, fn(e) { Event(..e, selected: False) }),
      ),
      effect.none(),
    )

    UserDeselectedEvent(event) -> #(
      State(
        ..state,
        events: list.map(state.events, fn(e) {
          case e.id == event.id {
            True -> Event(..e, selected: False)
            False -> e
          }
        }),
      ),
      effect.none(),
    )

    UserToggledTask(event, task) -> #(
      State(
        ..state,
        events: list.map(state.events, fn(current_item) {
          case current_item.id == event.id {
            True ->
              Event(
                ..current_item,
                tasks: list.map(current_item.tasks, fn(current_task) {
                  case current_task.id == task.id {
                    True -> Task(..current_task, done: !current_task.done)
                    False -> current_task
                  }
                }),
              )
            False -> current_item
          }
        }),
      ),
      effect.none(),
    )

    ResizedCalendar(rect) -> {
      let weekday_width = get_weekday_width(rect)

      #(
        State(..state, week_day_width: weekday_width, calendar_rect: rect),
        effect.none(),
      )
    }

    MountedCalendarVertically(rect) -> {
      let total_minutes = get_total_minutes(state.now)
      let offset = float.round(rect.height /. 2.0)
      let scroll_top = { state.minute_height * total_minutes } - offset

      #(
        State(..state, calendar_rect: rect),
        set_scroll_top(vertical_scroll_id, scroll_top),
      )
    }

    MountedCalendarHorizontally(rect) -> {
      let day = birl.weekday(state.now)
      let offset = case day {
        birl.Mon -> 0.0
        birl.Tue -> 1.0
        birl.Wed -> 2.0
        birl.Thu -> 3.0
        birl.Fri -> 4.0
        birl.Sat -> 5.0
        birl.Sun -> 6.0
      }
      let weekday_width = get_weekday_width(rect)
      let left = float.round(weekday_width *. offset)
      #(state, set_scroll_left(horizontal_scroll_id, left))
    }

    UserClickedEventInSidebar(event) -> {
      let total_minutes = get_total_minutes(event.start)
      let scroll_top = {
        state.minute_height * total_minutes
      }
      #(state, scroll_to_top(vertical_scroll_id, scroll_top))
    }

    ScrolledCalendarHorizontally(scroll_left) -> {
      #(state, set_scroll_left("#column-headers", float.round(scroll_left)))
    }

    UserSearchedEvent(keyword) -> {
      #(State(..state, keyword: keyword), effect.none())
    }

    UserFilteredEventsByUser(user) -> {
      #(
        State(
          ..state,
          selected_user_ids: case
            list.contains(state.selected_user_ids, user.id)
          {
            True ->
              list.filter(state.selected_user_ids, fn(id) { id != user.id })
            False -> [user.id]
          },
        ),
        effect.none(),
      )
    }

    UserUpdatedEndTime(value) -> {
      debug(value)
      #(state, effect.none())
    }
  }
}

fn get_weekday_width(rect: DomRect) -> Float {
  let min_width = 165.0
  let col_count =
    float.floor(rect.width /. min_width)
    |> float.round
    |> int.clamp(1, 7)
    |> int.to_float
  rect.width /. col_count
}
