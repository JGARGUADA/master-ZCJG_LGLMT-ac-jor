@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Items - Root'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_R_ITEMS_9149
  as select from zitems_9149
  association to parent Z_R_HEADER_9149 as _Header on $projection.HeaderUUID = _Header.HeaderUUID
  //composition of target_data_source_name as _association_name
{
  key items_uuid            as ItemsUUID,
      parent_uuid           as HeaderUUID,
      items_id              as ItemsID,
      name                  as Name,
      description           as Description,
      release_date          as ReleaseDate,
      discontinued_date     as DiscontinuedDate,
      price                 as Price,
      @Semantics.quantity.unitOfMeasure : 'UnitOfMeasure'
      height                as Height,
      @Semantics.quantity.unitOfMeasure : 'UnitOfMeasure'
      width                 as Width,
      @Semantics.quantity.unitOfMeasure : 'UnitOfMeasure'
      depth                 as Depth,
      quantity              as Quantity,
      unit_of_measure       as UnitOfMeasure,
      //Etag - local OData
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      _Header
      //  _association_name // Make association public
}
