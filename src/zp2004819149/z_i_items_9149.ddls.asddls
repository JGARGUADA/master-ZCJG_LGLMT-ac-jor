@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Items - Interface'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_ITEMS_9149
  as projection on Z_R_ITEMS_9149
{
  key ItemsUUID,
      HeaderUUID,
      ItemsID,
      Name,
      Description,
      ReleaseDate,
      DiscontinuedDate,
      Price,
      @Semantics.quantity.unitOfMeasure : 'UnitOfMeasure'
      Height,
      @Semantics.quantity.unitOfMeasure : 'UnitOfMeasure'
      Width,
      Depth,
      Quantity,
      UnitOfMeasure,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      /* Associations */
      _Header : redirected to parent Z_I_HEADER_9149
}
