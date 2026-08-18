@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status - Interface View'


define view entity ZI_EXPSTATUS
  as select from zexp_status_t
{
  key status_code   as StatusCode,
      status_text   as StatusText
}
