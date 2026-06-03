import { Body, Controller, Get, Inject, Param, Post } from '@nestjs/common'
import { CalendarService } from './calendar.service.js'
import type { CreateBookingRequest, CreateEventTypeRequest } from './calendar.types.js'

@Controller()
export class CalendarController {
  constructor(@Inject(CalendarService) private readonly calendar: CalendarService) {}

  @Get('/admin/event-types')
  listAdminEventTypes() {
    return this.calendar.listEventTypes()
  }

  @Post('/admin/event-types')
  createEventType(@Body() request: CreateEventTypeRequest) {
    return this.calendar.createEventType(request)
  }

  @Get('/admin/bookings')
  listAdminBookings() {
    return this.calendar.listUpcomingBookings()
  }

  @Get('/event-types')
  listPublicEventTypes() {
    return this.calendar.listEventTypes()
  }

  @Get('/event-types/:eventTypeId/slots')
  listSlots(@Param('eventTypeId') eventTypeId: string) {
    return this.calendar.listSlots(eventTypeId)
  }

  @Post('/bookings')
  createBooking(@Body() request: CreateBookingRequest) {
    return this.calendar.createBooking(request)
  }
}
