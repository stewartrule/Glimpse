import birl.{type Time}
import birl/duration
import css
import gleam/dynamic
import gleam/float
import gleam/int
import gleam/io.{debug}
import gleam/list
import gleam/result
import gleam/string.{lowercase}
import lustre/attribute.{class, classes, style}
import lustre/element.{type Element, element, none, text}
import lustre/element/html
import lustre/event.{on, on_click}

import decoder.{dom_rect_decoder}
import icon.{
  icon_bell, icon_calendar, icon_check, icon_clock, icon_close, icon_filter,
  icon_plus, icon_search,
}
import model.{
  type Attendee, type Event, type Msg, type State, type User, Attendee, Event,
  MountedCalendarHorizontally, MountedCalendarVertically, ResizedCalendar,
  ScrolledCalendarHorizontally, State, User, UserClickedEventInSidebar,
  UserDeselectedEvents, UserFilteredEventsByUser, UserSearchedEvent,
  UserSelectedEvent, UserToggledTask, UserUpdatedEndTime,
}
import time.{format_hh_mm, get_hours_for_date, get_total_minutes, ordinal}

pub fn view(state: State) -> Element(Msg) {
  let filtered_events = case list.is_empty(state.selected_user_ids) {
    True -> state.events
    False ->
      state.events
      |> list.filter(fn(event) {
        list.any(event.attendees, fn(attendee) {
          list.contains(state.selected_user_ids, attendee.user.id)
        })
      })
  }

  html.div([], [
    html.div(
      [
        class(
          "grid grid-cols-1 md:grid-cols-[18rem_1fr] lg:grid-cols-[22rem_1fr] bg-color-3 w-full h-dvh overflow-hidden relative",
        ),
      ],
      [
        view_sidebar(state),
        html.div([class("grid grid-rows-[auto_auto_1fr] h-dvh @container")], [
          html.div(
            [class("border-b p-2 flex justify-between items-center gap-2")],
            [
              view_member_filter(state),
              html.div([class("flex gap-2")], [
                html.button(
                  [
                    class(
                      "p-1 border rounded-full flex gap-1 items-center h-5 px-2",
                    ),
                  ],
                  [
                    html.span([class("hidden @3xl:flex")], [text("Filter")]),
                    icon_filter(),
                  ],
                ),
                html.button(
                  [
                    class(
                      "p-1 border rounded-full flex gap-1 items-center h-5 px-2",
                    ),
                  ],
                  [
                    html.span([class("hidden @3xl:flex")], [text("Month")]),
                    icon_calendar(),
                  ],
                ),
                html.button(
                  [
                    class(
                      "p-1 bg-color-12 text-color-2 rounded-full flex gap-1 items-center h-5 px-2",
                    ),
                  ],
                  [
                    html.span([class("hidden @3xl:flex")], [text("New Event")]),
                    icon_plus(),
                  ],
                ),
              ]),
            ],
          ),
          html.div(
            [class("w-full flex items-center overflow-hidden bg-color-2")],
            [
              html.div(
                [
                  attribute.id("column-headers"),
                  class(
                    "h-6 w-full flex items-center pl-10 overflow-x-auto pointer-events-none scrollbar-none",
                  ),
                ],
                list.map(state.date_range, fn(date) {
                  let is_current_day =
                    birl.get_day(date) == birl.get_day(state.now)

                  let count =
                    list.length(get_events_on_day(
                      state.events,
                      birl.get_day(date),
                    ))

                  let day = case state.week_day_width <. 180.0 {
                    True ->
                      string.slice(
                        from: birl.string_weekday(date),
                        at_index: 0,
                        length: 3,
                      )
                    False -> birl.string_weekday(date)
                  }

                  html.div(
                    [
                      class(
                        "h-6 flex translate-x-0 items-center justify-center shrink-0 grow",
                      ),
                      style([css.width_px(float.round(state.week_day_width))]),
                    ],
                    [
                      html.span([class("flex gap-1")], [
                        html.span(
                          [
                            class(case is_current_day {
                              True -> "text-color-12"
                              False -> "text-color-5"
                            }),
                          ],
                          [text(day)],
                        ),
                        html.span(
                          [
                            class(case is_current_day {
                              True -> "text-color-12"
                              False -> "text-color-1"
                            }),
                          ],
                          [text(int.to_string(birl.get_day(date).date))],
                        ),
                        html.span(
                          [
                            class(
                              "bg-color-3 text-color-5 px-[10px] border leading-none rounded-full text-xs flex items-center",
                            ),
                          ],
                          [text(int.to_string(count))],
                        ),
                      ]),
                    ],
                  )
                }),
              ),
            ],
          ),
          html.div([class("relative grid grid-cols-1 border-t")], [
            html.div([class("relative")], [
              view_calendar_week(filtered_events, state),
            ]),
          ]),
        ]),
      ],
    ),
    view_selected_events(state),
    // view_create_event(state),
  ])
}

