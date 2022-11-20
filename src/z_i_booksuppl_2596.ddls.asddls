@AbapCatalog.sqlViewName: 'ZV_BSUPPL_2596'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Booking Supplements'
define view Z_I_BOOKSUPPL_2596
  as select from ztb_bookuppl2596 as BookingSupplement
  association        to parent Z_I_BOOK_2596  as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                 and $projection.BookingId = _Booking.BookingId
  association [1..1] to Z_I_TRAVEL_2596       as _Travel         on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement     as _Product        on  $projection.SupplementId = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on  $projection.SupplementId = _SupplementText.SupplementID
{

  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'currency'
      price                 as Price,
      @Semantics.currencyCode: true
      currency              as Currency,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Booking,
      _Travel,
      _Product,
      _SupplementText
}
