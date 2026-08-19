CLASS zexp_cl_nr_setup DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS ZEXP_CL_NR_SETUP IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA(lv_object) = CONV cl_numberrange_objects=>nr_attributes-object( 'ZEXP_RPNR' ).

    DATA lt_interval TYPE cl_numberrange_intervals=>nr_interval.

    lt_interval = VALUE #(
      ( nrrangenr  = '01'
        fromnumber = '0000000001'
        tonumber   = '9999999999'
        procind    = 'I' )
    ).

    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval  = lt_interval
            object    = lv_object
            subobject = ''
          IMPORTING
            error     = DATA(lv_error)
            error_inf = DATA(ls_error_inf)
            error_iv  = DATA(lt_error_iv)
            warning   = DATA(lv_warning)
        ).

        IF lv_error = abap_true.
          out->write( 'Error, detay:' ).
          out->write( ls_error_inf ).
          out->write( lt_error_iv ).
        ELSE.
          out->write( 'The interval was successfully created.' ).
        ENDIF.

      CATCH cx_number_ranges INTO DATA(lx_error).
        out->write( lx_error->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.





*
*
*CLASS zexp_cl_nr_setup DEFINITION
*  PUBLIC FINAL CREATE PUBLIC.
*
*  PUBLIC SECTION.
*    INTERFACES if_oo_adt_classrun.
*
*ENDCLASS.
*
*
*
*CLASS zexp_cl_nr_setup IMPLEMENTATION.
*
*
*  METHOD if_oo_adt_classrun~main.
*
*    DATA(lv_object) = CONV cl_numberrange_objects=>nr_attributes-object( 'ZEXP_RPNR' ).
*    DATA lt_interval TYPE cl_numberrange_intervals=>nr_interval.
*
*    lt_interval = VALUE #(
*      ( nrrangenr = '01' )
*    ).
*
*    TRY.
*        cl_numberrange_intervals=>delete(
*          EXPORTING
*            interval  = lt_interval
*            object    = lv_object
*            subobject = ''
*          IMPORTING
*            error     = DATA(lv_error)
*            error_inf = DATA(ls_error_inf)
*            error_iv  = DATA(lt_error_iv)
*            warning   = DATA(lv_warning)
*        ).
*
*        IF lv_error = abap_true.
*          out->write( 'Hata oluştu, silinemedi:' ).
*          out->write( ls_error_inf ).
*        ELSE.
*          out->write( 'Aralık başarıyla SİLİNDİ! Şimdi Push yapabilirsin.' ).
*        ENDIF.
*
*      CATCH cx_number_ranges INTO DATA(lx_error).
*        out->write( lx_error->get_text( ) ).
*    ENDTRY.
*
*  ENDMETHOD.
*
*ENDCLASS.

