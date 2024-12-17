CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    types:
            ty_travel_create            type table for create z_r_travel_9194\\Travel,
            ty_travel_update            type table for update z_r_travel_9194\\Travel,
            ty_travel_delete            type table for delete z_r_travel_9194\\Travel,
            ty_travel_failed            type table for failed early z_r_travel_9194\\Travel,
            ty_travel_reported          type table for reported early z_r_travel_9194\\Travel,

            ty_travel_action_accept_import type table for action import z_r_travel_9194\\Travel~acceptTravel,
            ty_travel_action_accept_result type table for action result z_r_travel_9194\\Travel~acceptTravel.

            constants:
                begin of travel_status,
                    open        type c length 1 value '0', "Open
                    accepted    type c length 1 value 'A', "Accepted
                    rejected    type c length 1 value 'X', "Rejected
                end of travel_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Travel.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductDiscount RESULT result.

    METHODS reCalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~reCalcTotalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS Resume FOR MODIFY
      IMPORTING keys FOR ACTION Travel~Resume.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setStatusOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusOpen.

    METHODS setTravelNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelNumber.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateCurrencyCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCurrencyCode.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS precheck_auth
        importing
            entities_create type ty_travel_create optional
            entities_update type ty_travel_update optional
        changing
            failed          type ty_travel_failed
            reported        type ty_travel_reported.

    METHODS createTravelByTemplate FOR MODIFY IMPORTING keys FOR
    ACTION Travel~createTravelByTemplate RESULT result.



ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
    read entities of z_r_travel_9194 in local mode
        entity Travel
        fields ( OverallStatus )
        with corresponding #( keys )
        result data(travels)
        failed failed.


* Los siguientes métodos están asociados a acciones que se producen en el listado y a N registros. Los valores asociados a cada acción se almacenan en el registro resultado
    result = value #(  for travel in travels
                           (  %tky = travel-%tky
                              %field-BookingFee = cond #( when travel-OverallStatus = travel_status-accepted
                                                          then if_abap_behv=>fc-f-read_only
                                                          else if_abap_behv=>fc-f-unrestricted )
                              %action-acceptTravel = cond #( when travel-OverallStatus = travel_status-accepted
                                                               then if_abap_behv=>fc-o-disabled
                                                               else if_abap_behv=>fc-o-enabled )
                              %action-rejectTravel = cond #( when travel-OverallStatus = travel_status-rejected
                                                             then if_abap_behv=>fc-o-disabled
                                                             else if_abap_behv=>fc-o-enabled )
                              %action-deductDiscount = cond #( when travel-OverallStatus = travel_status-accepted
                                                               then if_abap_behv=>fc-o-disabled
                                                               else if_abap_behv=>fc-o-enabled )
                              %assoc-_Booking = cond #( when travel-OverallStatus = travel_status-rejected
                                                        then if_abap_behv=>fc-o-disabled
                                                        else if_abap_behv=>fc-o-enabled )  )  ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    data: update_requested type abap_bool,
          delete_requested type abap_bool,
          update_granted   type abap_bool,
          delete_granted   type abap_bool.

    read entities of z_r_travel_9194 in local mode
        entity Travel
        fields ( AgencyID )
        with corresponding #( keys )
        result data(travels)
        failed failed.

    check travels is not initial.

    "Decide business check
    data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name( ).

    update_requested = cond #( when requested_authorizations-%update       = if_abap_behv=>mk-on
                                 or requested_authorizations-%action-Edit   = if_abap_behv=>mk-on
                               then abap_true else abap_false ).

    loop at travels into data(travel).

        if travel-AgencyID is not initial.

            "Business check
            if lv_technical_user eq 'CB9980001410' and travel-AgencyID ne '70021'. "WHAT EVER.
                update_granted = delete_granted = abap_true.
*               delete_granted = abap_true.
            else.
                update_granted = delete_granted = abap_false.
