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
define view entity ZC_LIBROS_9194
  as select from    ztb_libros_9194 as Libros
    inner join      ztb_catego_9194 as Categorias on Libros.bi_categ = Categorias.bi_categ
    left outer join ZC_CLNTSLIB9194 as Ventas     on Libros.id_libro = Ventas.IdLibro
  association [0..*] to ZC_CLIENTE_9194 as _Clientes on $projection.IdLibro = _Clientes.IdLibro
{
  key Libros.id_libro  as IdLibro,
      Libros.titulo    as Titulo,
      Libros.bi_categ  as Categoria,
      Libros.autor     as Autor,
      Libros.editorial as Editorial,
      Libros.idioma    as Idioma,
      Libros.paginas   as Paginas,
      //Se debe tener la referencia entre el importe y su omenda
      @Semantics.amount.currencyCode: 'Moneda'
      Libros.precio    as Precio,
      Libros.moneda    as Moneda,
      case
        when Ventas.Ventas < 1 then 0
        when Ventas.Ventas = 1 then 1
        when Ventas.Ventas = 2 then 2
        when Ventas.Ventas > 2 then 3
      else 0
      end              as Ventas,
      Categorias.descripcion as Descripcion,
      Libros.formato   as Formato,
      Libros.url       as Imagen,
      // se debe publicar el alias _CLiente para que en el futuro se conozca el IdLibro
      _Clientes
}
