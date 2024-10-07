@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Libros'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZC_CLIENTE_9194
  as select from ztb_cliente_9194 as Clientes
  //para obtener datos de la tabla clientes/libros y como se unen. Tenemos dos fuentes con alias
    inner join   ztb_clntslib9194 as ClientesLibros on ClientesLibros.id_cliente = Clientes.id_cliente
{
  key ClientesLibros.id_libro as IdLibro,
  key Clientes.id_cliente     as IdCliente,
  key Clientes.tipo_acceso    as Acceso,
      Clientes.nombre         as Nombre,
      Clientes.apellidos      as Apellidos,
      Clientes.email          as Email,
      Clientes.url            as Imagen
}
