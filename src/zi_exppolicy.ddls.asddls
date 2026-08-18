@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Policy Rule - Interface View'

define view entity ZI_EXPPOLICY
  as select from zexp_policy
{
  key policy_uuid    as PolicyUUID,
      policy_id      as PolicyID,
      category       as Category,
      @Semantics.amount.currencyCode: 'Currency'
      max_per_day    as MaxPerDay,
      currency       as Currency
}
