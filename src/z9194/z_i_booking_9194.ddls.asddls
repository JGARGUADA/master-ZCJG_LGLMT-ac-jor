@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking - Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_BOOKING_9194
  as projection on Z_R_BOOKING_9194
{
  key BookingUUID,
      TravelUUID,
      BookingID,
      BookingDate,
      CustomerID,
      AirlineID,
      ConnectionID,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSupplement : redirected to composition child Z_I_BOOK_SUPPL_9194,
      _Carrier,
      _Connection,
      _Customer,
      //Redireccionamiento al padre
      _Travel            : redirected to parent Z_I_TRAVEL_9194
}
