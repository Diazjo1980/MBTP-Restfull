CLASS zcl_aux_travel_det_2596 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_travel_reported     TYPE TABLE FOR REPORTED z_i_travel_2596,
           tt_booking_reported    TYPE TABLE FOR REPORTED z_i_book_2596,
           tt_supplement_reported TYPE TABLE FOR REPORTED z_i_booksuppl_2596.

    TYPES: tt_travel_id TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS get_calculate_price IMPORTING it_travel_id TYPE tt_travel_id.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_aux_travel_det_2596 IMPLEMENTATION.

  METHOD get_calculate_price.

    DATA: lv_total_booking_price    TYPE /dmo/total_price,
          lv_total_supplement_price TYPE /dmo/total_price.

    IF  it_travel_id IS INITIAL.
      RETURN.
    ENDIF.

* Travel ID
    READ ENTITIES OF z_i_travel_2596
    ENTITY Travel
    FIELDS ( TravelId CurrencyCode )
    WITH VALUE #( FOR ls_travel_id IN it_travel_id (
                      TravelId = ls_travel_id )  )
    RESULT DATA(lt_read_travel).

* Booking
    READ ENTITIES OF z_i_travel_2596
    ENTITY Travel BY \_Booking
    FROM VALUE #( FOR ls_travel_id IN it_travel_id (
                      TravelId = ls_travel_id
                      %control-FlightPrice = if_abap_behv=>mk-on
                      %control-CurrencyCode = if_abap_behv=>mk-on )  )
    RESULT DATA(lt_read_booking).

    LOOP AT lt_read_booking INTO DATA(ls_booking)
        GROUP BY ls_booking-TravelId INTO DATA(lv_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = lv_travel_key ]
          TO FIELD-SYMBOL(<fs_travel>).

      LOOP AT GROUP lv_travel_key INTO DATA(ls_booking_result)
          GROUP BY ls_booking_result-CurrencyCode INTO DATA(lv_curr).

        lv_total_booking_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_booking_line).

          lv_total_booking_price += ls_booking_line-FlightPrice.

        ENDLOOP.

        IF lv_curr EQ <fs_travel>-CurrencyCode.
          <fs_travel>-TotalPrice += lv_total_booking_price.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                  iv_amount               = lv_total_booking_price
                  iv_currency_code_source = lv_curr
                  iv_currency_code_target = <fs_travel>-CurrencyCode
                  iv_exchange_rate_date   = cl_abap_context_info=>get_system_date(  )
              IMPORTING
                  ev_amount = DATA(lv_curr_converted) ).

          <fs_travel>-TotalPrice += lv_curr_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

* Booking Supplements
    READ ENTITIES OF z_i_travel_2596
    ENTITY Booking BY \_BookingSupplement
    FROM VALUE #( FOR ls_travel IN lt_read_booking (
                      TravelId          = ls_travel-TravelId
                      BookingId         = ls_travel-BookingId
                      %control-Price    = if_abap_behv=>mk-on
                      %control-Currency = if_abap_behv=>mk-on )  )
    RESULT DATA(lt_read_supplements).

    LOOP AT lt_read_supplements INTO DATA(ls_book_suppl)
        GROUP BY ls_book_suppl-TravelId INTO lv_travel_key.

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = lv_travel_key ]
          TO <fs_travel>.

      LOOP AT GROUP lv_travel_key INTO DATA(ls_supplements_result)
          GROUP BY ls_supplements_result-Currency INTO lv_curr.

        lv_total_supplement_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_supplements_line).
          lv_total_supplement_price += ls_supplements_line-Price.
        ENDLOOP.

        IF lv_curr EQ <fs_travel>-CurrencyCode.
          <fs_travel>-TotalPrice += lv_total_booking_price.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
              EXPORTING
                  iv_amount               = lv_total_supplement_price
                  iv_currency_code_source = lv_curr
                  iv_currency_code_target = <fs_travel>-CurrencyCode
                  iv_exchange_rate_date   = cl_abap_context_info=>get_system_date(  )
              IMPORTING
                  ev_amount = lv_curr_converted ).

          <fs_travel>-TotalPrice += lv_curr_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

* Se modifica la estructura del BO de la entidad principal
    MODIFY ENTITIES OF z_i_travel_2596
        ENTITY Travel
        UPDATE FROM VALUE #( FOR ls_travel_bo IN lt_read_travel (
                                 TravelId            = ls_travel_bo-TravelId
                                 TotalPrice          = ls_travel_bo-TotalPrice
                                 %control-TotalPrice = if_abap_behv=>mk-on ) ).

  ENDMETHOD.

ENDCLASS.
