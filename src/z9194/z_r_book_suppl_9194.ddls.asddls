@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement - Root'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_R_BOOK_SUPPL_9194
  as select from ztb_booksup_9194
//Este CDS indicará que se relaciona con el padre
association to parent Z_R_BOOKING_9194 as _Booking on $projection.BookingUUID =  _Booking.BookingUUID
association [1..1] to Z_R_TRAVEL_9194 as _Travel on $projection.TravelUUID = _Travel.TravelUUID

association [1..1] to /DMO/I_Supplement as _Product on $projection.SupplementID = _Product.SupplementID
association [1..*] to /DMO/I_SupplementText as _SupplementText on $projection.SupplementID = _SupplementText.SupplementID

{
  key booksuppl_uuid        as BookSupplUUID,
      root_uuid             as TravelUUID,
      parent_uuid           as BookingUUID,
      booking_supplement_id as BookingSupplementID,
      supplement_id         as SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as BookSupplPrice,
      currency_code         as CurrencyCode,
      //eTag para el oData
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      _Booking,
      _Travel,
      _Product,
      _SupplementText
}