fn view_selected_events(state: State) -> Element(Msg) {
  let any_selected = state.events |> list.any(fn(e) { e.selected })

  element.fragment([
    html.div(
      [
        on_click(UserDeselectedEvents),
        class("fixed inset-0 bg-color-1-50 transition-opacity duration-300"),
        classes([
          #("opacity-0 pointer-events-none", !any_selected),
          #("opacity-100 pointer-events-auto", any_selected),
        ]),
      ],
      [],
    ),
    element.fragment(
      list.map(state.events, fn(event) {
        let end = event.start |> birl.add(event.duration)

        html.div(
          [
            class(
              "fixed inset-0 overflow-y-auto flex p-2 flex-col pointer-events-none",
            ),
          ],
          [
            html.div(
              [
                class(
                  "bg-color-2 relative m-auto shrink-0 flex flex-col gap-3 max-w-64 min-h-10 w-full p-3 rounded-1 transition duration-300",
                ),
                classes([
                  #(
                    "opacity-0 translate-y-8 pointer-events-none delay-0",
                    !event.selected,
                  ),
                  #(
                    "opacity-100 translate-y-0 pointer-events-auto delay-100",
                    event.selected,
                  ),
                ]),
              ],
              [
                html.div([class("flex flex-col gap-1")], [
                  html.div([class("flex justify-between")], [
                    html.h2([class("text-3xl font-semibold pr-6")], [
                      text(event.name),
                    ]),
                    html.button(
                      [
                        attribute.attribute("title", "Close"),
                        on_click(UserDeselectedEvents),
                        class(
                          "size-6 top-0 right-0 absolute bg-color-12 rounded-tr-1 rounded-bl-1 text-color-2 flex items-center justify-center",
                        ),
                      ],
                      [icon_close()],
                    ),
                  ]),
                  html.span([], [
                    text(
                      birl.string_weekday(event.start)
                      <> ", "
                      <> birl.string_month(event.start)
                      <> " "
                      <> ordinal(birl.get_day(event.start).date),
                    ),
                    text(" - "),
                    text(format_hh_mm(event.start)),
                    text(" - "),
                    text(format_hh_mm(end)),
                  ]),
                ]),
                html.div([class("grid gap-3")], [
                  case list.is_empty(event.tasks) {
                    False ->
                      html.div([class("flex flex-col gap-1")], [
                        html.h2([class("text-xl font-semibold")], [
                          text("Tasks"),
                        ]),
                        view_event_task_list(event),
                      ])
                    True -> none()
                  },
                  html.div([class("flex flex-col gap-1")], [
                    html.h2([class("text-xl font-semibold")], [text("Guests")]),
                    view_attendee_list(event.attendees),
                  ]),
                ]),
              ],
            ),
          ],
        )
      }),
    ),
  ])
}

