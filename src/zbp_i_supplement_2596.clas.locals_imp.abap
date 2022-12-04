CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSupplimPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotalSupplimPrice.

ENDCLASS.

CLASS lhc_Supplement IMPLEMENTATION.

  METHOD calculateTotalSupplimPrice.

    IF NOT keys IS INITIAL.

      zcl_aux_travel_det_2596=>get_calculate_price( it_travel_id =  VALUE #( FOR GROUPS <booking_suppl> OF booking_keys IN keys
                                                                                GROUP BY booking_keys-TravelId WITHOUT MEMBERS ( <booking_suppl> ) ) ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.
