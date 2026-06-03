import "@typespec/http";
import "@typespec/openapi3";

using Http;

@service(#{
  title: "Calendar Booking API",
})
@server("http://localhost:3000", "Локальный сервер разработки")
@doc("""
Design First контракт для простого приложения бронирования календаря.

В приложении нет регистрации и авторизации. Владелец календаря — один заранее
заданный профиль, который используется в админской части. Гости бронируют
доступные слоты без создания аккаунта.

Правила доступности:
- Слоты вычисляются, а не создаются владельцем вручную.
- Слоты формируются на 14 дней, начиная с текущей даты.
- Базовая доступность: каждый день с 09:00 до 18:00 по локальному времени приложения.
- Шаг сетки слотов равен длительности выбранного типа события.
- Бронирование можно создать только для свободного слота из 14-дневного окна.
- Две брони не могут занимать одно и то же время начала или пересекающийся
  временной интервал, даже если относятся к разным типам событий.
""")
namespace CalendarBooking;

@doc("Заранее заданный профиль владельца календаря. Профиль есть в домене, но не управляется через API.")
model Owner {
  @doc("Стабильный идентификатор владельца.")
  id: string;

  @doc("Отображаемое имя владельца на страницах календаря.")
  name: string;

  @doc("Часовой пояс владельца, который используется для отображения и расчета локальной доступности.")
  timezone: string;
}

@doc("Тип встречи, который гость может забронировать.")
model EventType {
  @doc("Стабильный идентификатор типа события.")
  id: string;

  @doc("Публичное название типа события.")
  title: string;

  @doc("Публичное описание типа события.")
  description: string;

  @doc("Длительность встречи в минутах. Это значение также определяет шаг генерируемых слотов.")
  @minValue(1)
  durationMinutes: int32;
}

@doc("Данные, которые владелец передает при создании типа события.")
model CreateEventTypeRequest {
  @doc("Публичное название типа события.")
  title: string;

  @doc("Публичное описание типа события.")
  description: string;

  @doc("Длительность встречи в минутах. Это значение также определяет шаг генерируемых слотов.")
  @minValue(1)
  durationMinutes: int32;
}

@doc("Вычисленный свободный временной интервал для выбранного типа события.")
model Slot {
  @doc("Тип события, для которого рассчитан этот слот.")
  eventTypeId: string;

  @doc("Дата и время начала слота.")
  startAt: utcDateTime;

  @doc("Дата и время окончания слота. Значение равно startAt плюс длительность типа события.")
  endAt: utcDateTime;

  @doc("Длительность, скопированная из выбранного типа события.")
  durationMinutes: int32;
}

@doc("Бронирование гостя для выбранного типа события и слота.")
model Booking {
  @doc("Стабильный идентификатор бронирования.")
  id: string;

  @doc("Забронированный тип события.")
  eventType: EventType;

  @doc("Отображаемое имя гостя.")
  guestName: string;

  @doc("Электронная почта гостя, которая используется как контакт в списке встреч владельца.")
  guestEmail: string;

  @doc("Дата и время начала бронирования.")
  startAt: utcDateTime;

  @doc("Дата и время окончания бронирования, рассчитанные из startAt и eventType.durationMinutes.")
  endAt: utcDateTime;

  @doc("Дата и время создания бронирования.")
  createdAt: utcDateTime;
}

@doc("Данные, которые гость передает при создании бронирования.")
model CreateBookingRequest {
  @doc("Идентификатор выбранного типа события.")
  eventTypeId: string;

  @doc("Дата и время начала выбранного слота.")
  startAt: utcDateTime;

  @doc("Отображаемое имя гостя.")
  guestName: string;

  @doc("Электронная почта гостя.")
  guestEmail: string;
}

@doc("Стандартный ответ API с ошибкой.")
model ErrorResponse {
  @doc("Машиночитаемый код ошибки.")
  code: string;

  @doc("Человекочитаемое сообщение об ошибке.")
  message: string;
}

