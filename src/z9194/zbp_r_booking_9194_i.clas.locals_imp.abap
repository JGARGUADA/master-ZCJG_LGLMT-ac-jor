CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Booking RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Booking RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalPrice.

    METHODS setBookingDate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingDate.

    METHODS setBookingNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingNumer.

    METHODS validateConnection FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateConnection.

    METHODS validateCurrencyCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateCurrencyCode.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateCustomer.

    METHODS validateFlightPrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  method calculateTotalPrice.

    " Read parent UUID
    read entities of z_r_travel_9194 in local mode
         entity Booking by \_Travel
         fields ( TravelUUID  )
         with corresponding #(  keys  )
         result data(travels).

    " Trigger Parent Internal Action
    modify entities of z_r_travel_9194 in local mode
           entity Travel
           execute reCalcTotalPrice
           from corresponding  #( travels ).

  endmethod.

  method setBookingDate.

    read entities of z_r_travel_9194 in local mode
       entity Booking
         fields ( BookingDate )
         with corresponding #( keys )
       result data(bookings).

    delete bookings where BookingDate is not initial.

    check bookings is not initial.

    loop at bookings assigning field-symbol(<booking>).
      <booking>-BookingDate = cl_abap_context_info=>get_system_date( ).
    endloop.

    modify entities of z_r_travel_9194 in local mode
      entity Booking
        update  fields ( BookingDate )
        with corresponding #( bookings ).

  endmethod.

  method setBookingNumber.

    data max_bookingid type /dmo/booking_id.
    data booking_update type table for update z_r_travel_9194\\Booking.

    read entities of z_r_travel_9194 in local mode
         entity Booking by \_Travel
         fields ( TravelUUID )
         with corresponding #( keys )
         result data(travels).

    loop at travels into data(travel).

      read entities of z_r_travel_9194 in local mode
           entity Travel by \_Booking
           fields ( BookingID )
           with value #( ( %tky = travel-%tky ) )
           result data(bookings).

      max_bookingid = '0000'.

      loop at bookings into data(booking).
        if booking-BookingID > max_bookingid.
          max_bookingid = booking-BookingID.
        endif.
      endloop.

      loop at bookings into booking where BookingID is initial.
        max_bookingid += 1.
        append value #( %tky      = booking-%tky
                        BookingID = max_bookingid )  to booking_update.
      endloop.
    endloop.

    modify entities of z_r_travel_9194 in local mode
           entity Booking
           update fields ( BookingID )
           with booking_update.

  endmethod.

method validateConnection.

    read entities of z_r_travel_9194 in local mode
         entity Booking
         fields ( BookingID AirlineID ConnectionID FlightDate )
         with corresponding #( keys )
         result data(bookings).

    read entities of z_r_travel_9194 in local mode
         entity Booking by \_Travel
         from corresponding #( bookings )
         link data(travel_booking_links).

    loop at bookings assigning field-symbol(<booking>).

      append value #(  %tky               = <booking>-%tky
                       %state_area        = 'VALIDATE_CONNECTION' ) to reported-booking.


      if <booking>-AirlineID is initial.
        append value #( %tky = <booking>-%tky ) to failed-booking.

        append value #( %tky                = <booking>-%tky
                        %state_area         = 'VALIDATE_CONNECTION'
                         %msg                = new /dmo/cm_flight_messages(
                                                                textid = /dmo/cm_flight_messages=>enter_airline_id
                                                                severity = if_abap_behv_message=>severity-error )
                        %path              = value #( travel-%tky = travel_booking_links[ key id  source-%tky = <booking>-%tky ]-target-%tky )
                        %element-AirlineID = if_abap_behv=>mk-on
                       ) to reported-booking.
      endif.

      if <booking>-ConnectionID is initial.
        append value #( %tky = <booking>-%tky ) to failed-booking.

        append value #( %tky                = <booking>-%tky
                        %state_area         = 'VALIDATE_CONNECTION'
                        %msg                = new /dmo/cm_flight_messages(
                                                                textid = /dmo/cm_flight_messages=>enter_connection_id
                                                                severity = if_abap_behv_message=>severity-error )
                        %path               = value #( travel-%tky = travel_booking_links[ key id  source-%tky = <booking>-%tky ]-target-%tky )
                        %element-ConnectionID = if_abap_behv=>mk-on
                       ) to reported-booking.
      endif.

      if <booking>-FlightDate is initial.
        append value #( %tky = <booking>-%tky ) to failed-booking.

        append value #( %tky                = <booking>-%tky
                        %state_area         = 'VALIDATE_CONNECTION'
                        %msg                = new /dmo/cm_flight_messages(
                                                                textid = /dmo/cm_flight_messages=>enter_flight_date
                                                                severity = if_abap_behv_message=>severity-error )
                        %path               = value #( travel-%tky = travel_booking_links[ key id  source-%tky = <booking>-%tky ]-target-%tky )
                        %element-FlightDate = if_abap_behv=>mk-on
                       ) to reported-booking.
      endif.

      if <booking>-AirlineID is not initial and
         <booking>-ConnectionID is not initial and
         <booking>-FlightDate is not initial.

        select single Carrier_ID, Connection_ID, Flight_Date   from /dmo/flight  where  carrier_id    = @<booking>-AirlineID
                                                               and  connection_id = @<booking>-ConnectionID
                                                               and  flight_date   = @<booking>-FlightDate
                                                               into  @data(flight).

        if sy-subrc <> 0.
          append value #( %tky = <booking>-%tky ) to failed-booking.

          append value #( %tky                 = <booking>-%tky
                          %state_area          = 'VALIDATE_CONNECTION'
                          %msg                 = new /dmo/cm_flight_messages(
                                                                textid      = /dmo/cm_flight_messages=>no_flight_exists
                                                                carrier_id  = <booking>-AirlineID
                                                                flight_date = <booking>-FlightDate
                                                                severity    = if_abap_behv_message=>severity-error )
                          %path                  = value #( travel-%tky = travel_booking_links[ key id  source-%tky = <booking>-%tky ]-target-%tky )
                          %element-FlightDate    = if_abap_behv=>mk-on
                          %element-AirlineID     = if_abap_behv=>mk-on
                          %element-ConnectionID  = if_abap_behv=>mk-on
                        ) to reported-booking.

        endif.

      endif.

    endloop.

  endmethod.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateFlightPrice.
  ENDMETHOD.

  METHOD validateStatus.
  ENDMETHOD.

ENDCLASS.
