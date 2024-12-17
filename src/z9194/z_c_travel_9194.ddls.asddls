@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel - Consumption'
//@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity Z_C_TRAVEL_9194
provider contract transactional_query
  as projection on Z_R_TRAVEL_9194
{
  key TravelUUID,
  
  
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      TravelID,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Agency_StdVH',
                                                     element: 'AgencyID'},
                                           useForValidation: true }]
      AgencyID,
      _Agency.Name as AgencyName,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer_StdVH',
                                                     element: 'CustomerID'},
                                           useForValidation: true }]
      CustomerID,
      _Customer.LastName as CustomerName,
      
      BeginDate,
      EndDate,
      
      BookingFee,
      TotalPrice,
      @Semantics.amount.currencyCode: 'CurrencyCode'
          @EndUserText.label: 'VAT Included'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_316'
     virtual PriceWithVAT : /dmo/total_price,
      
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                    element:'Currency' },
                                                    useForValidation: true }]
      CurrencyCode,
      Description,
      
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Overall_Status_VH',
                                                     element: 'OverallStatus'} }]
      OverallStatus,
      _OverallStatus._Text.Text as OverallStatusText : localized, // Inyecta el idioma del usuario

      LocalLastChangedAt,

      /* Associations */
      _Agency,
      _Booking : redirected to composition child Z_C_BOOKING_9194, // Así la navegación es del padre al hijo también
      _Currency,
      _Customer,
      _OverallStatus
}
