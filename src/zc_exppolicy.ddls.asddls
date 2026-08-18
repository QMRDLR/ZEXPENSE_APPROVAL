@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Policy Rule - Consumption View'

define view entity ZC_EXPPOLICY
  as select from ZI_EXPPOLICY
{
  key PolicyUUID,
      PolicyID,
      Category,
      MaxPerDay,
      Currency
}