fn view_sidebar(state: State) -> Element(Msg) {
  let range = state.date_range
  let filtered_events =
    list.filter(state.events, fn(event) {
      string.contains(
        does: lowercase(event.name),
        contain: lowercase(state.keyword),
      )
    })
  let filtered_range =
    list.filter(range, fn(date) {
      has_events_on_day(filtered_events, birl.get_day(date))
    })

  html.div(
    [
      class(
        "hidden md:flex flex-col gap-2 p-2 pb-0 border-r bg-color-2 h-dvh overflow-hidden",
      ),
    ],
    [
      html.div(
        [class("border grid grid-cols-[1fr_2.5rem] rounded-1 relative")],
        [
          html.input([
            attribute.value(state.keyword),
            event.on_input(UserSearchedEvent),
            class("h-5 p-1 px-2 w-full bg-transparent"),
            attribute.placeholder("Search event"),
          ]),
          html.button(
            [
              class("size-5 flex items-center justify-center rounded-1"),
              attribute.attribute("title", "Search"),
            ],
            [
              html.span(
                [
                  class(
                    "size-4 bg-color-12 text-color-2 rounded-2 flex items-center justify-center",
                  ),
                ],
                [icon_search()],
              ),
            ],
          ),
        ],
      ),
      html.div(
        [class("overflow-y-auto flex flex-col grow shrink smooth-scroll")],
        list.map(filtered_range, fn(date) {
          let events = get_events_on_day(filtered_events, birl.get_day(date))
          html.div([], [
            html.h3(
              [
                class(
                  "bg-color-13 text-color-12 p-1 pl-4 h-6 items-center flex font-semibold rounded-1",
                ),
              ],
              [
                text(
                  birl.string_weekday(date)
                  <> ", "
                  <> ordinal(birl.get_day(date).date),
                ),
              ],
            ),
            ..list.map(events, fn(event) {
              let end = event.start |> birl.add(event.duration)
              let is_now = is_between(event.start, end, state.now)
              let border_color = case is_now {
                True -> "border-red-500"
                False ->
                  case event.event_type {
                    model.Assignment -> "border-color-6"
                    model.Story -> "border-color-8"
                    model.Bug -> "border-color-10"
                    _ -> "border-color-12"
                  }
              }

              html.div(
                [
                  class("py-2 ml-4 border-b last:border-0"),
                  on_click(UserClickedEventInSidebar(event)),
                ],
                [
                  html.h4(
                    [
                      class("border-l-2 pl-1 text-xl leading-none font-normal"),
                      class(border_color),
                    ],
                    [text(event.name)],
                  ),
                  html.span(
                    [
                      class("leading-none flex gap-1 pl-0 mt-2 "),
                      classes([
                        #("text-red-500", is_now),
                        #("text-color-5 contrast-more:text-color-1", !is_now),
                      ]),
                    ],
                    [
                      case is_now {
                        True -> icon_bell()
                        False -> icon_clock()
                      },
                      html.span([], [
                        text(format_hh_mm(event.start)),
                        text(" - "),
                        text(format_hh_mm(
                          event.start |> birl.add(event.duration),
                        )),
                      ]),
                    ],
                  ),
                ],
              )
            })
          ])
        }),
      ),
    ],
  )
}

fn get_attendees_for_this_week(state: State) -> List(User) {
  let attending_user_ids =
    state.date_range
    |> list.flat_map(fn(date) {
      state.events
      |> get_events_on_day(birl.get_day(date))
      |> list.flat_map(fn(event) {
        list.map(event.attendees, fn(attendee) { attendee.user.id })
      })
    })

  state.users
  |> list.filter(fn(user) { list.contains(attending_user_ids, user.id) })
}

