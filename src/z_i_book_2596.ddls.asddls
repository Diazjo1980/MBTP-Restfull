@AbapCatalog.sqlViewName: 'ZV_BOOK_2596'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Bookings'
define view Z_I_BOOK_2596
  as select from ztb_booking_2596 as Booking
  composition [0..*] of Z_I_BOOKSUPPL_2596 as _BookingSupplement
  association        to parent Z_I_TRAVEL_2596    as _Travel on $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Customer    as _Customer      on $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier     as _Carrier       on $projection.carrier_id = _Carrier.AirlineID
  association [1..*] to /DMO/I_Connection  as _Connection    on $projection.ConnectionId = _Connection.ConnectionID
{

  key Booking.travel_id       as TravelId,
  key Booking.booking_id      as BookingId,
      Booking.booking_date    as BookingDate,
      Booking.customer_id     as CustomerId,
      Booking.carrier_id,
      Booking.connection_id   as ConnectionId,
      Booking.flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Booking.flight_price    as FlightPrice,
      @Semantics.currencyCode: true
      Booking.currency_code   as CurrencyCode,
      Booking.booking_status  as BookingStatus,
      Booking.last_changed_at as LastChangedAt,
      _Travel,
      _BookingSupplement,
      _Customer,
      _Carrier,
      _Connection

}
