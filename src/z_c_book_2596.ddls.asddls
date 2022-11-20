@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Booking'
@Metadata.allowExtensions: true
define view entity Z_C_BOOK_2596
  as projection on Z_I_BOOK_2596
{



  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      @ObjectModel.text.element: ['CarrierName']
      CarrierId,
      _Carrier.Name as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      FlightPrice,
      @Semantics.currencyCode: true
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _Travel: redirected to parent Z_C_TRAVEL_2596,
      _BookingSupplement : redirected to composition child Z_C_BOOKSUPPL_2596,
      _Carrier,
      _Connection,
      _Customer

}
