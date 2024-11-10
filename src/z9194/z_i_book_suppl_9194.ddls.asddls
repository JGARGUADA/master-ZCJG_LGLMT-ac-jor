@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplements - Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_BOOK_SUPPL_9194
  as projection on Z_R_BOOK_SUPPL_9194
{
  key BookSupplUUID,
      TravelUUID,
      BookingUUID,
      BookingSupplementID,
      SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookSupplPrice,
      CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent Z_I_BOOKING_9194,
      _Product,
      _SupplementText,
      _Travel : redirected to Z_I_TRAVEL_9194
}
