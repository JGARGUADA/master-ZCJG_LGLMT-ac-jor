@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplements - Consumption'
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity Z_C_BOOK_SUPPL_9194
  as projection on Z_R_BOOK_SUPPL_9194
{
  key BookSupplUUID,
      TravelUUID,
      BookingUUID,
      
      @Search.defaultSearchElement: true
      BookingSupplementID,

      
      @ObjectModel.text.element: [ 'SupplementDescription' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Supplement_StdVH',
                                                   element: 'SupplementID'},
                                                   additionalBinding: [{ localElement: 'BookSupplPrice',
                                                                          element: 'Price',
                                                                          usage: #RESULT },
                                                                           { localElement: 'CurrencyCode',
                                                                          element: 'CurrencyCode',
                                                                          usage: #RESULT }],
                                         useForValidation: true }]
      
      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,
      BookSupplPrice,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                     element: 'Currency' },
                                                     useForValidation: true }]
      CurrencyCode,
      
      LocalLastChangedAt,
      
      
      
      /* Associations */
      _Booking : redirected to parent Z_C_BOOKING_9194,
      _Product,
      _SupplementText,
      _Travel : redirected to Z_C_TRAVEL_9194
}
