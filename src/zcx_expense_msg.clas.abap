CLASS zcx_expense_msg DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.
    INTERFACES if_abap_behv_message.

    CONSTANTS:
      BEGIN OF budget_exceeded,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'DEPARTMENT',
        attr2 TYPE scx_attrname VALUE 'LIMIT_AMOUNT',
        attr3 TYPE scx_attrname VALUE 'CURRENCY',
        attr4 TYPE scx_attrname VALUE 'REQUESTED_AMOUNT',
      END OF budget_exceeded,


      BEGIN OF policy_exceeded,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'CATEGORY',
        attr2 TYPE scx_attrname VALUE 'EXPENSE_DATE',
        attr3 TYPE scx_attrname VALUE 'LIMIT_AMOUNT',
        attr4 TYPE scx_attrname VALUE 'REQUESTED_AMOUNT',
      END OF policy_exceeded,


      BEGIN OF expense_date_required,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF expense_date_required,


      BEGIN OF only_draft_can_submit,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF only_draft_can_submit,


      BEGIN OF manager_approve,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF manager_approve,



      BEGIN OF manager_reject,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF manager_reject,


      BEGIN OF finance_review_can_approve,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF finance_review_can_approve,

      BEGIN OF finance_review_can_reject,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF finance_review_can_reject,


      BEGIN OF only_approved_can_be_paid,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF only_approved_can_be_paid,


      BEGIN OF item_not_editable,
        msgid TYPE symsgid VALUE 'ZEXP_MSG',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
     END OF item_not_editable.



    DATA department       TYPE zexp_report-department.
    DATA limit_amount     TYPE zexp_budget-limit_amount.
    DATA currency         TYPE zexp_budget-currency.
    DATA requested_amount TYPE zexp_report-total_amount.
    DATA category         TYPE zexp_item_od-category.
    DATA expense_date     TYPE zexp_item_od-expense_date.



    METHODS constructor
      IMPORTING
        textid           LIKE if_t100_message=>t100key OPTIONAL
        previous         LIKE previous OPTIONAL
        severity         TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        department       TYPE zexp_report-department OPTIONAL
        limit_amount     TYPE zexp_budget-limit_amount OPTIONAL
        currency         TYPE zexp_budget-currency OPTIONAL
        requested_amount TYPE zexp_report-total_amount OPTIONAL
        category         TYPE zexp_item_od-category OPTIONAL
        expense_date     TYPE zexp_item_od-expense_date OPTIONAL.

ENDCLASS.



CLASS ZCX_EXPENSE_MSG IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).

    me->department       = department.
    me->limit_amount     = limit_amount.
    me->currency         = currency.
    me->requested_amount = requested_amount.
    me->category     = category.
    me->expense_date = expense_date.



    if_abap_behv_message~m_severity = severity.

    IF textid IS INITIAL.
      if_t100_message~t100key = budget_exceeded.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
