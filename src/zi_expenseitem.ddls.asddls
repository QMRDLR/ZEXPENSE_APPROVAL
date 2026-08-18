@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Expense Item - Interface View'
@Metadata.allowExtensions: true


define view entity ZI_EXPENSEITEM
  as select from zexp_item_od

  association to parent ZI_EXPENSEREPORT as _Report 
    on $projection.ParentUUID = _Report.ReportUUID

{
  key item_uuid             as ItemUUID,
      parent_uuid           as ParentUUID,
      item_id               as ItemID,
      category              as Category,
      @Semantics.amount.currencyCode: 'Currency'
      amount                as Amount,
      currency              as Currency,
      expense_date          as ExpenseDate,
      receipt_ref           as ReceiptRef,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      _Report
}
