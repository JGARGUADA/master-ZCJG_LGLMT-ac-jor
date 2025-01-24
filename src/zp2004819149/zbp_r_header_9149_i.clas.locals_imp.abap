CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


    TYPES:
      ty_header_create               TYPE TABLE FOR CREATE z_r_header_9149\\Header,
      ty_header_update               TYPE TABLE FOR UPDATE z_r_header_9149\\Header,
      ty_header_delete               TYPE TABLE FOR DELETE z_r_header_9149\\Header,
      ty_header_failed               TYPE TABLE FOR FAILED EARLY z_r_header_9149\\Header,
      ty_header_reported             TYPE TABLE FOR REPORTED EARLY z_r_header_9149\\Header,

      ty_header_action_accept_import TYPE TABLE FOR ACTION IMPORT z_r_header_9149\\Header~acceptHeader,
      ty_header_action_accept_result TYPE TABLE FOR ACTION RESULT z_r_header_9149\\Header~acceptHeader.


    CONSTANTS:
      BEGIN OF header_status,
                    open        type i  value '0', "Open
                    accepted    type i  value '1', "Accepted
                    rejected    type i  value '2', "Rejected

      END OF header_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Header RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Header RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Header.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Header.

    METHODS acceptHeader FOR MODIFY
      IMPORTING keys FOR ACTION Header~acceptHeader RESULT result.

    METHODS rejectHeader FOR MODIFY
      IMPORTING keys FOR ACTION Header~rejectHeader RESULT result.

    METHODS Resume FOR MODIFY
      IMPORTING keys FOR ACTION Header~Resume.

*    METHODS validateDates FOR VALIDATE ON SAVE
*      IMPORTING keys FOR Header~validateDates.
    METHODS precheck_auth
      IMPORTING
        entities_create TYPE ty_header_create OPTIONAL
        entities_update TYPE ty_header_update OPTIONAL
      CHANGING
        failed          TYPE ty_header_failed
        reported        TYPE ty_header_reported.

    METHODS setStatusOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Header~setStatusOpen.


    METHODS setHeaderNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Header~setHeaderNumber.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF z_r_header_9149 IN LOCAL MODE
         ENTITY Header
         FIELDS ( OrderStatus )
         WITH CORRESPONDING #( keys )
         RESULT DATA(headers)
         FAILED failed.


* Los siguientes métodos están asociados a acciones que se producen en el listado y a N registros. Los valores asociados a cada acción se almacenan en el registro resultado
    result = VALUE #(  FOR header IN headers
                           (  %tky = header-%tky

                              %action-acceptHeader = COND #( WHEN header-OrderStatus = header_status-accepted
                                                               THEN if_abap_behv=>fc-o-disabled
                                                               ELSE if_abap_behv=>fc-o-enabled )
                              %action-rejectHeader = COND #( WHEN header-OrderStatus = header_status-rejected
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled )
                              %assoc-_Items = COND #( WHEN header-OrderStatus = header_status-rejected
                                                        THEN if_abap_behv=>fc-o-disabled
                                                        ELSE if_abap_behv=>fc-o-enabled )  )  ).



  ENDMETHOD.

  METHOD get_instance_authorizations.

********    DATA: update_requested TYPE abap_bool,
********          delete_requested TYPE abap_bool,
********          update_granted   TYPE abap_bool,
********          delete_granted   TYPE abap_bool.
*********
********    READ ENTITIES OF z_r_header_9149 IN LOCAL MODE
********        ENTITY Header
********        FIELDS ( HeaderID )
********        WITH CORRESPONDING #( keys )
********        RESULT DATA(headers)
********        FAILED failed.
********
********    CHECK headers IS NOT INITIAL.
********
********    "Decide business check
********    DATA(lv_technical_user) = cl_abap_context_info=>get_user_technical_name( ).
********
********    update_requested = COND #( WHEN requested_authorizations-%update       = if_abap_behv=>mk-on
********                                 OR requested_authorizations-%action-Edit   = if_abap_behv=>mk-on
********                               THEN abap_true ELSE abap_false ).
********
********    LOOP AT headers INTO DATA(header).
********
********      IF header-HeaderID IS NOT INITIAL.
********
********        "Business check
*********            if lv_technical_user eq 'CB9980001410'. "WHAT EVER.
********        IF lv_technical_user EQ 'CB9980008018'. "WHAT EVER.
********          update_granted = delete_granted = abap_true.
*********               delete_granted = abap_true.
********        ELSE.
********          update_granted = delete_granted = abap_false.
*********               abap_false.
********        ENDIF.
********
********        "check for update
********        IF update_requested = abap_true.
********          IF update_granted = abap_false.
********            APPEND VALUE #(  %tky = header-%tky
********                                     %msg = new /dmo/cm_flight_messages(
********                                                                textid = 'not_authorized'
********                                                                agency_id = travel-AgencyID
********                                                                severity = if_abap_behv_message=>severity-error )
********                             %element-HeaderID = if_abap_behv=>mk-on
********                             ) TO reported-header.
********
********
********          ENDIF.
********        ENDIF.
********
********        " operations on draft instances and oon active instances
********        "new created instances
********
********      ELSE.
********        update_granted = delete_granted = abap_true. "REPLACE ME WITH BUSINESS CHECK
********        IF update_granted = abap_false.
********          APPEND VALUE #(  %tky = header-%tky
********                           %msg = NEW /dmo/cm_flight_messages(
********                                      textid = /dmo/cm_flight_messages=>not_authorized
********                                      severity = if_abap_behv_message=>severity-error )
********                           %element-HeaderID = if_abap_behv=>mk-on ) TO reported-header.
********
********        ENDIF.
********      ENDIF.
********
********      APPEND VALUE #(
********                        LET upd_auth = COND #(  WHEN update_granted = abap_true
******                                                 THEN if_abap_behv=>auth-allowed
******                                                 ELSE if_abap_behv=>auth-unauthorized )
******                            del_auth = COND #(  WHEN delete_granted = abap_true
******                                                 THEN if_abap_behv=>auth-allowed
******                                                 ELSE if_abap_behv=>auth-unauthorized )
******                        IN
******                            %tky = header-%tky
*****                            %update                 = upd_auth
*****                            %action-Edit            = del_auth
*****
*****                            %delete                 = del_auth
*****                        ) TO result.
*****    ENDLOOP.



  ENDMETHOD.

  METHOD get_global_authorizations.
    DATA(lv_technical_user) = cl_abap_context_info=>get_user_technical_name( ).

    "Simulate NOT authorized
