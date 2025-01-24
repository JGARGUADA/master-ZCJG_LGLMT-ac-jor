@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Items - Consumption'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity Z_C_ITEMS_9149
  as projection on Z_R_ITEMS_9149
{
  key ItemsUUID,
      HeaderUUID,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @EndUserText.label: 'Item'
     // @ObjectModel.text.element: [ 'ItemsID' ]
      ItemsID,

      @Search.defaultSearchElement: true
      @EndUserText.label: 'Name'
      //@ObjectModel.text.element: [ 'Name' ]
      Name,

      @Search.defaultSearchElement: true
      @EndUserText.label: 'Description'
      //@ObjectModel.text.element: [ 'Description' ]
      Description,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Release Date'
      //@ObjectModel.text.element: [ 'ReleaseDate' ]
      ReleaseDate,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Discontinued Date'
      //@ObjectModel.text.element: [ 'DiscontinuedDate' ]
      DiscontinuedDate,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Price'
      //@ObjectModel.text.element: [ 'Price' ]
      Price,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Height'

      //@ObjectModel.text.element: [ 'Height' ]
      Height,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Width'
      //@ObjectModel.text.element: [ 'Width' ]
      Width,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Depth'
      //@ObjectModel.text.element: [ 'Depth' ]
      Depth,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Quantity'
      //@ObjectModel.text.element: [ 'Quantity' ]
      Quantity,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Unit of Measure'
      //@ObjectModel.text.element: [ 'UnitOfMeasure' ]
      UnitOfMeasure,
      
      
      LocalLastChangedAt,
      /* Associations */
      _Header : redirected to parent Z_C_HEADER_9149 // sin esta sentencia no sabría navegar al padre
}
