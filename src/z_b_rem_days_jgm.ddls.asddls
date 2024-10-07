//Asignación del nombre que se va a generar en el catálogo del diccionario de datos
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Remaining days'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
//Indicamos ahora la fuente para obtener los datos y sustituimos data_source_name por la tabla de base de datos
define view entity z_b_rem_days_jgm
  as select from zrent_cars_j
{
  key matricula                                                                 as Matricula,
      marca                                                                     as Marca,
      case
      when alq_hasta is initial
      then dats_days_between( cast ($session.system_date as abap.dats ), alq_hasta) 
      end as Dias
}