*     <  lv_technical_user = 'DIFFERENET_USER'.

    IF requested_authorizations-%create EQ if_abap_behv=>mk-on OR
*        new
    requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.
      IF lv_technical_user EQ 'CB9980008018'.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-allowed.

        APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages(
                                    textid = /dmo/cm_flight_messages=>not_authorized
                                    severity = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-header.
      ENDIF.

    ENDIF.

    IF requested_authorizations-%update EQ if_abap_behv=>mk-on OR
       requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.

      IF lv_technical_user EQ 'CB9980008018'.
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-Edit = if_abap_behv=>auth-allowed.
      ELSE.
        result-%update = if_abap_behv=>auth-unauthorized.
        result-%action-Edit = if_abap_behv=>auth-unauthorized.
      ENDIF.

    ENDIF.

    IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.
      IF lv_technical_user EQ 'CB9980008018'.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #(  %msg = NEW /dmo/cm_flight_messages(
                                    textid = /dmo/cm_flight_messages=>not_authorized
                                    severity = if_abap_behv_message=>severity-error  )
                         %global = if_abap_behv=>mk-on ) TO reported-header.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD precheck_create.

    me->precheck_auth( EXPORTING entities_create = entities
                    CHANGING  failed          = failed-header
                              reported        = reported-header ).

  ENDMETHOD.

  METHOD precheck_update.
    me->precheck_auth( EXPORTING entities_update = entities
                      CHANGING failed          = failed-header
                               reported        =  reported-header ).
  ENDMETHOD.

  METHOD acceptHeader.

* EML - Entity Manipulation Language

*//modificamos la entidad que aparece en Behavior
    MODIFY ENTITIES OF z_r_header_9149 IN LOCAL MODE
           ENTITY Header
           UPDATE FIELDS ( OrderStatus )
           WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                            OrderStatus = header_status-accepted ) ).
*Leemos los datos de persistencia antes de devolverlos
    READ ENTITIES OF z_r_header_9149 IN LOCAL MODE
         ENTITY Header
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(headers).


    result = VALUE #( FOR header IN headers ( %tky = header-%tky
                                               %param = header ) ).


  ENDMETHOD.

  METHOD rejectHeader.


    MODIFY ENTITIES OF z_r_header_9149 IN LOCAL MODE
            ENTITY Header
            UPDATE FIELDS ( OrderStatus )
            WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                             OrderStatus = header_status-rejected ) ).

    READ ENTITIES OF z_r_header_9149 IN LOCAL MODE
         ENTITY Header
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(headers).

    result = VALUE #( FOR header IN headers ( %tky = header-%tky
                                              %param = header ) ).

  ENDMETHOD.
