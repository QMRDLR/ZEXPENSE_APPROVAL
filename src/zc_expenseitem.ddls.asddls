@EndUserText.label: 'Expense Item - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_EXPENSEITEM
  as projection on ZI_EXPENSEITEM as ExpenseItem
{
  key ItemUUID,
      ParentUUID,
      ItemID,
      Category,
      Amount,
      Currency,
      ExpenseDate,
      ReceiptRef,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _Report : redirected to parent ZC_EXPENSEREPORT
}
