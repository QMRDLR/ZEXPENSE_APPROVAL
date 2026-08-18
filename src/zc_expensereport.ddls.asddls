@EndUserText.label: 'Expense Report - Projection View'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@UI.headerInfo: { typeName: 'Expense Report', typeNamePlural: 'Expense Reports' }


define root view entity ZC_EXPENSEREPORT
  provider contract transactional_query
  as projection on ZI_EXPENSEREPORT as ExpenseReport
  
{
  key ReportUUID,
      ReportID,
//      @ObjectModel.text.element: [ 'EmployeeName' ]
      EmployeeID,
      EmployeeName,
      Department,
      PeriodStart,
      @Semantics.amount.currencyCode: 'Currency'
      TotalAmount,
      Currency,
      @ObjectModel.text.element: [ 'StatusText' ]
      Status,
      StatusText,
      StatusCriticality,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Composition */
      _Item        : redirected to composition child ZC_EXPENSEITEM,
      _ApprovalLog : redirected to composition child ZC_EXPAPPRLOG,
      
      
            /* Value Help Associations */
      _Employee,
      _Department 
}
