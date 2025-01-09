CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


  types:
            ty_header_create            type table for create z_r_header_9149\\Header,
            ty_header_update            type table for update z_r_header_9149\\Header,
            ty_header_delete            type table for delete z_r_header_9149\\Header,
            ty_header_failed            type table for failed early z_r_header_9149\\Header,
            ty_header_reported          type table for reported early z_r_header_9149\\Header,

            ty_header_action_accept_import type table for action import z_r_header_9149\\Header~acceptHeader,
            ty_header_action_accept_result type table for action result z_r_header_9149\\Header~acceptHeader.


            constants:
                begin of header_status,
                    open        type i  value '0', "Open
                    accepted    type i  value '1', "Accepted
                    rejected    type i  value '2', "Rejected
                end of header_status.

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

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Header~validateDates.
    METHODS precheck_auth
        importing
            entities_create type ty_header_create optional
            entities_update type ty_header_update optional
        changing
            failed          type ty_header_failed
            reported        type ty_header_reported.

        METHODS setStatusOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Header~setStatusOpen.


    METHODS setHeaderNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Header~setHeaderNumber.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_features.
*   read entities of z_r_header_9149 in local mode
*        entity Header
*        fields ( OrderStatus )
*        with corresponding #( keys )
*        result data(headers)
*        failed failed.
*
*
** Los siguientes métodos están asociados a acciones que se producen en el listado y a N registros. Los valores asociados a cada acción se almacenan en el registro resultado
*    result = value #(  for header in headers
*                           (  %tky = header-%tky
*
*                              %action-acceptHeader = cond #( when header-OrderStatus = header_status-accepted
*                                                               then if_abap_behv=>fc-o-disabled
*                                                               else if_abap_behv=>fc-o-enabled )
*                              %action-rejectHeader = cond #( when header-OrderStatus = header_status-rejected
*                                                             then if_abap_behv=>fc-o-disabled
*                                                             else if_abap_behv=>fc-o-enabled )
*                              %assoc-_Items = cond #( when header-OrderStatus = header_status-rejected
*                                                        then if_abap_behv=>fc-o-disabled
*                                                        else if_abap_behv=>fc-o-enabled )  )  ).



  ENDMETHOD.

  METHOD get_instance_authorizations.

*      data: update_requested type abap_bool,
*          delete_requested type abap_bool,
*          update_granted   type abap_bool,
*          delete_granted   type abap_bool.
*
*    read entities of z_r_header_9149 in local mode
*        entity Header
*        fields ( HeaderID )
*        with corresponding #( keys )
*        result data(headers)
*        failed failed.
*
*    check headers is not initial.
*
*    "Decide business check
*    data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name( ).
*
*    update_requested = cond #( when requested_authorizations-%update       = if_abap_behv=>mk-on
*                                 or requested_authorizations-%action-Edit   = if_abap_behv=>mk-on
*                               then abap_true else abap_false ).
*
*    loop at headers into data(header).
*
*        if header-HeaderID is not initial.
*
*            "Business check
**            if lv_technical_user eq 'CB9980001410'. "WHAT EVER.
*            if lv_technical_user eq 'CB9980008018'. "WHAT EVER.
*                update_granted = delete_granted = abap_true.
**               delete_granted = abap_true.
*            else.
*                update_granted = delete_granted = abap_false.
**               abap_false.
*            endif.
*
*            "check for update
*            if update_requested = abap_true.
*                if update_granted = abap_false.
*                    append value #(  %tky = header-%tky
***                                     %msg = new /dmo/cm_flight_messages(
***                                                                textid = 'not_authorized'
***                                                                agency_id = travel-AgencyID
***                                                                severity = if_abap_behv_message=>severity-error )
*                                     %element-HeaderID = if_abap_behv=>mk-on
*                                     ) to reported-header.
*
*
*                endif.
*            endif.
*
*  " operations on draft instances and oon active instances
*  "new created instances
*
*  else.
*    update_granted = delete_granted = abap_true. "REPLACE ME WITH BUSINESS CHECK
*    if update_granted = abap_false.
*        append value #(  %tky = header-%tky
*                         %msg = new /dmo/cm_flight_messages(
*                                    textid = /dmo/cm_flight_messages=>not_authorized
*                                    severity = if_abap_behv_message=>severity-error )
*                         %element-HeaderID = if_abap_behv=>mk-on ) to reported-header.
*
*  endif.
*  endif.
*
*  append value #(
*                    let upd_auth = cond #(  when update_granted = abap_true
*                                             then if_abap_behv=>auth-allowed
*                                             else if_abap_behv=>auth-unauthorized )
*                        del_auth = cond #(  when delete_granted = abap_true
*                                             then if_abap_behv=>auth-allowed
*                                             else if_abap_behv=>auth-unauthorized )
*                    in
*                        %tky = header-%tky
*                        %update                 = upd_auth
*                        %action-Edit            = del_auth
*
*                        %delete                 = del_auth
*                    ) to result.
*  endloop.



  ENDMETHOD.

  METHOD get_global_authorizations.
