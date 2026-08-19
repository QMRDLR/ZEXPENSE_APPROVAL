CLASS zexp_cl_dcl_test DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS ZEXP_CL_DCL_TEST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    out->write( |Current user: { cl_abap_context_info=>get_user_technical_name( ) }| ).

    DATA(lv_ts) = cl_abap_tstmp=>utclong2tstmp( utclong_current( ) ).

*    DELETE FROM zexp_report.

    INSERT zexp_report FROM @( VALUE #(
      client                = sy-mandt
      report_uuid           = cl_system_uuid=>create_uuid_x16_static( )
      report_id             = '9999999999'
      employee_id           = 'EMP001'
      department            = 'LOGISTICS'
      period_start          = '20260801'
      total_amount          = '99.00'
      currency              = 'EUR'
      status                = '01'
      local_created_by      = 'FOREIGN_USER'
      local_created_at      = lv_ts
      local_last_changed_by = 'FOREIGN_USER'
      local_last_changed_at = lv_ts
      last_changed_at       = lv_ts
    ) ).

    IF sy-subrc = 0.
      out->write( 'Foreign test record inserted (ReportID 9999999999, created by FOREIGN_USER).' ).
    ELSE.
      out->write( 'Insert failed.' ).
    ENDIF.

    COMMIT WORK.

  ENDMETHOD.
ENDCLASS.
