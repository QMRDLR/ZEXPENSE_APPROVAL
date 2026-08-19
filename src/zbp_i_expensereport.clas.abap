
*///////////////  ITEM //////////////////////////////////////////

CLASS lhc_expenseitem DEFINITION INHERITING FROM cl_abap_behavior_handler.


  PRIVATE SECTION.

    METHODS RecalcTotalAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ExpenseItem~RecalcTotalAmount.
    METHODS CalculateTotalAmountDelete FOR DETERMINE ON SAVE
      IMPORTING keys FOR ExpenseItem~CalculateTotalAmountDelete.
    METHODS CheckPolicyLimit FOR VALIDATE ON SAVE
      IMPORTING keys FOR ExpenseItem~CheckPolicyLimit.
    METHODS CheckExpenseDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR ExpenseItem~CheckExpenseDate.
    METHODS SetItemCurrency FOR DETERMINE ON SAVE
       keys FOR ExpenseItem~SetItemCurrency.
    METHODS CheckItemCreatable FOR VALIDATE ON SAVE
       keys FOR ExpenseItem~CheckItemCreatable.
    METHODS CheckItemUpdatable FOR VALIDATE ON SAVE
       keys FOR ExpenseItem~CheckItemUpdatable.
    METHODS LogItemUpdate FOR DETERMINE ON SAVE
       keys FOR ExpenseItem~LogItemUpdate.

    METHODS CheckItemEditableDelete FOR VALIDATE ON SAVE
       keys FOR ExpenseItem~CheckItemEditableDelete.



ENDCLASS.