@doc("Тип события не существует.")
@error
model NotFoundError {
  code: "NOT_FOUND";
  message: string;
}

@doc("Запрос нарушает правила входных данных или бизнес-валидации.")
@error
model ValidationError {
  code: "VALIDATION_ERROR";
  message: string;
}

@doc("Запрошенный слот конфликтует с существующим бронированием.")
@error
model ConflictError {
  code: "BOOKING_CONFLICT";
  message: string;
}

model EventTypesOkResponse {
  @statusCode statusCode: 200;
  @body eventTypes: EventType[];
}

model EventTypeCreatedResponse {
  @statusCode statusCode: 201;
  @body eventType: EventType;
}

model BookingsOkResponse {
  @statusCode statusCode: 200;
  @body bookings: Booking[];
}

model SlotsOkResponse {
  @statusCode statusCode: 200;
  @body slots: Slot[];
}

model BookingCreatedResponse {
  @statusCode statusCode: 201;
  @body booking: Booking;
}

model NotFoundResponse {
  @statusCode statusCode: 404;
  @body error: NotFoundError;
}

model ValidationErrorResponse {
  @statusCode statusCode: 422;
  @body error: ValidationError;
}

model ConflictErrorResponse {
  @statusCode statusCode: 409;
  @body error: ConflictError;
}

alias EventTypeCreateResponse = EventTypeCreatedResponse | ValidationErrorResponse;
alias EventTypeListResponse = EventTypesOkResponse | ValidationErrorResponse;
alias BookingCreateResponse =
  | BookingCreatedResponse
  | NotFoundResponse
  | ValidationErrorResponse
  | ConflictErrorResponse;
alias BookingListResponse = BookingsOkResponse | ValidationErrorResponse;
alias SlotListResponse = SlotsOkResponse | NotFoundResponse | ValidationErrorResponse;

@tag("Admin")
@route("/admin/event-types")
interface AdminEventTypes {
  @doc("Вернуть типы событий, видимые владельцу в админской части.")
  @get
  list(): EventTypeListResponse;

  @doc("Создать тип события. Редактирование и удаление типов событий не входят в этот контракт.")
  @post
  create(@body request: CreateEventTypeRequest): EventTypeCreateResponse;
}

@tag("Admin")
@route("/admin/bookings")
interface AdminBookings {
  @doc("Вернуть предстоящие бронирования по всем типам событий, отсортированные по startAt по возрастанию.")
  @get
  listUpcoming(): BookingListResponse;
}

@tag("Guest")
@route("/event-types")
interface PublicEventTypes {
  @doc("Вернуть типы событий, доступные гостям.")
  @get
  list(): EventTypeListResponse;
}

@tag("Guest")
@route("/event-types/{eventTypeId}/slots")
interface PublicSlots {
  @doc("""
  Вернуть свободные слоты для выбранного типа события.

  Слоты рассчитываются на ближайшие 14 дней от текущей даты, в интервале
  с 09:00 до 18:00 по локальному времени приложения. Шаг сетки слотов равен
  длительности типа события. Уже забронированные интервалы исключаются по всем
  типам событий.
  """)
  @get
  list(@path eventTypeId: string): SlotListResponse;
}

@tag("Guest")
@route("/bookings")
interface PublicBookings {
  @doc("""
  Создать бронирование гостя для выбранного слота.

  Сервер рассчитывает endAt из длительности выбранного типа события и проверяет,
  что запрошенный startAt относится к сгенерированному свободному слоту.
  Возвращает 409, если интервал конфликтует с существующим бронированием.
  Возвращает 422, если слот находится вне 14-дневного окна, вне доступности
  09:00-18:00 или не совпадает с шагом сетки для типа события.
  """)
  @post
  create(@body request: CreateBookingRequest): BookingCreateResponse;
}
