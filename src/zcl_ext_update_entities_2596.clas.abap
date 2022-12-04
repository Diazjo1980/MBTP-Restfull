CLASS zcl_ext_update_entities_2596 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_update_entities_2596 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF z_i_travel_2596
      ENTITY Travel
      UPDATE FIELDS ( AgencyId Description )
      WITH VALUE #( ( TravelId    = '00000001'
                      AgencyId    = '070046'
                      Description = 'Nueva actualización externa' ) )
      FAILED DATA(failed)
      REPORTED DATA(reported).

    READ ENTITIES OF z_i_travel_2596
      ENTITY Travel
      FIELDS ( AgencyId Description )
      WITH VALUE #( ( TravelId    = '00000001'  ) )
      RESULT DATA(lt_ent_result)
      FAILED failed
      REPORTED reported.

    COMMIT ENTITIES.

    IF failed IS INITIAL.
      out->write( 'Commit con éxito' ).
    ELSE.
      out->write( 'Commit fallido' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
