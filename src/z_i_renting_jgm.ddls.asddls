@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Renting'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity z_i_renting_jgm
  as select from z_b_cars_jgm as Cars
  association [1]    to z_b_rem_days_jgm as _RemDays     on Cars.Matricula = _RemDays.Matricula
  association [0..*] to z_b_brands_jgm   as _Brands      on Cars.Marca = _Brands.Marca
  association [0..*] to Z_B_DET_CUSTOMER as _DetCustomer on Cars.Matricula = _DetCustomer.Matricula
{
      //z_b_cars_jgm
  key Matricula,
      Marca,
      Modelo,
      Color,
      Motor,
      Potencia,
      Unidad,
      Combustible,
      Consumo,
      FechaFabricacion,
      Puertas,
      Precio,
      Moneda,
      Alquilado,
      Desde,
      Hasta,
      
//      0 neutral grey
//      1 negative red
//      2 critical yellow
//      3 positive green   
      
      
      case
      when _RemDays.Dias <= 0 then 0
      when _RemDays.Dias between 1 and 30 then 1
      when _RemDays.Dias between 31 and 100 then 2
      when _RemDays.Dias > 100 then 3
      else 0
      end as TiempoRenta,
   /*         case
      when _RemDays.Dias <= 0 then 'New'
      when _RemDays.Dias between 1 and 30 then 'Error'
      when _RemDays.Dias between 31 and 100 then 'In progress'
      when _RemDays.Dias > 100 then 'Delivered'
      else 'New'
      end as Estado,*/
// nos quedamos con Estado ya que será una columna dummy a utilizar en la lógica en determianr los valores en base a otra columna
      '' as Estado,
      _Brands.Imagen,
      _DetCustomer
}