*               abap_false.
            endif.

            "check for update
            if update_requested = abap_true.
                if update_granted = abap_false.
                    append value #(  %tky = travel-%tky
                                     %msg = new /dmo/cm_flight_messages(
                                                                textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                                agency_id = travel-AgencyID
                                                                severity = if_abap_behv_message=>severity-error )
                                     %element-AgencyID = if_abap_behv=>mk-on
                                     ) to reported-travel.


                endif.
            endif.

  " operations on draft instances and oon active instances
  "new created instances

  else.
    update_granted = delete_granted = abap_true. "REPLACE ME WITH BUSINESS CHECK
    if update_granted = abap_false.
        append value #(  %tky = travel-%tky
                         %msg = new /dmo/cm_flight_messages(
                                    textid = /dmo/cm_flight_messages=>not_authorized
                                    severity = if_abap_behv_message=>severity-error )
                         %element-AgencyID = if_abap_behv=>mk-on ) to reported-travel.

  endif.
  endif.

  append value #(
                    let upd_auth = cond #(  when update_granted = abap_true
                                             then if_abap_behv=>auth-allowed
                                             else if_abap_behv=>auth-unauthorized )
                        del_auth = cond #(  when delete_granted = abap_true
                                             then if_abap_behv=>auth-allowed
                                             else if_abap_behv=>auth-unauthorized )
                    in
                        %tky = travel-%tky
                        %update                 = upd_auth
                        %action-Edit            = del_auth

                        %delete                 = del_auth
                    ) to result.
  endloop.
  ENDMETHOD.

  METHOD get_global_authorizations.

        data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name( ).

        "Simulate NOT authorized
*       lv_technical_user = 'DIFFERENET_USER'.

        if requested_authorizations-%create eq if_abap_behv=>mk-on.
            if lv_technical_user eq 'CB9980001410'.
                result-%create = if_abap_behv=>auth-allowed.
            else.
                result-%create = if_abap_behv=>auth-allowed.

                append value #( %msg = new /dmo/cm_flight_messages(
                                            textid = /dmo/cm_flight_messages=>not_authorized
                                            severity = if_abap_behv_message=>severity-error )
                                %global = if_abap_behv=>mk-on ) to reported-travel.
            endif.

        endif.

        if requested_authorizations-%update eq if_abap_behv=>mk-on or
           requested_authorizations-%action-Edit eq if_abap_behv=>mk-on.

           if lv_technical_user eq 'CB9980001410'.
            result-%update = if_abap_behv=>auth-allowed.
            result-%action-Edit = if_abap_behv=>auth-allowed.
           else.
            result-%update = if_abap_behv=>auth-unauthorized.
            result-%action-Edit = if_abap_behv=>auth-unauthorized.
           endif.

        endif.

        if requested_authorizations-%delete eq if_abap_behv=>mk-on.
            if lv_technical_user eq 'CB9980001410'.
                result-%delete = if_abap_behv=>auth-allowed.
            else.
                result-%delete = if_abap_behv=>auth-unauthorized.

                append value #(  %msg = new /dmo/cm_flight_messages(
                                            textid = /dmo/cm_flight_messages=>not_authorized
                                            severity = if_abap_behv_message=>severity-error  )
                                 %global = if_abap_behv=>mk-on ) to reported-travel.

            endif.

        endif.

  ENDMETHOD.


  METHOD precheck_create.

     me->precheck_auth( exporting entities_create = entities
                       changing  failed          = failed-travel
                                 reported        = reported-travel ).

  ENDMETHOD.

  METHOD precheck_update.

    me->precheck_auth( exporting entities_update = entities
                        changing failed          = failed-travel
                                 reported        =  reported-travel ).

  ENDMETHOD.

  METHOD acceptTravel.

