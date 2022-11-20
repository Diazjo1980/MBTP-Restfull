CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

* Métodos para las acciones
    METHODS: acceptTravel    FOR MODIFY IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result,
      rejectTravel           FOR MODIFY IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result,
      createTravelByTemplate FOR MODIFY IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

* Métodos para la validaciones
    METHODS: validateCustomer FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateCustomer,
      validateDates           FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateDates,
      validateStatus          FOR VALIDATE ON SAVE IMPORTING keys FOR Travel~validateStatus.

* Features
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

* Authorizations
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.


ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

* Se realiza la lectura de los datos modificados para volcarlos en un tabla interna
    READ ENTITIES OF z_i_travel_2596 IN LOCAL MODE
     ENTITY Travel
     FIELDS ( TravelId
              TravelStatus )
     WITH VALUE #( FOR feature_row IN keys (  TravelId = feature_row-TravelId ) )
     RESULT DATA(lt_travel_result).

* Se realiza la asignación de datos para se visualizados en la capa de persistencia
    result = VALUE #( FOR ls_travel IN lt_travel_result (
                        %key                 = ls_travel-%key
                        %field-TravelId      = if_abap_behv=>fc-f-read_only
                        %field-TravelStatus  = if_abap_behv=>fc-f-read_only
                        %action-acceptTravel = COND #( WHEN ls_travel-TravelStatus = |A|
                                                         THEN if_abap_behv=>fc-o-disabled
                                                         ELSE if_abap_behv=>fc-o-enabled )
                        %action-rejectTravel = COND #( WHEN ls_travel-TravelStatus = |X|
                                                         THEN if_abap_behv=>fc-o-disabled
                                                         ELSE if_abap_behv=>fc-o-enabled )

                                                         ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CB9980002596'
                                THEN if_abap_behv=>auth-allowed
                                ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_keys>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<fs_result>).

      <fs_result> = VALUE #( %key                           = <fs_keys>-%key
                             %op-%update                    = lv_auth
                             %delete                        = lv_auth
                             %action-acceptTravel           = lv_auth
                             %action-rejectTravel           = lv_auth
                             %action-createTravelByTemplate = lv_auth
                             %assoc-_Booking                = lv_auth ).

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

* Modificación del BO seleccionado
    MODIFY ENTITIES OF z_i_travel_2596 IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( TravelStatus )
        WITH VALUE #( FOR sel_row IN keys ( TravelId     = sel_row-TravelId
                                            TravelStatus = |A| ) ) "Vaije aceptado
        FAILED failed
        REPORTED reported.

* Se realiza la lectura de los datos modificados para volcarlos en un tabla interna
    READ ENTITIES OF z_i_travel_2596 IN LOCAL MODE
     ENTITY Travel
     FIELDS ( TravelId
              AgencyId
              CustomerId
              BeginDate
              EndDate
              BookingFee
              TotalPrice
              CurrencyCode
              Description
              TravelStatus )
     WITH VALUE #( FOR mode_row IN keys (  TravelId = mode_row-TravelId ) )
     RESULT DATA(lt_travel_mod).

* Se realiza la asignación de datos para se visualizados en la capa de persistencia
    result = VALUE #( FOR ls_travel IN lt_travel_mod ( TravelId = ls_travel-TravelId
                                                       %param   = ls_travel ) ).


    LOOP AT lt_travel_mod ASSIGNING FIELD-SYMBOL(<fs_travel>).

      DATA(lv_travelid) = |{ <fs_travel>-TravelId ALPHA = OUT }|.


      APPEND VALUE #( %key = <fs_travel>-%key
                      %msg              = new_message( id       = |Z_MC_TRAVEL_2596|
                                                       number   = |005|
                                                       v1       = lv_travelid
                                                       severity = if_abap_behv_message=>severity-success )
                      %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.

  ENDMETHOD.

  METHOD createTravelByTemplate.

* keys[ 1 ]-
* result[ 1 ]-
* mapped-
* failed-
* reported-

* Leer la entidad, campos que copiaremos para el template
    READ ENTITIES OF z_i_travel_2596 IN LOCAL MODE
        ENTITY Travel
        FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
        WITH VALUE #( FOR r_keys IN keys ( %key = r_keys-%key ) )
        RESULT DATA(lt_read_data_entity_travel)
        FAILED failed
        REPORTED reported.

*    READ ENTITY z_i_travel_2596
*        FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
*        WITH VALUE #( FOR r_keys IN keys ( %key = r_keys-%key ) )
*        RESULT lt_read_data_entity_travel
*        FAILED failed
*        REPORTED reported.

    CHECK failed IS INITIAL.

* Declaraciones de variables locales
    DATA lt_template_travel TYPE TABLE FOR CREATE z_i_travel_2596\\Travel.

* Seleccionamos el último ID de viaje para la copia por template
    SELECT MAX( travel_id ) FROM ztb_travel_2596
        INTO @DATA(lv_travel_id).

* Obtenemos la fecha del día
    DATA(lv_day_today) = cl_abap_context_info=>get_system_date( ).

* Iteramos para pasar los datos al template
    lt_template_travel = VALUE #( FOR result_data IN lt_read_data_entity_travel INDEX INTO index
                                    ( TravelId     = lv_travel_id + index
                                      AgencyId     = result_data-AgencyId
                                      CustomerId   = result_data-CustomerId
                                      BeginDate    = lv_day_today
                                      EndDate      = lv_day_today + 30
                                      BookingFee   = result_data-BookingFee
                                      TotalPrice   = result_data-TotalPrice
                                      CurrencyCode = result_data-CurrencyCode
                                      Description  = |Add comments|
                                      TravelStatus = |O| ) ).

