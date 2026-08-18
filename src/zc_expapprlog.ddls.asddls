@EndUserText.label: 'Approval Log - Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZC_EXPAPPRLOG
  as projection on ZI_EXPAPPRLOG
  
{
  key LogUUID,
      ParentUUID,
      LogID,
      ApproverID,
      Action,
      ActionComment,
      ActionAt,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      

      _Report : redirected to parent ZC_EXPENSEREPORT
}