* EML - Entity Manipulation Language
* keys[ 1 ]-%tky-TravelUUID

    modify entities of z_r_travel_9194 in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for key in keys ( %tky = key-%tky
                                            OverallStatus = travel_status-accepted ) ).

   read entities of z_r_travel_9194 in local mode
        entity Travel
        all fields
        with corresponding #( keys )
        result data(travels).

   result = value #( for travel in travels ( %tky = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

  METHOD deductDiscount.

    data travels_for_update type table for update z_r_travel_9194.
    data(keys_with_valid_discount) = keys.

    loop at keys_with_valid_discount assigning field-symbol(<key_discount>)
        where %param-discount_percent is initial
        or %param-discount_percent > 100
        or %param-discount_percent <= 0.

    append value #( %tky = <key_discount>-%tky ) to failed-travel.

    append value #( %tky = <key_discount>-%tky
                    %msg = new /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>discount_invalid
                                                           severity = if_abap_behv_message=>severity-error )
                    %element-bookingfee = if_abap_behv=>mk-on
                    %action-deductDiscount = if_abap_behv=>mk-on ) to reported-travel.

    delete keys_with_valid_discount.


    endloop.

    check keys_with_valid_discount is not initial.

    read entities of z_r_travel_9194 in local mode
         entity Travel
         fields ( BookingFee )
         with corresponding #( keys_with_valid_discount )
         result data(travels).

    data percentage type decfloat16.

    loop at travels assigning field-symbol(<travel>).
        data(discount_percent) = keys_with_valid_discount[ key id %tky = <travel>-%tky ]-%param-discount_percent.

        percentage = discount_percent / 100.
        data(reduce_fee) = <travel>-BookingFee * ( 1 - percentage ).

        append value #( %tky        = <travel>-%tky
                        BookingFee = reduce_fee ) to travels_for_update.

    endloop.

    modify entities of z_r_travel_9194 in local mode
            entity Travel
            update fields ( BookingFee )
            with travels_for_update.

    read entities of z_r_travel_9194 in local mode
         entity Travel
         all fields
         with corresponding #( travels )
         result data(travels_with_discount).

    result = value #( for travel in travels_with_discount ( %tky   = travel-%tky
                                                             %param = travel ) ).

  ENDMETHOD.

  METHOD reCalcTotalPrice.

    types: begin of ty_amount_per_currencycode,
            amount      type /dmo/total_price,
            currency_code type /dmo/currency_code,
           end of ty_amount_per_currencycode.

   data: amount_per_currencycode type standard table of ty_amount_per_currencycode.

   read entities of z_r_travel_9194 in local mode
        entity Travel
        fields ( BookingFee CurrencyCode )
        with corresponding #( keys )
        result data(travels).

   delete travels where CurrencyCode is initial.

   loop at travels assigning field-symbol(<travel>).
    amount_per_currencycode = value #( ( amount        = <travel>-BookingFee
                                         currency_code = <travel>-CurrencyCode ) ).

    " Read Bookings
    read entities of z_r_travel_9194 in local mode
        entity Travel by \_Booking
            fields ( FlightPrice CurrencyCode )
        with value #( (  %tky = <travel>-%tky ) )
        result data(bookings).


    loop at bookings into data(booking) where CurrencyCode is not initial.
        collect value ty_amount_per_currencycode( amount        = booking-FlightPrice
                                                  currency_code = booking-CurrencyCode ) into amount_per_currencycode.

    endloop.

         " Read Booking Supplements
      read entities of z_r_travel_9194 in local mode
           entity Booking by \_BookingSupplement
           fields ( BookSupplPrice CurrencyCode )
           with value #( for rba_booking in bookings ( %tky = rba_booking-%tky ) )
           result data(bookingsupplements).

      loop at bookingsupplements into data(bookingsupplement) where CurrencyCode is not initial.
        collect value ty_amount_per_currencycode( amount        = bookingsupplement-BookSupplPrice
                                                  currency_code = bookingsupplement-CurrencyCode ) into amount_per_currencycode.
      endloop.

      clear <travel>-TotalPrice.


    clear <travel>-TotalPrice.

    loop at amount_per_currencycode into data(single_amount_per_currencycode).

        " Currency Conversion
        if single_amount_per_currencycode-currency_code = <travel>-CurrencyCode.
            <travel>-TotalPrice += single_amount_per_currencycode-amount.
        else.
            /dmo/cl_flight_amdp=>convert_currency(
                exporting
                    iv_amount               = single_amount_per_currencycode-amount
                    iv_currency_code_source = single_amount_per_currencycode-currency_code
                    iv_currency_code_target = <travel>-CurrencyCode
                    iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
                importing
                    ev_amount               = data(total_booking_price_per_curr)
            ).

            <travel>-TotalPrice += total_booking_price_per_curr.
        endif.

    endloop.

   endloop.

   "write back the modified total_price of travels

    modify entities of z_r_travel_9194 in local mode
        entity travel
        update fields ( TotalPrice )
        with corresponding #( travels ).


  ENDMETHOD.

  METHOD rejectTravel.

    modify entities of z_r_travel_9194 in local mode
            entity Travel
            update fields ( OverallStatus )
            with value #( for key in keys ( %tky = key-%tky
                                             OverallStatus = travel_status-rejected ) ).

    read entities of z_r_travel_9194 in local mode
         entity Travel
         all fields
         with corresponding #( keys )
         result data(travels).

    result = value #( for travel in travels ( %tky = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

  METHOD Resume.

    data entities_update type ty_travel_update.

    read entities of z_r_travel_9194 in local mode
         entity Travel
         fields ( AgencyID )
         with value #( for key in keys
                            %is_draft = if_abap_behv=>mk-on
                            ( %key = key-%key ) )
         result data(travels).

    " Set %control-AgencyID (if set) to true, so that the precheck_auth checks the permissions.
    entities_update = corresponding #( travels changing control ).

    if entities_update is not initial.
        me->precheck_auth( exporting entities_update = entities_update
                            changing failed          = failed-travel
                                      reported       = reported-travel  ).

    endif.

  ENDMETHOD.

  METHOD calculateTotalPrice.

    modify entities of z_r_travel_9194 in local mode
           entity Travel
           execute reCalcTotalPrice
           from corresponding #( keys ).


  ENDMETHOD.

  METHOD setStatusOpen.

    read entities of z_r_travel_9194 in local mode
            entity Travel
            fields ( OverallStatus )
            with corresponding #( keys )
            result data(travels).

    delete travels where OverallStatus is not initial.

    check travels is not initial.

    modify entities of z_r_travel_9194 in local mode
           entity Travel
           update fields ( OverallStatus )
           with value #( for travel in travels ( %tky           = travel-%tky
                                                 OverallStatus  = travel_status-open ) ).

  ENDMETHOD.

  METHOD setTravelNumber.

    read entities of z_r_travel_9194 in local mode
         entity Travel
         fields ( TravelID )
         with corresponding #( keys )
         result data(travels).

    delete travels where TravelID is not initial.

    check travels is not initial.

    select single from ztb_travel_9194
        fields max( travel_id )
        into @data(lv_max_travelid).

    modify entities of z_r_travel_9194 in local mode
           entity Travel
           update fields ( TravelID )
           with value #( for travel in travels index into i ( %tky     = travel-%tky
                                                              TravelID = lv_max_travelid + i ) ).

  ENDMETHOD.

  METHOD validateAgency.
        read entities of z_r_travel_9194 in local mode
             entity Travel
             fields ( AgencyID )
             with corresponding #( keys )
             result data(travels).


    data agencies type sorted table of /dmo/agency with unique key client agency_id.

    agencies = corresponding #( travels discarding duplicates mapping agency_id = AgencyID except * ).
    delete agencies where agency_id is initial.

    if agencies is not initial.
        select from /dmo/agency as ddbb
               inner join @agencies as http_req on ddbb~agency_id = http_req~agency_id
               fields ddbb~agency_id
               into table @data(valid_agencies).

    endif.

    loop at travels into data(travel).
        append value #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_AGENCY' ) to reported-travel.

        if travel-AgencyID is initial.
            append value #( %tky = travel-%tky ) to failed-travel.

            append value #( %tky                = travel-%tky
                            %state_area         = 'VALIDAATE_AGENCY'
                            %msg                = new /dmo/cm_flight_messages(
                                                        textid      = /dmo/cm_flight_messages=>enter_agency_id
                                                        severity    = if_abap_behv_message=>severity-error )
                            %element-AgencyID   = if_abap_behv=>mk-on
                             ) to reported-travel.
        elseif travel-AgencyID is not initial and not line_exists( valid_agencies[ agency_id = travel-AgencyID ] ).
            append value #( %tky = travel-%tky ) to failed-travel.

            append value #( %tky                = travel-%tky
                            %state_area         = 'VALIDATE_AGENCY'
                            %msg                = NEW /dmo/cm_flight_messages(
                                                                    agency_id = travel-agencyid
                                                                    textid    = /dmo/cm_flight_messages=>agency_unkown
                                                                    severity  = if_abap_behv_message=>severity-error )
                            %element-AgencyID   = if_abap_behv=>mk-on
                             ) to reported-travel.
        endif.

    endloop.

  ENDMETHOD.

  METHOD validateCurrencyCode.

    read entities of z_r_travel_9194 in local mode
         entity Travel
         fields ( CurrencyCode )
         with corresponding #( keys )
         result data(travels).


    data currencies type sorted table of I_Currency with unique key Currency.

    currencies = corresponding    #( travels discarding duplicates mapping Currency = CurrencyCode except * ).
    delete currencies where Currency is initial.

    if currencies is not initial.
        select from I_Currency as ddbb
                inner join @currencies as http_req on ddbb~Currency = http_req~Currency
                fields ddbb~Currency
                into table @data(valid_currencies).

    endif.

    loop at travels into data(travel).
        append value #( %tky        = travel-%tky
                        %state_area = 'VALIDATE_CURRENCIES' ) to reported-travel.

        if travel-CurrencyCode is initial.

            append value #( %tky = travel-%tky ) to failed-travel.

            append value #( %tky = travel-%tky
                            %state_area = 'VALIDATE_CURRENCIES'
                            %msg = new /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>currency_required
                                                                severity = if_abap_behv_message=>severity-error  )
                            %element-CurrencyCode = if_abap_behv=>mk-on ) to reported-travel.
        endif.
    endloop.
  ENDMETHOD.

  METHOD validateCustomer.

    read entities of z_r_travel_9194 in local mode
        entity Travel
        fields ( CustomerID )
        with corresponding #( keys )
        result data(travels).

        data customers type sorted table of /dmo/customer with unique key client customer_id.

        customers = corresponding #( travels discarding duplicates mapping customer_id = CustomerID except * ).
        delete customers where customer_id is initial.

        if customers is not initial.

            select from /dmo/customer as ddbb
                    inner join @customers as http_req on ddbb~customer_id = http_req~customer_id
                    fields ddbb~customer_id
                    into table @data(valid_customers).

        endif.

        loop at travels into data(travel).