CLASS lhc_expenseitem IMPLEMENTATION.

  METHOD RecalcTotalAmount.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseItem
        BY \_Report
        FIELDS ( ReportUUID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reports).

    DATA(lt_unique_reports) = lt_reports.
    SORT lt_unique_reports BY ReportUUID.
    DELETE ADJACENT DUPLICATES FROM lt_unique_reports COMPARING ReportUUID.

    MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        EXECUTE recalcTotalPrice
        FROM CORRESPONDING #( lt_unique_reports ).


  ENDMETHOD.



  METHOD CalculateTotalAmountDelete.

    DATA lt_parent_uuids TYPE SORTED TABLE OF sysuuid_x16 WITH UNIQUE KEY table_line.

    " READ ENTITIES silinen kalem için sonuç döndürmez, bu yüzden
    " doğrudan persistent tablodan ParentUUID'yi okuyoruz
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE parent_uuid
        FROM zexp_item_od
        WHERE item_uuid = @ls_key-%tky-ItemUUID
        INTO @DATA(lv_parent_uuid).
      IF sy-subrc = 0.
        INSERT lv_parent_uuid INTO TABLE lt_parent_uuids.
      ENDIF.
    ENDLOOP.

    IF lt_parent_uuids IS NOT INITIAL.
      MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          EXECUTE recalcTotalPrice
          FROM VALUE #( FOR uuid IN lt_parent_uuids
                         ( %tky = VALUE #( ReportUUID = uuid ) ) ).
    ENDIF.

  ENDMETHOD.




  METHOD checkpolicylimit.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseItem
        FIELDS ( ParentUUID Category ExpenseDate Amount )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_changed_items).

    DATA lt_parent_keys TYPE SORTED TABLE OF sysuuid_x16 WITH UNIQUE KEY table_line.
    LOOP AT lt_changed_items INTO DATA(ls_changed).
      INSERT ls_changed-ParentUUID INTO TABLE lt_parent_keys.
    ENDLOOP.

    LOOP AT lt_parent_keys INTO DATA(lv_parent_uuid).

      READ ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport BY \_Item
          FIELDS ( Category ExpenseDate Amount )
          WITH VALUE #( ( %tky = VALUE #( ReportUUID = lv_parent_uuid ) ) )
        RESULT DATA(lt_all_items).

      LOOP AT lt_changed_items INTO ls_changed WHERE ParentUUID = lv_parent_uuid.

        DATA lv_daily_total TYPE zexp_item_od-amount.
        CLEAR lv_daily_total.

        LOOP AT lt_all_items INTO DATA(ls_item)
          WHERE Category   = ls_changed-Category
            AND ExpenseDate = ls_changed-ExpenseDate.
          lv_daily_total += ls_item-Amount.
        ENDLOOP.

        SELECT SINGLE max_per_day, currency
          FROM zexp_policy
          WHERE category = @ls_changed-Category
          INTO @DATA(ls_policy).

        IF sy-subrc = 0 AND lv_daily_total > ls_policy-max_per_day.

          APPEND VALUE #( %tky = ls_changed-%tky )
            TO failed-expenseitem.

          APPEND VALUE #( %tky = ls_changed-%tky
                           %msg = NEW zcx_expense_msg(
                                     textid           = zcx_expense_msg=>policy_exceeded
                                     category         = ls_changed-Category
                                     expense_date     = ls_changed-ExpenseDate
                                     limit_amount     = ls_policy-max_per_day
                                     requested_amount = lv_daily_total ) )
            TO reported-expenseitem.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.



  METHOD CheckExpenseDate.


    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseItem
        FIELDS ( ExpenseDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item) WHERE ExpenseDate IS INITIAL.

      APPEND VALUE #( %tky = ls_item-%tky )
        TO failed-expenseitem.

      APPEND VALUE #( %tky = ls_item-%tky
                       %msg = NEW zcx_expense_msg(
                                 textid = zcx_expense_msg=>expense_date_required ) )
        TO reported-expenseitem.

    ENDLOOP.

  ENDMETHOD.



  METHOD SetItemCurrency.


    DATA lt_update TYPE TABLE FOR UPDATE zi_expenseitem.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseItem
        FIELDS ( Currency )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item) WHERE Currency IS INITIAL.
      APPEND VALUE #( %tky = ls_item-%tky Currency = 'EUR' ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseItem
        UPDATE FIELDS ( Currency )
        WITH lt_update.



  ENDMETHOD.



  METHOD CheckItemCreatable.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
    ENTITY ExpenseItem BY \_Report
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_reports)
    LINK DATA(lt_links).

    LOOP AT keys INTO DATA(ls_key).

      READ TABLE lt_links WITH KEY source-%tky = ls_key-%tky INTO DATA(ls_link).
      CHECK sy-subrc = 0.
      READ TABLE lt_reports WITH KEY %tky = ls_link-target-%tky INTO DATA(ls_report).
      CHECK sy-subrc = 0.

      IF ls_report-Status <> '01'.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-expenseitem.
        APPEND VALUE #( %tky = ls_key-%tky
                         %msg = NEW zcx_expense_msg( textid = zcx_expense_msg=>item_not_editable ) )
          TO reported-expenseitem.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.




  METHOD CheckItemUpdatable.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseItem BY \_Report
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reports)
      LINK DATA(lt_links).

    LOOP AT keys INTO DATA(ls_key).

      READ TABLE lt_links WITH KEY source-%tky = ls_key-%tky INTO DATA(ls_link).
      CHECK sy-subrc = 0.
      READ TABLE lt_reports WITH KEY %tky = ls_link-target-%tky INTO DATA(ls_report).
      CHECK sy-subrc = 0.

      IF ls_report-Status <> '01' AND ls_report-Status <> '02'.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-expenseitem.
        APPEND VALUE #( %tky = ls_key-%tky
                         %msg = NEW zcx_expense_msg( textid = zcx_expense_msg=>item_not_editable ) )
          TO reported-expenseitem.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.



  METHOD LogItemUpdate.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
    ENTITY ExpenseItem BY \_Report
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_reports)
    LINK DATA(lt_links).

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseItem
        FIELDS ( ItemID Category Amount ExpenseDate ReceiptRef )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_new_items).

    DATA lv_counter TYPE i VALUE 0.

    LOOP AT keys INTO DATA(ls_key).

      READ TABLE lt_links WITH KEY source-%tky = ls_key-%tky INTO DATA(ls_link).
      CHECK sy-subrc = 0.
      READ TABLE lt_reports WITH KEY %tky = ls_link-target-%tky INTO DATA(ls_report).
      CHECK sy-subrc = 0.
      CHECK ls_report-Status = '02'.

      READ TABLE lt_new_items WITH KEY %tky = ls_key-%tky INTO DATA(ls_new).
      CHECK sy-subrc = 0.

      SELECT SINGLE category, amount, expense_date, receipt_ref
        FROM zexp_item_od
        WHERE item_uuid = @ls_key-%tky-ItemUUID
        INTO @DATA(ls_old).

      CHECK sy-subrc = 0.

      DATA lv_changes TYPE string.
      CLEAR lv_changes.

      IF ls_old-amount <> ls_new-Amount.
        lv_changes = lv_changes && |Amount: { ls_old-amount } -> { ls_new-Amount }. |.
      ENDIF.

      IF ls_old-category <> ls_new-Category.
        lv_changes = lv_changes && |Category: { ls_old-category } -> { ls_new-Category }. |.
      ENDIF.

      IF ls_old-expense_date <> ls_new-ExpenseDate.
        lv_changes = lv_changes && |Date: { ls_old-expense_date DATE = USER } -> { ls_new-ExpenseDate DATE = USER }. |.
      ENDIF.

      IF ls_old-receipt_ref <> ls_new-ReceiptRef.
        lv_changes = lv_changes && |Receipt reference changed. |.
      ENDIF.

      CHECK lv_changes IS NOT INITIAL.

      lv_counter += 1.

      DATA lt_log_create TYPE TABLE FOR CREATE zi_expensereport\_ApprovalLog.
      DATA(lv_ts) = cl_abap_tstmp=>utclong2tstmp( utclong_current( ) ).

      APPEND VALUE #(
        %tky    = ls_link-target-%tky
        %target = VALUE #( (
          %cid          = |LOG_{ sy-uzeit }{ sy-datum }{ lv_counter }|
          ApproverID    = cl_abap_context_info=>get_user_technical_name( )
          Action        = 'IU'
          ActionComment = |Item { ls_new-ItemID } updated: { lv_changes }|
          ActionAt      = lv_ts
        ) )
      ) TO lt_log_create.

      MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          CREATE BY \_ApprovalLog
          FIELDS ( ApproverID Action ActionComment ActionAt )
          WITH lt_log_create.

    ENDLOOP.

  ENDMETHOD.




  METHOD CheckItemEditableDelete.

    LOOP AT keys INTO DATA(ls_key).

      SELECT SINGLE parent_uuid
        FROM zexp_item_od
        WHERE item_uuid = @ls_key-%tky-ItemUUID
        INTO @DATA(lv_parent_uuid).

      CHECK sy-subrc = 0.

      READ ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          FIELDS ( Status )
          WITH VALUE #( ( %tky = VALUE #( ReportUUID = lv_parent_uuid ) ) )
        RESULT DATA(lt_report).

      CHECK lt_report IS NOT INITIAL.

      IF lt_report[ 1 ]-Status <> '01'.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-expenseitem.
        APPEND VALUE #( %tky = ls_key-%tky
                         %msg = NEW zcx_expense_msg( textid = zcx_expense_msg=>item_not_editable ) )
          TO reported-expenseitem.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.





