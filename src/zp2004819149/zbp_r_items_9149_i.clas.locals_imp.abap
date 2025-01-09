CLASS lhc_Items DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setItemNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Items~setItemNumber.

ENDCLASS.

CLASS lhc_Items IMPLEMENTATION.

  METHOD setItemNumber.

    DATA max_itemid TYPE c LENGTH 36.
    DATA item_update TYPE TABLE FOR UPDATE z_r_header_9149\\Items.

    READ ENTITIES OF z_r_header_9149 IN LOCAL MODE
         ENTITY Items BY \_Header
         FIELDS ( HeaderUUID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(headers).

    LOOP AT headers INTO DATA(header).

      READ ENTITIES OF z_r_header_9149 IN LOCAL MODE
           ENTITY Header BY \_Items
           FIELDS ( ItemsID )
           WITH VALUE #( ( %tky = header-%tky ) )
           RESULT DATA(items).

      max_itemid = '0000'.

      LOOP AT items INTO DATA(item).
        IF item-ItemsID > max_itemid.
          max_itemid = item-ItemsID.
        ENDIF.
      ENDLOOP.

      LOOP AT items INTO item WHERE ItemsID IS INITIAL.
        max_itemid += 10.
        APPEND VALUE #( %tky      = item-%tky
                        ItemsID = max_itemid )  TO item_update.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF z_r_header_9149 IN LOCAL MODE
           ENTITY Items
           UPDATE FIELDS ( ItemsID )
           WITH item_update.

  ENDMETHOD.

ENDCLASS.