*           reported-travel[ 1 ]-

            append value #( %tky            = travel-%tky
                            %state_area     = 'VALIDATE_CUSTOMER' ) to reported-travel.

            if travel-CustomerID is initial.

                append value #( %tky = travel-%tky ) to failed-travel.

                append value #( %tky        = travel-%tky
                                %state_area = 'VVALIDATE CUSTOMER' ) to reported-travel.

            elseif travel-CustomerID is not initial and not line_exists( valid_customers[ customer_id = travel-CustomerID ] ).

                append value #( %tky = travel-%tky ) to failed-travel.

                append value #( %tky = travel-%tky
                                %state_area = 'VALIDATE_CUSTOMER'
                                %msg = new /dmo/cm_flight_messages( textid          = /dmo/cm_flight_messages=>customer_unkown
                                                                    severity        = if_abap_behv_message=>severity-error
                                                                    customer_id     = travel-CustomerID )
                                %element-CustomerID = if_abap_behv=>mk-on ) to reported-travel.

            endif.
        endloop.
  ENDMETHOD.

  METHOD validateDates.

    read entities of z_r_travel_9194 in local mode
         entity Travel
         fields ( BeginDate EndDate TRavelID )
         with corresponding #( keys )
         result data(travels).

    loop at travels into data(travel).
        append value #( %tky            = travel-%tky
                        %state_area     = 'VALIDATE_DATES' ) to reported-travel.

        if travel-BeginDate is initial.
            append value #(  %tky = travel-%tky ) to failed-travel.

            append value #( %tky            = travel-%tky
                            %state_area     = 'VALIDATE_DATES'
                            %msg            = new /dmo/cm_flight_messages(
                                                                textid      = /dmo/cm_flight_messages=>enter_end_date
                                                                severity    = if_abap_behv_message=>severity-error )
                           %element-EndDate = if_abap_behv=>mk-on ) to reported-travel.
        endif.
        if travel-EndDate is initial.
      append value #( %tky = travel-%tky ) to failed-travel.

        append value #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg                = new /dmo/cm_flight_messages(
                                                                textid   = /dmo/cm_flight_messages=>enter_end_date
                                                                severity = if_abap_behv_message=>severity-error )
                        %element-EndDate   = if_abap_behv=>mk-on ) to reported-travel.
        endif.
    endloop.

  ENDMETHOD.

