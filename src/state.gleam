import birl.{type Time, TimeOfDay}
import birl/duration
import gleam/iterator.{to_list}
import gleam/list
import gleam/option.{Some}

import model.{
  type Attendee, type Event, type State, type User, Assignment, Attendee, Bug,
  DomRect, Event, Research, State, Story, Task, User,
}

fn get_attendees(users: List(User), user_ids: List(Int)) -> List(Attendee) {
  users
  |> list.filter(fn(user) { list.contains(user_ids, user.id) })
  |> list.map(fn(user) { Attendee(user: user, accepted: user.id % 3 != 0) })
}

fn get_date_range(from: Time, to: Time) -> List(Time) {
  birl.range(from: from, to: Some(to), step: duration.days(1))
  |> to_list
}

pub fn get_initial_state() -> State {
  let users = [
    User(id: 1, first_name: "Michelle", last_name: "Doe"),
    User(id: 2, first_name: "Jake", last_name: "Doe"),
    User(id: 3, first_name: "John", last_name: "Doe"),
    User(id: 4, first_name: "Michael", last_name: "Doe"),
    User(id: 5, first_name: "Jack", last_name: "Doe"),
    User(id: 6, first_name: "Lisa", last_name: "Doe"),
    User(id: 7, first_name: "Joanne", last_name: "Doe"),
    User(id: 8, first_name: "Phoebe", last_name: "Doe"),
    User(id: 9, first_name: "Joanne", last_name: "Doe"),
    User(id: 10, first_name: "Phoebe", last_name: "Doe"),
    User(id: 11, first_name: "Mike", last_name: "Doe"),
    User(id: 12, first_name: "David", last_name: "Doe"),
    User(id: 13, first_name: "Suzy", last_name: "Doe"),
    User(id: 14, first_name: "Joyce", last_name: "Doe"),
    User(id: 15, first_name: "Michelle", last_name: "Doe"),
    User(id: 16, first_name: "Jake", last_name: "Doe"),
    User(id: 17, first_name: "John", last_name: "Doe"),
    User(id: 18, first_name: "Michael", last_name: "Doe"),
    User(id: 19, first_name: "Jack", last_name: "Doe"),
    User(id: 20, first_name: "Lisa", last_name: "Doe"),
    User(id: 21, first_name: "Joanne", last_name: "Doe"),
    User(id: 22, first_name: "Phoebe", last_name: "Doe"),
    User(id: 23, first_name: "Joanne", last_name: "Doe"),
    User(id: 24, first_name: "Phoebe", last_name: "Doe"),
    User(id: 25, first_name: "Mike", last_name: "Doe"),
    User(id: 26, first_name: "David", last_name: "Doe"),
    User(id: 27, first_name: "Suzy", last_name: "Doe"),
    User(id: 28, first_name: "Joyce", last_name: "Doe"),
  ]

  let now = birl.now()
  let start_of_work_day =
    birl.set_time_of_day(
      now,
      TimeOfDay(hour: 9, minute: 0, second: 0, milli_second: 0),
    )
  let day = birl.weekday(start_of_work_day)
  let offset = case day {
    birl.Mon -> 0
    birl.Tue -> 1
    birl.Wed -> 2
    birl.Thu -> 3
    birl.Fri -> 4
    birl.Sat -> 5
    birl.Sun -> 6
  }
  let mon = start_of_work_day |> birl.subtract(duration.days(offset))

  let tue = birl.add(mon, duration.days(1))
  let wed = birl.add(mon, duration.days(2))
  let thu = birl.add(mon, duration.days(3))
  let fri = birl.add(mon, duration.days(4))
  let sat = birl.add(mon, duration.days(5))
  let sun = birl.add(mon, duration.days(6))

  let date_range: List(Time) =
    birl.range(from: mon, to: Some(sun), step: duration.days(1))
    |> to_list

  State(
    users: users,
    calendar_display: model.Week,
    events: [
      Event(
        id: 10,
        name: "Breakfast",
        attendees: get_attendees(users, [13, 7]),
        tasks: [],
        start: mon |> birl.subtract(duration.minutes(120)),
        duration: duration.minutes(30),
        event_type: Research,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 15,
        name: "Client Meeting",
        attendees: get_attendees(users, [1, 2, 3, 4, 5, 6, 7, 8]),
        tasks: [],
        start: mon |> birl.add(duration.minutes(30)),
        duration: duration.hours(1) |> duration.add(duration.minutes(30)),
        event_type: Story,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 20,
        name: "Water plants",
        attendees: get_attendees(users, [18]),
        tasks: [],
        start: mon |> birl.add(duration.minutes(420)),
        duration: duration.minutes(30),
        event_type: Story,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 25,
        name: "Standup",
        attendees: get_attendees(users, [12, 11, 10, 8, 1, 2, 3]),
        tasks: [],
        start: tue |> birl.add(duration.minutes(30)),
        duration: duration.minutes(15),
        event_type: Assignment,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 30,
        name: "Laydown",
        attendees: get_attendees(users, [9, 8, 7, 8, 1, 2, 3]),
        tasks: [],
        start: tue |> birl.add(duration.hours(3)),
        duration: duration.minutes(45),
        event_type: Story,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 35,
        name: "Retro",
        attendees: get_attendees(users, [5, 6, 7, 8, 1, 2, 3]),
        tasks: [],
        start: wed |> birl.add(duration.hours(4)),
        duration: duration.minutes(90),
        event_type: Assignment,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 40,
        name: "Create Design System",
        attendees: get_attendees(users, [5, 6, 7, 8, 1, 2, 3]),
        tasks: [
          Task(id: 1, name: "Define project goals and scope", done: True),
          Task(id: 2, name: "Research and Analysis", done: True),
          Task(id: 3, name: "Create a Core Team", done: False),
          Task(id: 4, name: "Design Language", done: False),
          Task(id: 5, name: "Component Library", done: False),
          Task(id: 6, name: "Documentation", done: False),
          Task(id: 7, name: "Testing and validation", done: False),
        ],
        start: wed |> birl.add(duration.hours(7)),
        duration: duration.hours(2),
        event_type: Story,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 45,
        name: "Diner",
        attendees: get_attendees(users, [24, 25]),
        tasks: [
          Task(id: 1, name: "Define project goals and scope", done: True),
          Task(id: 2, name: "Research and Analysis", done: True),
        ],
        start: wed |> birl.add(duration.hours(10)),
        duration: duration.minutes(90),
        event_type: Assignment,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 50,
        name: "Create Design System",
        attendees: get_attendees(users, [6, 7, 8, 1, 2, 3]),
        tasks: [
          Task(id: 1, name: "Define project goals and scope", done: True),
          Task(id: 2, name: "Research and Analysis", done: True),
          Task(id: 3, name: "Create a Core Team", done: False),
          Task(id: 4, name: "Design Language", done: False),
          Task(id: 5, name: "Component Library", done: False),
          Task(id: 6, name: "Documentation", done: False),
          Task(id: 7, name: "Testing and validation", done: False),
        ],
        start: thu |> birl.add(duration.hours(1)),
        duration: duration.hours(2),
        event_type: Assignment,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 55,
        name: "Fifa Campions League",
        attendees: get_attendees(users, [3, 4]),
        tasks: [],
        start: thu |> birl.add(duration.hours(7)),
        duration: duration.hours(1) |> duration.add(duration.minutes(15)),
        event_type: Assignment,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 60,
        name: "Job Interview",
        attendees: get_attendees(users, [8, 1, 2, 3, 9, 13, 7]),
        tasks: [],
        start: fri |> birl.add(duration.hours(2)),
        duration: duration.hours(2),
        event_type: Bug,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 65,
        name: "Vrijmibo",
        attendees: get_attendees(users, [7, 8, 18, 19, 20, 9, 1, 23, 5, 26]),
        tasks: [],
        start: fri |> birl.add(duration.hours(6)),
        duration: duration.hours(1) |> duration.add(duration.minutes(30)),
        event_type: Assignment,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 70,
        name: "Play pool",
        attendees: get_attendees(users, [26, 27, 28, 25, 24, 23]),
        tasks: [],
        start: fri |> birl.add(duration.hours(12)),
        duration: duration.hours(1) |> duration.add(duration.minutes(30)),
        event_type: Assignment,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 75,
        name: "Tequila!",
        attendees: get_attendees(users, [25, 26, 27, 28]),
        tasks: [],
        start: sat |> birl.subtract(duration.hours(6)),
        duration: duration.minutes(75),
        event_type: Research,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 80,
        name: "Lunch",
        attendees: get_attendees(users, [9, 8, 7, 3]),
        tasks: [],
        start: sat |> birl.add(duration.hours(3)),
        duration: duration.minutes(75),
        event_type: Research,
        selected: False,
        was_selected: False,
      ),
      Event(
        id: 85,
        name: "Lunch",
        attendees: get_attendees(users, [5, 8, 1, 2]),
        tasks: [],
        start: sun |> birl.add(duration.hours(3)),
        duration: duration.minutes(75),
        event_type: Research,
        selected: False,
        was_selected: False,
      ),
    ],
    date_range: date_range,
    now: now,
    minute_height: 2,
    week_day_width: 200.0,
    week_scroll_left: 0.0,
    keyword: "",
    calendar_rect: DomRect(
      x: 0.0,
      y: 0.0,
      width: 375.0,
      height: 375.0,
      top: 0.0,
      right: 375.0,
      bottom: 375.0,
      left: 0.0,
    ),
    selected_user_ids: [],
  )
}
