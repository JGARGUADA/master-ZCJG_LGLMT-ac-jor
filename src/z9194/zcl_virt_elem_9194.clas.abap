CLASS zcl_virt_elem_9194 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces if_sadl_exit_calc_element_read.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_virt_elem_9194 IMPLEMENTATION.
******************************

    method if_sadl_exit_calc_element_read~get_calculation_info.
* F2 para ver documentación
        case iv_entity.
* Cuando la entidad de consumo es z_c_travel_9194
            when 'z_c_travel_9194'.
* Iteramos sobre los elementos de laas columnas de la entidad
                loop at it_requested_calc_elements into data(ls_requested).
* De todos los elementos que tenemos con elementos de tipo string, solo nos interesa PriceWithVat
                if ls_requested = 'PRICEWITHVAT'.
* Añadimos el vlor que necesitamos para el cálculo del TotalPrice ( nombre de la columna )
                    append 'TOTALPRICE' to et_requested_orig_elements.
                endif.
                endloop.
        endcase.
    endmethod.

    method if_sadl_exit_calc_element_read~calculate.


        data lt_original_data type standard table of z_c_travel_9194 with default key.
* Pasamos con autorreferencia de tipo genérico que haga un mapeo
        lt_original_data = corresponding #( it_original_data ).


        loop at lt_original_data assigning field-symbol(<fs_original_data>).
* Determinación de virtualización. El framework garantiza que el dato del IVA se transportará
            <fs_original_data>-PriceWithVAT = <fs_original_data>-TotalPrice * '1.21'.

        endloop.

* Lleva el dato modificado. Se virtualiza el TotalPrice
        ct_calculated_data = corresponding #( lt_original_data ).


    endmethod.

ENDCLASS.


