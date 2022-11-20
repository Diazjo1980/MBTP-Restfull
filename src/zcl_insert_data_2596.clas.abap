CLASS zcl_insert_data_2596 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_INSERT_DATA_2596 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_travel   TYPE TABLE OF ztb_travel_2596,
          lt_booking  TYPE TABLE OF ztb_booking_2596,
          lt_book_sup TYPE TABLE OF ztb_bookuppl2596.

    SELECT FROM /dmo/travel
      FIELDS travel_id,
             agency_id,
             customer_id,
             begin_date,
             end_date,
             booking_fee,
             total_price,
             currency_code,
             description,
             status        AS overall_status,
             createdby     AS created_by,
             createdat     AS created_at,
             lastchangedby AS last_changed_by,
             lastchangedat AS last_changed_at
    INTO CORRESPONDING FIELDS OF TABLE @lt_travel
    UP TO 50 ROWS.

    SELECT FROM /dmo/booking
       FIELDS *
       FOR ALL ENTRIES IN @lt_travel
       WHERE travel_id EQ @lt_travel-travel_id
    INTO CORRESPONDING FIELDS OF TABLE @lt_booking.

    SELECT FROM /dmo/book_suppl
        FIELDS *
        FOR ALL ENTRIES  IN @lt_booking
        WHERE travel_id  EQ @lt_booking-travel_id  AND
              booking_id EQ @lt_booking-booking_id
    INTO CORRESPONDING FIELDS OF TABLE @lt_book_sup.

    DELETE FROM: ztravel_log,
                 zbooking_log,
                 zbooksuppl_log.

    INSERT: ztb_travel_2596  FROM TABLE @lt_travel,
            ztb_booking_2596 FROM TABLE @lt_booking,
            ztb_bookuppl2596 FROM TABLE @lt_book_sup.

    out->write( 'Your work here it´s DONE!' ).

  ENDMETHOD.
ENDCLASS.