*       data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name( ).
*
*        "Simulate NOT authorized
**       lv_technical_user = 'DIFFERENET_USER'.
*
*        if requested_authorizations-%create eq if_abap_behv=>mk-on.
*           if lv_technical_user eq 'CB9980008018'.
*                result-%create = if_abap_behv=>auth-allowed.
*           else.
*                result-%create = if_abap_behv=>auth-allowed.
*
*                append value #( %msg = new /dmo/cm_flight_messages(
*                                            textid = /dmo/cm_flight_messages=>not_authorized
*                                            severity = if_abap_behv_message=>severity-error )
*                                %global = if_abap_behv=>mk-on ) to reported-header.
*            endif.
*
*        endif.
*
*        if requested_authorizations-%update eq if_abap_behv=>mk-on or
*           requested_authorizations-%action-Edit eq if_abap_behv=>mk-on.
*
*           if lv_technical_user eq 'CB9980008018'.
*            result-%update = if_abap_behv=>auth-allowed.
*            result-%action-Edit = if_abap_behv=>auth-allowed.
*           else.
*            result-%update = if_abap_behv=>auth-unauthorized.
*            result-%action-Edit = if_abap_behv=>auth-unauthorized.
*           endif.
*
*        endif.
*
*        if requested_authorizations-%delete eq if_abap_behv=>mk-on.
*            if lv_technical_user eq 'CB9980008018'.
*                result-%delete = if_abap_behv=>auth-allowed.
*            else.
*                result-%delete = if_abap_behv=>auth-unauthorized.
*
*                append value #(  %msg = new /dmo/cm_flight_messages(
*                                            textid = /dmo/cm_flight_messages=>not_authorized
*                                            severity = if_abap_behv_message=>severity-error  )
*                                 %global = if_abap_behv=>mk-on ) to reported-header.
*
*            endif.
*
*        endif.

  ENDMETHOD.

  METHOD precheck_create.

*       me->precheck_auth( exporting entities_create = entities
*                       changing  failed          = failed-header
*                                 reported        = reported-header ).
*
  ENDMETHOD.

  METHOD precheck_update.
*      me->precheck_auth( exporting entities_update = entities
*                        changing failed          = failed-header
*                                 reported        =  reported-header ).
  ENDMETHOD.

  METHOD acceptHeader.

* EML - Entity Manipulation Language

*//modificamos la entidad que aparece en Behavior
    modify entities of z_r_header_9149 in local mode
           entity Header
           update fields ( OrderStatus )
           with value #( for key in keys ( %tky = key-%tky
                                            OrderStatus = header_status-accepted ) ).
*Leemos los datos de persistencia antes de devolverlos
   read entities of z_r_header_9149 in local mode
        entity Header
        all fields
        with corresponding #( keys )
        result data(headers).


   result = value #( for header in headers ( %tky = header-%tky
                                              %param = header ) ).


  ENDMETHOD.

  METHOD rejectHeader.


    modify entities of z_r_header_9149 in local mode
            entity Header
            update fields ( OrderStatus )
            with value #( for key in keys ( %tky = key-%tky
                                             OrderStatus = header_status-rejected ) ).

    read entities of z_r_header_9149 in local mode
         entity Header
         all fields
         with corresponding #( keys )
         result data(headers).

    result = value #( for header in headers ( %tky = header-%tky
                                              %param = header ) ).

  ENDMETHOD.

  METHOD Resume.

*    data entities_update type ty_header_update.
*
*    read entities of z_r_header_9149 in local mode
*         entity header
*         fields ( HeaderID )
*         with value #( for key in keys
*                            %is_draft = if_abap_behv=>mk-on
*                            ( %key = key-%key ) )
*         result data(headers).
*
*    " Set %control-AgencyID (if set) to true, so that the precheck_auth checks the permissions.
*    entities_update = corresponding #( headers changing control ).
*
*    if entities_update is not initial.
*        me->precheck_auth( exporting entities_update = entities_update
*                            changing failed          = failed-header
*                                      reported       = reported-header  ).
*
*    endif.

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

  METHOD validateDates.

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

  ENDMETHOD.

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
*
*        if lv_technical_user eq 'CB9980001410' and entity-AgencyID ne '70025'. "WHAT EVER
*            modify_granted = abap_true.
*        endif.
*
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
*                                                        agency_id   = entity-AgencyID
*                                                        severity    = if_abap_behv_message=>severity-error )
*                            %element-AgencyID   = if_abap_behv=>mk-on ) to reported.
*
*        endif.
*
*    endloop.

ENDMETHOD.

 METHOD setHeaderNumber.

    read entities of z_r_header_9149 in local mode
         entity Header
         fields ( HeaderID )
         with corresponding #( keys )
         result data(headers).

    delete headers where HeaderID is not initial.

    check headers is not initial.

    select single from zheader_9149
        fields max( header_id )
        into @data(lv_max_headerid).

    modify entities of z_r_header_9149 in local mode
           entity Header
           update fields ( HeaderID )
           with value #( for header in headers index into i ( %tky     = header-%tky
                                                              HeaderID = lv_max_headerid + i ) ).

  ENDMETHOD.

ENDCLASS.