*///////////////  REPORT //////////////////////////////////////////

CLASS lhc_ExpenseReport DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ExpenseReport RESULT result.
    METHODS setreportid FOR DETERMINE ON SAVE
      IMPORTING keys FOR expensereport~setreportid.
    METHODS setinitialstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR expensereport~setinitialstatus.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION expensereport~recalctotalprice.
    METHODS checkbudget FOR VALIDATE ON SAVE
      IMPORTING keys FOR expensereport~checkbudget.
    METHODS setdepartmentfromemployee FOR DETERMINE ON MODIFY
      IMPORTING keys FOR expensereport~setdepartmentfromemployee.
    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION expensereport~submit RESULT result.
    METHODS managerapprove FOR MODIFY
      IMPORTING keys FOR ACTION expensereport~managerapprove RESULT result.

    METHODS managerreject FOR MODIFY
      IMPORTING keys FOR ACTION expensereport~managerreject RESULT result.
    METHODS financeapprove FOR MODIFY
      IMPORTING keys FOR ACTION expensereport~financeapprove RESULT result.

    METHODS financereject FOR MODIFY
      IMPORTING keys FOR ACTION expensereport~financereject RESULT result.

    METHODS markaspaid FOR MODIFY
      IMPORTING keys FOR ACTION expensereport~markaspaid RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ExpenseReport RESULT result.
    METHODS setdefaultcurrency FOR DETERMINE ON SAVE
       keys FOR expensereport~setdefaultcurrency.

    METHODS create_approval_log
      IMPORTING
        iv_report_uuid TYPE sysuuid_x16
        iv_action      TYPE zexp_apprlog-action
        iv_comment     TYPE zexp_apprlog-action_comment OPTIONAL.


ENDCLASS.

