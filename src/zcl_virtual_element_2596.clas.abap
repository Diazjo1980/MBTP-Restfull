CLASS zcl_virtual_element_2596 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_virtual_element_2596 IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity = 'Z_C_TRAVEL_2596'.

      LOOP AT it_requested_calc_elements INTO DATA(ls_calc_elements).

        IF ls_calc_elements = 'DISCOUNTPRICE'.
          APPEND 'TOTALPRICE' TO et_requested_orig_elements.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_original_data TYPE STANDARD TABLE OF z_c_travel_2596 WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      <fs_original_data>-discountPrice = <fs_original_data>-TotalPrice - ( <fs_original_data>-TotalPrice * ( 1 / 10 ) ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.

ENDCLASS.
