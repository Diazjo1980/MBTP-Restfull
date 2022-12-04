@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Travels'
@Metadata.allowExtensions: true
define root view entity Z_C_TRAVEL_2596
  as projection on Z_I_TRAVEL_2596
{

  key     TravelId,
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
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRTUAL_ELEMENT_2596'
  virtual discountPrice : /dmo/total_price,
          /* Associations */
          _Agency,
          _Booking : redirected to composition child Z_C_BOOK_2596,
          _Currency,
          _Customer

}