CLASS lhc_ExpenseReport IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.



  METHOD setreportid.

    DATA lt_report_update TYPE TABLE FOR UPDATE zi_expensereport.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        FIELDS ( ReportID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_report).

    LOOP AT lt_report INTO DATA(ls_report) WHERE ReportID IS INITIAL.

      cl_numberrange_runtime=>number_get(
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZEXP_RPNR'
        IMPORTING
          number      = DATA(lv_number)
          returncode  = DATA(lv_rc)
      ).

      APPEND VALUE #( %tky      = ls_report-%tky
                       ReportID = lv_number+10(10) )
        TO lt_report_update.

    ENDLOOP.

    MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        UPDATE FIELDS ( ReportID )
        WITH lt_report_update
      REPORTED DATA(ls_reported).

  ENDMETHOD.



  METHOD setinitialstatus.

    DATA lt_report_update TYPE TABLE FOR UPDATE zi_expensereport.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_report).

    LOOP AT lt_report INTO DATA(ls_report) WHERE Status IS INITIAL.

      APPEND VALUE #( %tky   = ls_report-%tky
                       Status = '01' )
        TO lt_report_update.

    ENDLOOP.

    MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        UPDATE FIELDS ( Status )
        WITH lt_report_update.

  ENDMETHOD.




  METHOD recalcTotalPrice.

    DATA lt_header_update TYPE TABLE FOR UPDATE zi_expensereport\\ExpenseReport.

    LOOP AT keys INTO DATA(ls_key).

      READ ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          BY \_Item
            FIELDS ( Amount )
          WITH VALUE #( ( %tky = ls_key-%tky ) )
        RESULT DATA(lt_items).

      DATA(lv_total) = CONV zexp_report-total_amount( 0 ).
      LOOP AT lt_items INTO DATA(ls_item).
        lv_total += ls_item-Amount.
      ENDLOOP.

      APPEND VALUE #( %tky        = ls_key-%tky
                       TotalAmount = lv_total )
        TO lt_header_update.

    ENDLOOP.

    MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        UPDATE FIELDS ( TotalAmount )
        WITH lt_header_update.
  ENDMETHOD.



  METHOD checkbudget.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        FIELDS ( Department PeriodStart TotalAmount Currency )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reports).

    LOOP AT lt_reports INTO DATA(ls_report).

      SELECT SINGLE limit_amount, spent_amount, currency
        FROM zexp_budget
        WHERE department   = @ls_report-Department
          AND period_start = @ls_report-PeriodStart
        INTO @DATA(ls_budget).

      IF sy-subrc = 0.

        DATA lv_available TYPE zexp_budget-limit_amount.
        lv_available = ls_budget-limit_amount - ls_budget-spent_amount.

        IF ls_report-TotalAmount > lv_available.

          APPEND VALUE #( %tky = ls_report-%tky )
            TO failed-expensereport.

          APPEND VALUE #( %tky  = ls_report-%tky
                           %msg = NEW zcx_expense_msg(
                                     textid           = zcx_expense_msg=>budget_exceeded
                                     department       = ls_report-Department
                                     limit_amount     = lv_available
                                     currency         = ls_budget-currency
                                     requested_amount = ls_report-TotalAmount ) )
            TO reported-expensereport.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.



  METHOD SetDepartmentFromEmployee.

    DATA lt_report_update TYPE TABLE FOR UPDATE zi_expensereport.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        FIELDS ( EmployeeID )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reports).

    LOOP AT lt_reports INTO DATA(ls_report) WHERE EmployeeID IS NOT INITIAL.

      SELECT SINGLE department_id
        FROM zexp_employee
        WHERE employee_id = @ls_report-EmployeeID
        INTO @DATA(lv_department_id).

      IF sy-subrc = 0.
        APPEND VALUE #( %tky       = ls_report-%tky
                         Department = lv_department_id )
          TO lt_report_update.
      ENDIF.

    ENDLOOP.

    MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        UPDATE FIELDS ( Department )
        WITH lt_report_update.

  ENDMETHOD.



  METHOD Submit.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          FIELDS ( Status )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_reports).

    DATA lt_update TYPE TABLE FOR UPDATE zi_expensereport.

    LOOP AT lt_reports INTO DATA(ls_report).

      IF ls_report-Status = '01'.
        APPEND VALUE #( %tky = ls_report-%tky Status = '02' ) TO lt_update.
        create_approval_log(
          iv_report_uuid = ls_report-ReportUUID
          iv_action      = 'SU'
          iv_comment     = 'Report submitted for approval' ).
      ELSE.
        APPEND VALUE #( %tky = ls_report-%tky ) TO failed-expensereport.
        APPEND VALUE #( %tky = ls_report-%tky
                         %msg = NEW zcx_expense_msg( textid = zcx_expense_msg=>only_draft_can_submit ) )
          TO reported-expensereport.
      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          UPDATE FIELDS ( Status )
          WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                       ( %tky   = ls_res-%tky
                         %param = ls_res ) ).

  ENDMETHOD.



  METHOD ManagerApprove.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
    ENTITY ExpenseReport
      FIELDS ( Status TotalAmount )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_reports).

    DATA lt_update TYPE TABLE FOR UPDATE zi_expensereport.

    LOOP AT lt_reports INTO DATA(ls_report).

      IF ls_report-Status = '02'.

        IF ls_report-TotalAmount < '500.00'.
          " 500 EUR altı: direkt Approved
          APPEND VALUE #( %tky = ls_report-%tky Status = '04' ) TO lt_update.
          create_approval_log(
              iv_report_uuid = ls_report-ReportUUID
              iv_action      = 'MA'
              iv_comment     = 'Approved by manager (below 500 EUR threshold)' ).
        ELSE.
          " 500 EUR ve üstü: Finance Review'a gider
          APPEND VALUE #( %tky = ls_report-%tky Status = '03' ) TO lt_update.
          create_approval_log(
              iv_report_uuid = ls_report-ReportUUID
              iv_action      = 'MA'
              iv_comment     = 'Approved by manager, forwarded to finance review' ).
        ENDIF.

      ELSE.
        APPEND VALUE #( %tky = ls_report-%tky ) TO failed-expensereport.
        APPEND VALUE #( %tky = ls_report-%tky
                         %msg = NEW zcx_expense_msg( textid = zcx_expense_msg=>manager_approve ) )
          TO reported-expensereport.
      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          UPDATE FIELDS ( Status )
          WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                       ( %tky = ls_res-%tky %param = ls_res ) ).

  ENDMETHOD.


  METHOD ManagerReject.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
    ENTITY ExpenseReport
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_reports).

    DATA lt_update TYPE TABLE FOR UPDATE zi_expensereport.

    LOOP AT lt_reports INTO DATA(ls_report).

      IF ls_report-Status = '02'.
        APPEND VALUE #( %tky = ls_report-%tky Status = '05' ) TO lt_update.
        create_approval_log(
            iv_report_uuid = ls_report-ReportUUID
            iv_action      = 'MR'
            iv_comment     = 'Rejected by manager' ).
      ELSE.
        APPEND VALUE #( %tky = ls_report-%tky ) TO failed-expensereport.
        APPEND VALUE #( %tky = ls_report-%tky
                         %msg = NEW zcx_expense_msg( textid = zcx_expense_msg=>manager_reject ) )
          TO reported-expensereport.
      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          UPDATE FIELDS ( Status )
          WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                       ( %tky = ls_res-%tky %param = ls_res ) ).


  ENDMETHOD.



  METHOD FinanceApprove.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
    ENTITY ExpenseReport
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_reports).

    DATA lt_update TYPE TABLE FOR UPDATE zi_expensereport.

    LOOP AT lt_reports INTO DATA(ls_report).

      IF ls_report-Status = '03'.
        APPEND VALUE #( %tky = ls_report-%tky Status = '04' ) TO lt_update.
        create_approval_log(
            iv_report_uuid = ls_report-ReportUUID
            iv_action      = 'FA'
            iv_comment     = 'Approved by finance' ).
      ELSE.
        APPEND VALUE #( %tky = ls_report-%tky ) TO failed-expensereport.
        APPEND VALUE #( %tky = ls_report-%tky
                         %msg = NEW zcx_expense_msg( textid = zcx_expense_msg=>finance_review_can_approve ) )
          TO reported-expensereport.
      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          UPDATE FIELDS ( Status )
          WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                       ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.




  METHOD FinanceReject.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
    ENTITY ExpenseReport
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_reports).

    DATA lt_update TYPE TABLE FOR UPDATE zi_expensereport.

    LOOP AT lt_reports INTO DATA(ls_report).

      IF ls_report-Status = '03'.
        APPEND VALUE #( %tky = ls_report-%tky Status = '05' ) TO lt_update.
        create_approval_log(
            iv_report_uuid = ls_report-ReportUUID
            iv_action      = 'FR'
            iv_comment     = 'Rejected by finance' ).
      ELSE.
        APPEND VALUE #( %tky = ls_report-%tky ) TO failed-expensereport.
        APPEND VALUE #( %tky = ls_report-%tky
                         %msg = NEW zcx_expense_msg( textid = zcx_expense_msg=>finance_review_can_reject ) )
          TO reported-expensereport.
      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          UPDATE FIELDS ( Status )
          WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                       ( %tky = ls_res-%tky %param = ls_res ) ).
  ENDMETHOD.



  METHOD MarkAsPaid.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
    ENTITY ExpenseReport
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_reports).

    DATA lt_update TYPE TABLE FOR UPDATE zi_expensereport.

    LOOP AT lt_reports INTO DATA(ls_report).

      IF ls_report-Status = '04'.
        APPEND VALUE #( %tky = ls_report-%tky Status = '06' ) TO lt_update.
        create_approval_log(
            iv_report_uuid = ls_report-ReportUUID
            iv_action      = 'PD'
            iv_comment     = 'Payment processed' ).
      ELSE.
        APPEND VALUE #( %tky = ls_report-%tky ) TO failed-expensereport.
        APPEND VALUE #( %tky = ls_report-%tky
                         %msg = NEW zcx_expense_msg( textid = zcx_expense_msg=>only_approved_can_be_paid ) )
          TO reported-expensereport.
      ENDIF.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
        ENTITY ExpenseReport
          UPDATE FIELDS ( Status )
          WITH lt_update.
    ENDIF.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_res IN lt_result
                       ( %tky = ls_res-%tky %param = ls_res ) ).

  ENDMETHOD.




  METHOD get_instance_features.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        FIELDS ( Status )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reports).

    result = VALUE #( FOR ls_report IN lt_reports
      ( %tky = ls_report-%tky


        %update = COND #( WHEN ls_report-Status = '01' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %delete = COND #( WHEN ls_report-Status = '01' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )


        "Action Dynamic Feature Control:
        %action-Submit         = COND #( WHEN ls_report-Status = '01' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-ManagerApprove = COND #( WHEN ls_report-Status = '02' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-ManagerReject  = COND #( WHEN ls_report-Status = '02' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-FinanceApprove = COND #( WHEN ls_report-Status = '03' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-FinanceReject  = COND #( WHEN ls_report-Status = '03' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-MarkAsPaid     = COND #( WHEN ls_report-Status = '04' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

        %assoc-_Item = COND #( WHEN ls_report-Status = '01' THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )

        %field-EmployeeID = COND #( WHEN ls_report-Status = '01' THEN if_abap_behv=>fc-f-unrestricted ELSE if_abap_behv=>fc-f-read_only )
        %field-PeriodStart = COND #( WHEN ls_report-Status = '01' THEN if_abap_behv=>fc-f-unrestricted ELSE if_abap_behv=>fc-f-read_only )

      ) ).

  ENDMETHOD.





  METHOD create_approval_log.

    DATA lt_log_create TYPE TABLE FOR CREATE zi_expensereport\_ApprovalLog.

    DATA(lv_ts) = cl_abap_tstmp=>utclong2tstmp( utclong_current( ) ).

    APPEND VALUE #(
      %tky    = VALUE #( ReportUUID = iv_report_uuid )
      %target = VALUE #( (
        %cid           = |LOG_{ sy-uzeit }{ sy-datum }|
        ApproverID     = cl_abap_context_info=>get_user_technical_name( )
        Action         = iv_action
        ActionComment  = iv_comment
        ActionAt       = lv_ts
      ) )
    ) TO lt_log_create.

    MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        CREATE BY \_ApprovalLog
        FIELDS ( ApproverID Action ActionComment ActionAt )
        WITH lt_log_create.

  ENDMETHOD.



  METHOD SetDefaultCurrency.

    DATA lt_update TYPE TABLE FOR UPDATE zi_expensereport.

    READ ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        FIELDS ( Currency )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reports).

    LOOP AT lt_reports INTO DATA(ls_report) WHERE Currency IS INITIAL.
      APPEND VALUE #( %tky = ls_report-%tky Currency = 'EUR' ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF zi_expensereport IN LOCAL MODE
      ENTITY ExpenseReport
        UPDATE FIELDS ( Currency )
        WITH lt_update.

  ENDMETHOD.

ENDCLASS.
