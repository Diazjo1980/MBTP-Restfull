CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

* Features
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.

    IF NOT keys IS INITIAL.

      zcl_aux_travel_det_2596=>get_calculate_price( it_travel_id =  VALUE #( FOR GROUPS <booking> OF booking_keys IN keys
                                                                                GROUP BY booking_keys-TravelId WITHOUT MEMBERS ( <booking> ) ) ).

    ENDIF.


  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF z_i_travel_2596 IN LOCAL MODE
    ENTITY Booking
    FIELDS ( BookingStatus )
    WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_booking_result).

    LOOP AT lt_booking_result ASSIGNING FIELD-SYMBOL(<fs_booking_result>).

      CASE <fs_booking_result>-BookingStatus.
        WHEN 'N'. " New
        WHEN 'X'. " Cancelled
        WHEN 'B'. " Booked
        WHEN OTHERS.

          APPEND VALUE #( %key = <fs_booking_result>-%key ) TO failed-booking.

          APPEND VALUE #( %key                   = <fs_booking_result>-%key
                          %msg                   = new_message( id       = |Z_MC_TRAVEL_2596|
                                                                number   = |007|
                                                                v1       = <fs_booking_result>-BookingId
                                                                severity = if_abap_behv_message=>severity-error )
                          %element-BookingStatus = if_abap_behv=>mk-on ) TO reported-booking.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

* Se realiza la lectura de los datos modificados para volcarlos en un tabla interna
    READ ENTITIES OF z_i_travel_2596 IN LOCAL MODE
     ENTITY Booking
     FIELDS ( BookingId BookingDate CustomerId BookingStatus )
     WITH VALUE #( FOR feature_row IN keys (  %key = feature_row-%key ) )
     RESULT DATA(lt_booking_result).

* Se realiza la asignación de datos para se visualizados en la capa de persistencia
    result = VALUE #( FOR ls_booking IN lt_booking_result (
                        %key                      = ls_booking-%key
                        %assoc-_BookingSupplement = if_abap_behv=>fc-o-enabled ) ).

  ENDMETHOD.

ENDCLASS.
