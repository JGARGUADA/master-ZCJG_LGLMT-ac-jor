@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header - Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_I_HEADER_9149 
provider contract transactional_interface
as projection on Z_R_HEADER_9149
{
    key HeaderUUID,
    HeaderID,
    Email,
    FirstName,
    LastName,
    Country,
    CreateOn,
    DeliveryDate,
    OrderStatus,
    ImageUrl,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Items: redirected to composition child Z_I_ITEMS_9149
   // _Country
}