*************
  METHOD Resume.

    DATA entities_update TYPE ty_header_update.

    READ ENTITIES OF z_r_header_9149 IN LOCAL MODE
         ENTITY header
         FIELDS ( HeaderID )
         WITH VALUE #( FOR key IN keys
                            %is_draft = if_abap_behv=>mk-on
                            ( %key = key-%key ) )
         RESULT DATA(headers).

    " Set %control-AgencyID (if set) to true, so that the precheck_auth checks the permissions.
    entities_update = CORRESPONDING #( headers CHANGING CONTROL ).

    IF entities_update IS NOT INITIAL.
      me->precheck_auth( EXPORTING entities_update = entities_update
                          CHANGING failed          = failed-header
                                    reported       = reported-header  ).

    ENDIF.

  ENDMETHOD.

  METHOD setStatusOpen.

    READ ENTITIES OF z_r_header_9149 IN LOCAL MODE
            ENTITY Header
            FIELDS ( OrderStatus )
            WITH CORRESPONDING #( keys )
            RESULT DATA(headers).

    DELETE headers WHERE OrderStatus IS NOT INITIAL.

    CHECK headers IS NOT INITIAL.

    MODIFY ENTITIES OF z_r_header_9149 IN LOCAL MODE
           ENTITY Header
           UPDATE FIELDS ( OrderStatus )
           WITH VALUE #( FOR header IN headers ( %tky           = header-%tky
                                                 OrderStatus  = header_status-open ) ).

  ENDMETHOD.

*  METHOD validateDates.

*      read entities of z_r_header_9149 in local mode
*         entity Header
*         fields ( CreateOn DeliveryDate HeaderID )
*         with corresponding #( keys )
*         result data(headers).
*
*    loop at headers into data(header).
*        append value #( %tky            = header-%tky
*                        %state_area     = 'VALIDATE_DATES' ) to reported-header.
*
*        if header-CreateOn is initial.
*            append value #(  %tky = header-%tky ) to failed-header.
*
*            append value #( %tky            = header-%tky
*                            %state_area     = 'VALIDATE_DATES'
*                            %msg            = new /dmo/cm_flight_messages(
*                                                                textid      = /dmo/cm_flight_messages=>enter_end_date
*                                                                severity    = if_abap_behv_message=>severity-error )
*                           %element-CreateOn = if_abap_behv=>mk-on ) to reported-header.
*        endif.
*        if header-DeliveryDate is initial.
*      append value #( %tky = header-%tky ) to failed-header.
*
*        append value #( %tky               = header-%tky
*                        %state_area        = 'VALIDATE_DATES'
*                         %msg                = new /dmo/cm_flight_messages(
*                                                                textid   = /dmo/cm_flight_messages=>enter_end_date
*                                                                severity = if_abap_behv_message=>severity-error )
*                        %element-DeliveryDate   = if_abap_behv=>mk-on ) to reported-header.
*        endif.
*    endloop.

*  ENDMETHOD.

  METHOD precheck_auth.

*    data: entities              type ty_header_update,
*          operation             type if_abap_behv=>t_char01,
*          agencies              type sorted table of /dmo/agency with unique key agency_id,
*          modify_granted type abap_bool.
*
*    if entities_create is not initial.
*        entities = corresponding #( entities_create mapping %cid_ref = %cid ).
*        operation = if_abap_behv=>op-m-create.
*    else.
*        entities = entities_update.
*        operation = if_abap_behv=>op-m-update.
*    endif.
*
*    delete entities where %control-HeaderID = if_abap_behv=>mk-off.
*
*    agencies = corresponding #( entities discarding duplicates mapping agency_id = HeaderID except * ).
*
*    check agencies is not initial.
*
*    data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name(  ).
*
*    loop at entities into data(entity).
*        modify_granted = abap_true.
**
**        if lv_technical_user eq 'CB9980001410' and entity-AgencyID ne '70025'. "WHAT EVER
**            modify_granted = abap_true.
**        endif.

*        if modify_granted = abap_false.
*            append value #( %cid       = cond #( when operation = if_abap_behv=>op-m-create
*                                                  then entity-%cid_ref )
*                             %tky       = entity-%tky ) to failed.
*
*            append value #( %cid        = cond #( when operation = if_abap_behv=>op-m-create
*                                                  then entity-%cid_ref )
*                            %tky        = entity-%tky
*                            %msg        = new /dmo/cm_flight_messages(
*                                                        textid      = /dmo/cm_flight_messages=>not_authorized_for_agencyid
*                                                        agency_id   = entity-HeaderID
*                                                        severity    = if_abap_behv_message=>severity-error )
*                            %element-AgencyID   = if_abap_behv=>mk-on ) to reported.
*
*        endif.
*
*    endloop.

  ENDMETHOD.

  METHOD setHeaderNumber.

    READ ENTITIES OF z_r_header_9149 IN LOCAL MODE
         ENTITY Header
         FIELDS ( HeaderID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(headers).

    DELETE headers WHERE HeaderID IS NOT INITIAL.

    CHECK headers IS NOT INITIAL.

    SELECT SINGLE FROM zheader_9149
        FIELDS MAX( header_id )
        INTO @DATA(lv_max_headerid).

    MODIFY ENTITIES OF z_r_header_9149 IN LOCAL MODE
           ENTITY Header
           UPDATE FIELDS ( HeaderID )
           WITH VALUE #( FOR header IN headers INDEX INTO i ( %tky     = header-%tky
                                                              HeaderID = lv_max_headerid + i ) ).

  ENDMETHOD.

ENDCLASS.
