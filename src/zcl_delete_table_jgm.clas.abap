CLASS zcl_delete_table_jgm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_delete_table_jgm IMPLEMENTATION.
    METHOD if_oo_adt_classrun~main.
        DELETE FROM zrent_brands_j.

        IF sy-subrc eq 0.
            out->WRITE(  'All data deleted' ).
        ENDIF.
    ENDMETHOD.
ENDCLASS.
