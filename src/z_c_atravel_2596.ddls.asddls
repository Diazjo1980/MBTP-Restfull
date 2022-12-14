@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Travels Approvals'
@Metadata.allowExtensions: true
define root view entity Z_C_ATRAVEL_2596
  as projection on Z_I_TRAVEL_2596
{

  key TravelId,
      @ObjectModel.text.element: ['AgencyName']
       AgencyId,
      _Agency.Name       as AgencyName,
      @ObjectModel.text.element: ['CustomerName']
      CustomerId,
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Semantics.currencyCode: true
      CurrencyCode,
      Description,
      TravelStatus,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child Z_C_ABOOK_2596,
      _Agency,
      _Customer
}
