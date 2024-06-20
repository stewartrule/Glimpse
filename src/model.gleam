import birl.{type Time}
import birl/duration.{type Duration}

pub type DomRect {
  DomRect(
    x: Float,
    y: Float,
    width: Float,
    height: Float,
    top: Float,
    right: Float,
    bottom: Float,
    left: Float,
  )
}

pub type Msg {
  UserUpdatedEndTime(String)
  UserSearchedEvent(String)
  UserSelectedEvent(Event)
  UserDeselectedEvent(Event)
  UserDeselectedEvents
  UserClickedEventInSidebar(Event)
  UserToggledTask(Event, Task)
  ResizedCalendar(DomRect)
  MountedCalendarVertically(DomRect)
  MountedCalendarHorizontally(DomRect)
  ScrolledCalendarHorizontally(Float)
  UserFilteredEventsByUser(User)
}

pub type User {
  User(id: Int, first_name: String, last_name: String)
}

pub type Attendee {
  Attendee(user: User, accepted: Bool)
}

pub type Task {
  Task(id: Int, name: String, done: Bool)
}

pub type EventType {
  Assignment
  Bug
  Story
  Research
}

pub type Event {
  Event(
    id: Int,
    name: String,
    attendees: List(Attendee),
    tasks: List(Task),
    start: Time,
    duration: Duration,
    event_type: EventType,
    selected: Bool,
    was_selected: Bool,
  )
}

pub type CalendarDisplay {
  Day
  Week
  Month
}

pub type State {
  State(
    users: List(User),
    calendar_display: CalendarDisplay,
    events: List(Event),
    date_range: List(Time),
    now: Time,
    minute_height: Int,
    week_day_width: Float,
    week_scroll_left: Float,
    calendar_rect: DomRect,
    keyword: String,
    selected_user_ids: List(Int),
  )
}
