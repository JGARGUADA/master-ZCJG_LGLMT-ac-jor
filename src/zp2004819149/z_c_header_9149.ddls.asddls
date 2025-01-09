@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header - Consumption'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity Z_C_HEADER_9149
  provider contract transactional_query
  as projection on Z_R_HEADER_9149
{
  key HeaderUUID,

      @Search.defaultSearchElement: true
      //Esta anotación permite ir completando por patrones. Es decir si el usuario recuerda que la orden empieza por 100* se irán autobuscando
      @Search.fuzzinessThreshold: 0.8
      //@ObjectModel.text.element: [ 'HeaderID' ]
      HeaderID,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Email' 
      //@ObjectModel.text.element: [ 'Email' ]
      Email,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'First Name'
      //@ObjectModel.text.element: [ 'FirstName' ]
      FirstName,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Last Name'
      //@ObjectModel.text.element: [ 'LastName' ]
      LastName,

      @Search.defaultSearchElement: true
      @EndUserText.label: 'Country'
      //@ObjectModel.text.element: [ 'Country' ]
      Country,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Created On'
      //@ObjectModel.text.element: [ 'CreateOn' ]
      CreateOn,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Delivery Date'
      //@ObjectModel.text.element: [ 'DeliveryDate' ]
      DeliveryDate,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Order Status'
      //@ObjectModel.text.element: [ 'OrderStatus' ]
      OrderStatus,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Imagen URL'
      //@ObjectModel.text.element: [ 'ImageUrl' ]
      ImageUrl,

      LocalLastChangedAt,
      /* Associations */
      _Items : redirected to composition child Z_C_ITEMS_9149 // Así la navegación es del padre al hijo también
      // _Country
}
