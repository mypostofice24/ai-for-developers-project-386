import { CalendarDate, type DateValue } from '@internationalized/date'

const dateFormatter = new Intl.DateTimeFormat('ru-RU', {
  day: 'numeric',
  month: 'long',
  year: 'numeric',
})

const shortDateFormatter = new Intl.DateTimeFormat('ru-RU', {
  weekday: 'long',
  day: 'numeric',
  month: 'long',
})

const timeFormatter = new Intl.DateTimeFormat('ru-RU', {
  hour: '2-digit',
  minute: '2-digit',
})

export function formatDateTime(value: string) {
  const date = new Date(value)

  return `${dateFormatter.format(date)}, ${timeFormatter.format(date)}`
}

export function formatDate(value: string) {
  return dateFormatter.format(new Date(value))
}

export function formatShortDate(value: string) {
  return shortDateFormatter.format(new Date(value))
}

export function formatTime(value: string) {
  return timeFormatter.format(new Date(value))
}

export function getDateKey(value: string | Date) {
  const date = typeof value === 'string' ? new Date(value) : value
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')

  return `${year}-${month}-${day}`
}

export function calendarDateToKey(value: DateValue) {
  const month = String(value.month).padStart(2, '0')
  const day = String(value.day).padStart(2, '0')

  return `${value.year}-${month}-${day}`
}

export function calendarDateFromKey(value: string) {
  const [year = 0, month = 1, day = 1] = value.split('-').map(Number)

  return new CalendarDate(year, month, day)
}
