CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.
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

ENDCLASS.
