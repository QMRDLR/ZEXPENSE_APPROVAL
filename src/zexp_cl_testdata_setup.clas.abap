CLASS zexp_cl_testdata_setup DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.



CLASS ZEXP_CL_TESTDATA_SETUP IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    " Insert departments
*    INSERT zexp_depart_od FROM TABLE @( VALUE #(
*      ( client = sy-mandt  department_id = 'IT'    department_name = 'Information Technology' )
*      ( client = sy-mandt  department_id = 'HR'    department_name = 'Human Resources' )
*      ( client = sy-mandt  department_id = 'FIN'   department_name = 'Finance' )
*      ( client = sy-mandt  department_id = 'SALES' department_name = 'Sales' )
*    ) ).
*
*    IF sy-subrc = 0.
*      out->write( 'Departments inserted successfully.' ).
*    ELSE.
*      out->write( 'Department insert failed or already exists.' ).
*    ENDIF.
*
*    " Insert employees
*    INSERT zexp_employee FROM TABLE @( VALUE #(
*      ( client = sy-mandt  employee_id = 'EMP001'  employee_name = 'John Smith'     department_id = 'IT' )
*      ( client = sy-mandt  employee_id = 'EMP002'  employee_name = 'Emily Johnson'  department_id = 'HR' )
*      ( client = sy-mandt  employee_id = 'EMP003'  employee_name = 'Michael Brown'  department_id = 'FIN' )
*      ( client = sy-mandt  employee_id = 'EMP004'  employee_name = 'Sarah Davis'    department_id = 'SALES' )
*    ) ).
*
*    IF sy-subrc = 0.
*      out->write( 'Employees inserted successfully.' ).
*    ELSE.
*      out->write( 'Employee insert failed or already exists.' ).
*    ENDIF.


    " Insert status codes
*    DELETE FROM zexp_status_t.
*
*
*    INSERT zexp_status_t FROM TABLE @( VALUE #(
*      ( status_code = '01'  status_text = 'Draft' )
*      ( status_code = '02'  status_text = 'Manager Review' )
*      ( status_code = '03'  status_text = 'Finance Review' )
*      ( status_code = '04'  status_text = 'Approved' )
*      ( status_code = '05'  status_text = 'Rejected' )
*      ( status_code = '06'  status_text = 'Paid' )
*    ) ).
*
*    IF sy-subrc = 0.
*      out->write( 'Status codes inserted successfully.' ).
*    ELSE.
*      out->write( 'Status code insert failed or already exists.' ).
*    ENDIF.



     DELETE FROM zexp_budget.
    " Insert budgets
    INSERT zexp_budget FROM TABLE @( VALUE #(
      ( client        = sy-mandt
        budget_uuid    = cl_system_uuid=>create_uuid_x16_static( )
        budget_id      = 'BUD001'
        department     = 'IT'
        period_start   = '20260801'
        limit_amount   = '500.00'
        spent_amount   = '0.00'
        currency       = 'EUR' )

      ( client        = sy-mandt
        budget_uuid    = cl_system_uuid=>create_uuid_x16_static( )
        budget_id      = 'BUD002'
        department     = 'HR'
        period_start   = '20260801'
        limit_amount   = '300.00'
        spent_amount   = '0.00'
        currency       = 'EUR' )

      ( client        = sy-mandt
        budget_uuid    = cl_system_uuid=>create_uuid_x16_static( )
        budget_id      = 'BUD003'
        department     = 'FIN'
        period_start   = '20260801'
        limit_amount   = '1000.00'
        spent_amount   = '0.00'
        currency       = 'EUR' )
    ) ).

    IF sy-subrc = 0.
      out->write( 'Budgets inserted successfully.' ).
    ELSE.
      out->write( 'Budget insert failed or already exists.' ).
    ENDIF.



*    DELETE FROM zexp_policy.
*
*    " Insert policy rules
*    INSERT zexp_policy FROM TABLE @( VALUE #(
*      ( client      = sy-mandt
*        policy_uuid  = cl_system_uuid=>create_uuid_x16_static( )
*        policy_id    = 'POL001'
*        category     = 'LAPTOP'
*        max_per_day  = '150.00'
*        currency     = 'EUR' )
*
*      ( client      = sy-mandt
*        policy_uuid  = cl_system_uuid=>create_uuid_x16_static( )
*        policy_id    = 'POL002'
*        category     = 'KEYBOARD'
*        max_per_day  = '50.00'
*        currency     = 'EUR' )
*
*      ( client      = sy-mandt
*        policy_uuid  = cl_system_uuid=>create_uuid_x16_static( )
*        policy_id    = 'POL003'
*        category     = 'TRAVEL'
*        max_per_day  = '200.00'
*        currency     = 'EUR' )
*    ) ).
*
*    IF sy-subrc = 0.
*      out->write( 'Policy rules inserted successfully.' ).
*    ELSE.
*      out->write( 'Policy rule insert failed or already exists.' ).
*    ENDIF.


    COMMIT WORK.

  ENDMETHOD.
ENDCLASS.
