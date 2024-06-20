import birl.{type Time, TimeOfDay}
import birl/duration
import gleam/int
import gleam/iterator.{to_list}
import gleam/option.{Some}
import gleam/string

pub fn get_total_minutes(time: Time) -> Int {
  let time_of_day = birl.get_time_of_day(time)
  { time_of_day.hour * 60 } + time_of_day.minute
}

fn pad_left_time(value: Int) -> String {
  string.pad_left(int.to_string(value), to: 2, with: "0")
}

pub fn format_hh_mm(date: Time) -> String {
  let time_of_day = birl.get_time_of_day(date)
  let hour = time_of_day.hour
  let minute = time_of_day.minute

  pad_left_time(hour) <> ":" <> pad_left_time(minute)
}

pub fn set_start_of_day(date: Time) -> Time {
  birl.set_time_of_day(
    date,
    TimeOfDay(hour: 0, minute: 0, second: 0, milli_second: 0),
  )
}

pub fn get_hours_for_date(date: Time) -> List(Time) {
  let from = set_start_of_day(date)
  let to = birl.add(from, duration.hours(23))

  to_list(birl.range(from: from, to: Some(to), step: duration.hours(1)))
}

pub fn set_hour(date: Time, hour: Int) {
  birl.set_time_of_day(
    date,
    TimeOfDay(hour: hour, minute: 0, second: 0, milli_second: 0),
  )
}

pub fn ordinal(num: Int) -> String {
  let j = num % 10
  let k = num % 100
  let v = int.to_string(num)
  case j {
    1 ->
      case k != 11 {
        True -> v <> "st"
        False -> v <> "th"
      }
    2 ->
      case k != 12 {
        True -> v <> "nd"
        False -> v <> "th"
      }
    3 ->
      case k != 13 {
        True -> v <> "rd"
        False -> v <> "th"
      }
    _ -> v <> "th"
  }
}
