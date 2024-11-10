@EndUserText.label: 'Travel - Interface'
@AccessControl.authorizationCheck: #NOT_REQUIRED
//@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_I_TRAVEL_9194
//Como extender la app estándar
provider contract transactional_interface
  as projection on Z_R_TRAVEL_9194
{
  key TravelUUID,
      TravelID,
      AgencyID,
      CustomerID,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Agency,
      //Redireccionamiento al hijo
      _Booking: redirected to composition child Z_I_BOOKING_9194,
      _Currency,
      _Customer,
      _OverallStatus
}
