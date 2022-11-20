@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Booking Supplements'
@Metadata.allowExtensions: true
define view entity Z_C_BOOKSUPPL_2596
  as projection on Z_I_BOOKSUPPL_2596
{

  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: ['SupplementDescription']
      SupplementId,
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode : 'currency'
      Price,
      @Semantics.currencyCode: true
      Currency,
      LastChangedAt,
      /* Associations */
      _Travel  : redirected to Z_C_TRAVEL_2596,
      _Booking : redirected to parent Z_C_BOOK_2596,
      _Product,
      _SupplementText

}