fn view_member_filter(state: State) {
  let width = state.calendar_rect.width
  let content_width = 672.0
  let full_button_width = 400.0
  let compact_button_width = 240.0
  let button_width = case width <. content_width {
    True -> compact_button_width
    False -> full_button_width
  }

  let users = get_attendees_for_this_week(state)
  let available_width = width -. button_width
  let amount = float.round(available_width /. 24.0)
  let initial = list.take(users, amount)

  html.div([class("flex items-center gap-2")], [
    html.div(
      [
        class(
          "flex flex-grow items-center gap-0 relative justify-end items-center h-4",
        ),
      ],
      list.index_map(initial, fn(user, i) {
        let has_user_filter = !list.is_empty(state.selected_user_ids)
        let is_selected = list.contains(state.selected_user_ids, user.id)
        let is_muted = has_user_filter && !is_selected

        html.button(
          [
            attribute.attribute(
              "title",
              "Only show events attended by "
                <> user.first_name
                <> " "
                <> user.last_name,
            ),
            class("absolute top-0 flex-shrink-0 size-4 bg-white rounded-full"),
            style([css.left_px(i * 24)]),
            classes([#("z-10", is_selected)]),
            classes([#("hover:z-10", is_muted)]),
            on_click(UserFilteredEventsByUser(user)),
          ],
          [view_user_avatar(user, is_muted)],
        )
      }),
    ),
    // html.span([], [text(int.to_string(list.length(state.users)) <> " members")]),
  ])
}

fn view_user_avatar(user: User, is_muted: Bool) {
  html.img([
    class(
      "rounded-full size-4 flex-shrink-0 border border-white hover:opacity-100",
    ),
    classes([#("opacity-20", is_muted)]),
    attribute.alt(""),
    attribute.height(32),
    attribute.width(32),
    attribute.src(get_user_avatar_url(user)),
  ])
}

fn get_user_avatar_url(user: User) -> String {
  "./img/" <> int.to_string(user.id) <> ".webp"
}

fn view_calendar_week(
  filtered_events: List(Event),
  state: State,
) -> Element(Msg) {
  let initial = list.take(state.date_range, 1)
  let hour_height = state.minute_height * 60

  element(
    "lifecycle-events",
    [
      attribute.id("vertical-scroll"),
      on("mounted", fn(event) {
        use detail <- result.try(dynamic.field("detail", dynamic.dynamic)(event))
        use rect <- result.try(dynamic.field("rect", dom_rect_decoder())(detail))
        Ok(MountedCalendarVertically(rect))
      }),
      class("flex overflow-y-auto absolute w-full inset-0"),
    ],
    [
      element.fragment(list.map(initial, view_calendar_hours(_, state))),
      element(
        "lifecycle-events",
        [
          attribute.id("horizontal-scroll"),
          style([css.height_px(24 * hour_height)]),
          on("mounted", fn(event) {
            use detail <- result.try(dynamic.field("detail", dynamic.dynamic)(
              event,
            ))
            use rect <- result.try(dynamic.field("rect", dom_rect_decoder())(
              detail,
            ))
            Ok(MountedCalendarHorizontally(rect))
          }),
          on("resize", fn(event) {
            use detail <- result.try(dynamic.field("detail", dynamic.dynamic)(
              event,
            ))
            use rect <- result.try(dynamic.field("rect", dom_rect_decoder())(
              detail,
            ))
            Ok(ResizedCalendar(rect))
          }),
          on("scroll", fn(event) {
            use target <- result.try(dynamic.field("target", dynamic.dynamic)(
              event,
            ))
            use scroll_left <- result.try(dynamic.field(
              "scrollLeft",
              dynamic.float,
            )(target))
            Ok(ScrolledCalendarHorizontally(scroll_left))
          }),
          class(
            "flex relative overscroll-x-contain overflow-y-hidden overflow-x-auto gap-0 w-full scroll-smooth snap-x snap-mandatory bg-color-4",
          ),
        ],
        list.map(state.date_range, view_calendar_day(_, filtered_events, state)),
      ),
    ],
  )
}

fn get_events_on_day(events: List(Event), day: birl.Day) -> List(Event) {
  list.filter(events, fn(event) { birl.get_day(event.start) == day })
}

fn has_events_on_day(events: List(Event), day: birl.Day) -> Bool {
  list.any(events, fn(event) { birl.get_day(event.start) == day })
}

fn view_calendar_day(
  date: Time,
  filtered_events: List(Event),
  state: State,
) -> Element(Msg) {
  let day_events = get_events_on_day(filtered_events, birl.get_day(date))
  let hours = get_hours_for_date(date)
  let hour_height = state.minute_height * 60
  let is_current_day = birl.get_day(date) == birl.get_day(state.now)
  let minutes_elapsed = get_total_minutes(state.now)

  html.div(
    [
      class("flex flex-col shrink-0 grow relative snap-start border-r"),
      classes([#("lines-deg-60", is_current_day)]),
      style([
        css.height_px(24 * hour_height),
        css.width_px(float.round(state.week_day_width)),
      ]),
    ],
    list.concat([
      list.map(hours, view_calendar_hour(_, is_current_day, state)),
      [
        html.div(
          [
            class("absolute top-0 left-0 h-[2px] bg-color-12 w-full"),
            style([
              css.top_px({ minutes_elapsed * state.minute_height } - 1),
              #("width", "calc(100% + 1px)"),
            ]),
          ],
          [],
        ),
      ],
      list.map(day_events, view_event_card(_, state)),
    ]),
  )
}

fn view_calendar_hours(date: Time, state: State) -> Element(Msg) {
  let hour_height = state.minute_height * 60
  let hours = get_hours_for_date(date)
  let minutes_elapsed = get_total_minutes(state.now)

  html.div(
    [
      class("flex flex-col bg-color-3 min-w-10 relative"),
      style([css.height_px(24 * hour_height)]),
    ],
    list.concat([
      list.map(hours, view_calendar_hour_label(_, state)),
      [
        html.div(
          [
            class(
              "absolute text-center text-xs top-0 left-2 rounded-2 right-2 h-3 text-color-2 flex justify-center items-center bg-color-12",
            ),
            style([css.top_px({ minutes_elapsed * state.minute_height } - 12)]),
          ],
          [text(format_hh_mm(state.now))],
        ),
        html.div(
          [
            class(
              "absolute text-center z-10 text-xs top-0 rounded-2 -right-[2px] size-1 text-color-2 bg-color-12",
            ),
            style([css.top_px({ minutes_elapsed * state.minute_height } - 4)]),
          ],
          [],
        ),
      ],
    ]),
  )
}

fn view_calendar_hour_label(time: Time, state: State) -> Element(Msg) {
  let hour = birl.get_time_of_day(time).hour
  let hour_height = state.minute_height * 60

  html.div(
    [
      class(
        "flex flex-col text-color-1-50 absolute left-0 text-center w-full h-8 -translate-y-4 justify-center",
      ),
      style([css.top_px(hour * hour_height)]),
    ],
    case hour {
      0 -> []
      _ -> [text(format_hh_mm(time))]
    },
  )
}

fn view_calendar_hour(
  time: Time,
  is_current_day: Bool,
  state: State,
) -> Element(Msg) {
  let hour = birl.get_time_of_day(time).hour
  let hour_height = state.minute_height * 60

  html.div(
    [
      class("flex flex-col absolute left-0 w-full"),
      classes([#("bg-color-2", !is_current_day)]),
      style([css.top_px(hour * hour_height), css.height_px(hour_height - 1)]),
    ],
    [],
  )
}

fn is_between(start: Time, stop: Time, current: Time) -> Bool {
  let timestamp = birl.to_unix(current)
  timestamp >= birl.to_unix(start) && timestamp < birl.to_unix(stop)
}

fn get_event_border_color(event: Event) {
  case event.event_type {
    model.Assignment -> "border-color-6"
    model.Story -> "border-color-8"
    model.Bug -> "border-color-10"
    _ -> "border-color-12"
  }
}

fn get_event_text_color(event: Event) {
  case event.event_type {
    model.Assignment -> "text-color-6"
    model.Story -> "text-color-8"
    model.Bug -> "text-color-10"
    _ -> "text-color-12"
  }
}

fn get_event_bg_color(event: Event) {
  case event.event_type {
    model.Assignment -> "bg-color-7"
    model.Story -> "bg-color-9"
    model.Bug -> "bg-color-11"
    _ -> "bg-color-13"
  }
}

fn view_event_card(event: Event, state: State) {
  let minute_height = state.minute_height
  let start = birl.get_time_of_day(event.start)
  let minutes = { start.hour * 60 } + start.minute
  let duration_minutes = duration.blur_to(event.duration, duration.Minute)
  let top = minutes * minute_height
  let event_height = duration_minutes * minute_height
  let end = event.start |> birl.add(event.duration)
  let is_now = is_between(event.start, end, state.now)
  let visible_attendee_count: Int =
    float.round({ state.week_day_width -. 124.0 } /. 24.0)

  let border_color = get_event_border_color(event)
  let text_color = get_event_text_color(event)
  let bg_color = get_event_bg_color(event)

  html.div(
    [
      class("w-full absolute left-0 p-[4px]"),
      style([css.top_px(top - 1), css.height_px(event_height + 1)]),
    ],
    [
      html.div(
        [
          on_click(UserSelectedEvent(event)),
          class(
            "flex flex-col gap-1 border h-full rounded-2 hover:shadow-md cursor-pointer",
          ),
          class(bg_color),
          class(border_color),
          classes([
            #("px-2 justify-center", duration_minutes <= 15),
            #("p-2", duration_minutes > 15),
            #("shadow-xl hover:shadow-xl", is_now),
          ]),
        ],
        [
          html.div([class("flex gap-1 items-center")], [
            html.h2(
              [
                classes([
                  #("line-clamp-2", duration_minutes <= 30),
                  #(
                    "line-clamp-2",
                    duration_minutes > 30 && duration_minutes <= 90,
                  ),
                  #("line-clamp-3", duration_minutes > 90),
                ]),
                class(text_color),
                classes([
                  #("text-xs", duration_minutes <= 15),
                  #(
                    "text-base",
                    duration_minutes > 15 && duration_minutes <= 30,
                  ),
                  #("text-xl", duration_minutes > 30),
                  #("leading-none", duration_minutes <= 15),
                  #("leading-tight", duration_minutes > 15),
                ]),
              ],
              [text(event.name)],
            ),
          ]),
          case duration_minutes >= 45 {
            False -> none()
            True ->
              html.span([class("leading-none font-light"), class(text_color)], [
                text(format_hh_mm(event.start)),
                text(" - "),
                text(format_hh_mm(end)),
              ])
          },
          case duration_minutes >= 60 {
            False -> none()
            True ->
              case event.attendees {
                [] -> none()
                _ ->
                  view_attendee_avatar_list(
                    state,
                    event,
                    visible_attendee_count,
                  )
              }
          },
        ],
      ),
    ],
  )
}

fn view_attendee_avatar_list(state: State, event: Event, visible_count: Int) {
  let border_color = get_event_border_color(event)
  let text_color = get_event_text_color(event)
  let attendees = event.attendees

  let initial = case list.is_empty(state.selected_user_ids) {
    True -> list.take(attendees, visible_count)
    False ->
      list.filter(attendees, fn(attendee) {
        list.contains(state.selected_user_ids, attendee.user.id)
      })
  }
  let rest_count = list.length(attendees) - list.length(initial)

  html.div(
    [class("flex gap-0 relative justify-end items-center h-4 mt-auto")],
    list.concat([
      list.index_map(initial, fn(attendee, i) {
        let is_muted = False

        html.div(
          [
            class("absolute top-0 flex-shrink-0 bg-white rounded-full"),
            style([css.left_px(i * 24)]),
          ],
          [view_user_avatar(attendee.user, is_muted)],
        )
      }),
      [
        case rest_count {
          0 -> none()
          _ ->
            html.button(
              [
                class("px-[12px] h-full rounded-full border"),
                class(text_color),
                class(border_color),
                attribute.attribute("title", "View attendees"),
              ],
              [text("+" <> int.to_string(rest_count))],
            )
        },
      ],
    ]),
  )
}

fn view_event_task_list(event: Event) -> Element(Msg) {
  html.div(
    [class("flex flex-col gap-1")],
    list.map(event.tasks, fn(task) {
      html.div(
        [
          class("flex items-center gap-1 justify-between cursor-pointer"),
          event.on_click(UserToggledTask(event, task)),
        ],
        [
          html.span(
            [
              classes([
                #("line-through", task.done),
                #("text-color-5", task.done),
              ]),
            ],
            [text(task.name)],
          ),
          view_checkbox(checked: task.done),
        ],
      )
    }),
  )
}

fn view_checkbox(checked checked: Bool) {
  html.div(
    [
      class("size-3 rounded-full flex flex-col items-center justify-center"),
      classes([
        #("bg-color-8", checked),
        #("text-color-2", checked),
        #("bg-color-4", !checked),
      ]),
    ],
    [
      case checked {
        True -> icon_check()
        False -> none()
      },
    ],
  )
}

fn view_attendee_list(users: List(Attendee)) {
  html.div(
    [class("flex flex-col gap-1")],
    list.map(users, view_attendee_list_item(_)),
  )
}

fn view_attendee_list_item(invite: Attendee) {
  html.div([class("flex items-center gap-1 h-4")], [
    view_user_avatar(invite.user, False),
    html.span([], [text(invite.user.first_name <> " " <> invite.user.last_name)]),
    view_attendee_status(invite),
  ])
}

fn view_attendee_status(invite: Attendee) {
  html.div(
    [
      class(
        "px-2 h-full flex gap-1 items-center bg-color-3 text-xs justify-self-end ml-auto rounded-full",
      ),
      classes([
        #("bg-color-4", invite.accepted),
        #("text-color-1", invite.accepted),
        #("bg-color-3", !invite.accepted),
        #("text-color-5", !invite.accepted),
      ]),
    ],
    [
      text(case invite.accepted {
        True -> "Accepted"
        False -> "Pending"
      }),
      case invite.accepted {
        True -> icon_check()
        False -> icon_clock()
      },
    ],
  )
}

fn view_create_event(state: State) -> Element(Msg) {
  html.div([class("absolute inset-0 bg-color-1-30 p-2")], [
    html.div([class("w-64 bg-color-2 p-3 rounded-2")], [
      html.div([class("flex flex-col gap-1")], [
        html.div([], [
          html.label([], [text("Date & Time")]),
          html.input([
            attribute.value("2024-06-24"),
            attribute.type_("date"),
            class("w-full border p-1 rounded-1"),
          ]),
        ]),
        html.div([class("grid grid-cols-2 gap-1")], [
          html.input([
            attribute.type_("time"),
            attribute.value("08:00"),
            class("w-full border p-1 rounded-1"),
          ]),
          html.input([
            attribute.type_("time"),
            attribute.value("08:00"),
            event.on_input(UserUpdatedEndTime),
            class("w-full border p-1 rounded-1"),
          ]),
        ]),
      ]),
    ]),
  ])
}
