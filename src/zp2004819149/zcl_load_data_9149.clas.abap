CLASS zcl_load_data_9149 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_load_data_9149 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
**Añadimos el código del script para poder insertar datos en tablas de base de datos

    DATA: lt_header TYPE TABLE OF zheader_9149,
          lt_items  TYPE TABLE OF zitems_9149.



********* ZHEADER_9149 ********
    "fill internal table
    lt_header = VALUE #(
    ( header_uuid = '462847ff-2e62-4cd0-af78-77eb5894bba3' header_id = '1000' email = 'STEPHANIE.ROBERTS@EMAIL.COM' first_name = 'Andrew' last_name = 'Roberts' country = 'Spain' create_on = '20250101' delivery_date = '20250301' order_status = '1'
     image_url = 'https://www.behance.net/gallery/29632909/Random-Logo-1' )
     ( header_uuid = '6ef9ee83-5dec-41cc-b683-1b0680be2c9a' header_id = '2000' email = 'GEORGE.SMITHS@EMAIL.COM' first_name = 'George' last_name = 'Smith' country = 'United Kingdom' create_on = '20250202' delivery_date = '20250415' order_status = '1'
     image_url = 'https://www.deviantart.com/kaitokid7/art/RANDOM-COMPANY-LOGO-1-636250627' )


      ).



    "Delete possible entries; insert new entries
    DELETE FROM zheader_9149.
*    INSERT zheader_9149 FROM TABLE @lt_header.

    IF sy-subrc EQ 0.
      out->write( |Header Sales Orders: { sy-dbcnt } entries inserted| ).
    ENDIF.

********* ZITEMS_9149  ********
    "fill internal table
    lt_items = VALUE #(
    ( items_uuid = '38d94a1d-8daf-4ec1-9d4b-b9e36db2f1fa ' parent_uuid = '462847ff-2e62-4cd0-af78-77eb5894bba3' items_id = '10' name = 'cloth' description = 'purple rough cloth' release_date = '20250301' discontinued_date = '20250601'
      price = '12.5' height = '25.5' width = '100' depth = '20' quantity = '2' unit_of_measure = 'CM' )
    ( items_uuid = '5ba00231-55a6-48b3-a2fe-00d04fbe5846' parent_uuid = '462847ff-2e62-4cd0-af78-77eb5894bba3' items_id = '20' name = 'car' description = 'minivan' release_date = '20250622' discontinued_date = '20260601'
      price = '1200.54' height = '1000' width = '500' depth = '200' quantity = '1' unit_of_measure = 'CM' )
    ( items_uuid = '234a82b3-73c1-4c1d-a61e-1cdf1550f268' parent_uuid = '6ef9ee83-5dec-41cc-b683-1b0680be2c9a' items_id = '20' name = 'site' description = 'individual site' release_date = '20250622' discontinued_date = '20260725'
      price = '300' height = '50' width = '20' depth = '10' quantity = '3' unit_of_measure = 'CM' )
       ).


    "Delete possible entries; insert new entries
**    DELETE FROM zitems_9149.
    INSERT zitems_9149 FROM TABLE @lt_items.

    IF sy-subrc EQ 0.
      out->write( |Items Sales Orders: { sy-dbcnt } entries inserted| ).
    ENDIF.



    "Check result in console
    out->write( 'DONE!' ).

  ENDMETHOD.
ENDCLASS.