METHOD precheck_auth.

    data: entities              type ty_travel_update,
          operation             type if_abap_behv=>t_char01,
          agencies              type sorted table of /dmo/agency with unique key agency_id,
          modify_granted type abap_bool.

    if entities_create is not initial.
        entities = corresponding #( entities_create mapping %cid_ref = %cid ).
        operation = if_abap_behv=>op-m-create.
    else.
        entities = entities_update.
        operation = if_abap_behv=>op-m-update.
    endif.

    delete entities where %control-AgencyID = if_abap_behv=>mk-off.

    agencies = corresponding #( entities discarding duplicates mapping agency_id = AgencyID except * ).

    check agencies is not initial.

    data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name(  ).

    loop at entities into data(entity).
        modify_granted = abap_true.

        if lv_technical_user eq 'CB9980001410' and entity-AgencyID ne '70025'. "WHAT EVER
            modify_granted = abap_true.
        endif.

        if modify_granted = abap_false.
            append value #( %cid       = cond #( when operation = if_abap_behv=>op-m-create
                                                  then entity-%cid_ref )
                             %tky       = entity-%tky ) to failed.

            append value #( %cid        = cond #( when operation = if_abap_behv=>op-m-create
                                                  then entity-%cid_ref )
                            %tky        = entity-%tky
                            %msg        = new /dmo/cm_flight_messages(
                                                        textid      = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                        agency_id   = entity-AgencyID
                                                        severity    = if_abap_behv_message=>severity-error )
                            %element-AgencyID   = if_abap_behv=>mk-on ) to reported.

        endif.

    endloop.

ENDMETHOD.
METHOD createTravelByTemplate.
* Al llamar al Create travel by Template tenemos clave del registro a insertar nos llegará toda la información de la entidad
* keys[ 1 ]
* result[ 1 ]
* mapped-
* failed-
* reported-
  read entities of z_r_travel_9194 in local mode
         entity Travel
         fields ( BeginDate EndDate TravelID )
         with value #( for row_key in keys ( %key = row_key-%key ) )
         result data(lt_read_entity_travel)
         FAILED failed
         reported reported.


* chequear si seguimos con la aplicación
    check failed is initial.

ENDMETHOD.


ENDCLASS.
