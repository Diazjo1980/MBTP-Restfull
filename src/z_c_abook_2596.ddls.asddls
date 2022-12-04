@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Booking Approvals'
@Metadata.allowExtensions: true
define view entity Z_C_ABOOK_2596
  as projection on Z_I_BOOK_2596
{

  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      @ObjectModel.text.element: ['CarrierName']
      carrier_id,
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
      _Travel : redirected to parent Z_C_ATRAVEL_2596,
      _Customer,
      _Carrier

}
