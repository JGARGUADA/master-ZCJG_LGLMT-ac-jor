@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header - Root'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_R_HEADER_9149
  as select from zheader_9149
  composition [0..*] of Z_R_ITEMS_9149 as _Items
  // association [1..1] to I_Country as _Country on $projection.Country = _Country.Country
  //composition of target_data_source_name as _association_name
{
      key header_uuid       as HeaderUUID,
      header_id             as HeaderID,
      email                 as Email,
      first_name            as FirstName,
      last_name             as LastName,
      country               as Country,
      create_on             as CreateOn,
      delivery_date         as DeliveryDate,
      order_status          as OrderStatus,
      image_url             as ImageUrl,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      //Etag - local
      @Semantics.systemDateTime.localInstanceLastChangedAt : true
      local_last_changed_at as LocalLastChangedAt,
      //Etag - global
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Items
      // _Country
      //   _association_name // Make association public
}
