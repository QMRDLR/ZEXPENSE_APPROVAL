@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Budget - Interface View'


define view entity ZI_EXPBUDGET
  as select from zexp_budget
  
{
  key budget_uuid       as BudgetUUID,
      budget_id         as BudgetID,
      department        as Department,
      period_start      as PeriodStart,
      @Semantics.amount.currencyCode: 'Currency'
      limit_amount      as LimitAmount,
      spent_amount      as SpentAmount,
      currency          as Currency
}
