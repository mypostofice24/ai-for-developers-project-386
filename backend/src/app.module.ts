import { Module } from '@nestjs/common'
import { CalendarModule } from './calendar/calendar.module.js'

@Module({
  imports: [CalendarModule],
})
export class AppModule {}
