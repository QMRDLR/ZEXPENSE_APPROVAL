@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status - Consumption View'


define view entity ZC_EXPSTATUS
  as select from ZI_EXPSTATUS
{
  key StatusCode,
      StatusText
}