* Modificamos el ojeto de negcio que llegará a la capa de persistencia
    MODIFY ENTITIES OF z_i_travel_2596
        IN LOCAL MODE ENTITY Travel
        CREATE FIELDS ( TravelId
                        AgencyId
                        CustomerId
                        BeginDate
                        EndDate
                        BookingFee
                        TotalPrice
                        CurrencyCode
                        Description
                        TravelStatus )
        WITH lt_template_travel
        MAPPED mapped
        FAILED failed
        REPORTED reported.

* Devolvemos los datos para que sean visualizados en la capa de persistencia

    result = VALUE #( FOR final_data IN lt_template_travel INDEX INTO index
                        ( %cid_ref = keys[ index ]-%cid_ref
                          %key     = keys[ index ]-%key
                          %param   = CORRESPONDING #( final_data ) ) ).

  ENDMETHOD.

  METHOD rejectTravel.

* Modificación del BO seleccionado
    MODIFY ENTITIES OF z_i_travel_2596 IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( TravelStatus )
        WITH VALUE #( FOR sel_row IN keys ( TravelId     = sel_row-TravelId
                                            TravelStatus = |X| ) ) "Vaije rechazado
        FAILED failed
        REPORTED reported.

* Se realiza la lectura de los datos modificados para volcarlos en un tabla interna
    READ ENTITIES OF z_i_travel_2596 IN LOCAL MODE
     ENTITY Travel
     FIELDS ( TravelId
              AgencyId
              CustomerId
              BeginDate
              EndDate
              BookingFee
              TotalPrice
              CurrencyCode
              Description
              TravelStatus )
     WITH VALUE #( FOR mode_row IN keys (  TravelId = mode_row-TravelId ) )
     RESULT DATA(lt_travel_mod).

* Se realiza la asignación de datos para se visualizados en la capa de persistencia
    result = VALUE #( FOR ls_travel IN lt_travel_mod ( TravelId = ls_travel-TravelId
                                                       %param   = ls_travel ) ).

    LOOP AT lt_travel_mod ASSIGNING FIELD-SYMBOL(<fs_travel>).

      DATA(lv_travelid) = |{ <fs_travel>-TravelId ALPHA = OUT }|.


      APPEND VALUE #( %key = <fs_travel>-%key
                      %msg              = new_message( id       = |Z_MC_TRAVEL_2596|
                                                       number   = |006|
                                                       v1       = lv_travelid
                                                       severity = if_abap_behv_message=>severity-success )
                      %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

* Se realiza la lectura del Custumer ID para validar que el dato exista y no sea cualquier ingreso
    READ ENTITIES OF z_i_travel_2596 IN LOCAL MODE
     ENTITY Travel
     FIELDS ( CustomerId )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_customer_id).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_customer_id DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer
        FIELDS customer_id
        FOR ALL ENTRIES IN @lt_customer
        WHERE customer_id EQ @lt_customer-customer_id
        INTO TABLE @DATA(lt_valid_customer).

    LOOP AT lt_customer_id ASSIGNING FIELD-SYMBOL(<fs_cid>).

      IF ( <fs_cid>-CustomerId IS INITIAL ) OR NOT
          ( line_exists( lt_valid_customer[ customer_id = <fs_cid>-CustomerId ] ) ).

        APPEND VALUE #( TravelID = <fs_cid>-TravelId ) TO failed-travel.

        APPEND VALUE #( TravelID = <fs_cid>-TravelId
                        %msg = new_message( id       = |Z_MC_TRAVEL_2596|
                                            number   = |001|
                                            v1       = <fs_cid>-TravelId
                                            severity = if_abap_behv_message=>severity-error )
                        %element-customerid          = if_abap_behv=>mk-on  ) TO reported-travel.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateDates.


    READ ENTITIES OF z_i_travel_2596 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( begindate enddate )
    WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result ASSIGNING FIELD-SYMBOL(<fs_travel_result>).

      IF ( <fs_travel_result>-enddate LT <fs_travel_result>-begindate ). "end_date before begin_date

        APPEND VALUE #( %key = <fs_travel_result>-%key
        travelid = <fs_travel_result>-travelid ) TO failed-travel.

        APPEND VALUE #( %key = <fs_travel_result>-%key
                        %msg = new_message( id       = |Z_MC_TRAVEL_2596|
                                            number   = |003|
                                            v1       = <fs_travel_result>-begindate
                                            v2       = <fs_travel_result>-enddate
                                            v3       = <fs_travel_result>-travelid
                                            severity = if_abap_behv_message=>severity-error )

        %element-begindate = if_abap_behv=>mk-on
        %element-enddate   = if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF ( <fs_travel_result>-begindate < cl_abap_context_info=>get_system_date( ) ). "begin_date must be in the future

        APPEND VALUE #( %key = <fs_travel_result>-%key
        travelid = <fs_travel_result>-travelid ) TO failed-travel.

        APPEND VALUE #( %key = <fs_travel_result>-%key
                        %msg = new_message( id       = |Z_MC_TRAVEL_2596|
                                            number   = |002|
                                            severity = if_abap_behv_message=>severity-error )
                        %element-begindate           = if_abap_behv=>mk-on
                        %element-enddate             = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF z_i_travel_2596 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelStatus )
    WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      CASE ls_travel_result-TravelStatus.
        WHEN 'O'. " Open
        WHEN 'X'. " Cancelled
        WHEN 'A'. " Accepted
        WHEN OTHERS.

          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg                 = new_message( id       = |Z_MC_TRAVEL_2596|
                                                              number   = |004|
                                                              v1       = ls_travel_result-TravelStatus
                                                              severity = if_abap_behv_message=>severity-error )
                          %element-TravelStatus                        = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_2596 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_2596 IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
